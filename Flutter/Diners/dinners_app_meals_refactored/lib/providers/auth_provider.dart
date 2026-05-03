import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _authUser;
  UserModel? _userProfile;
  GroupModel? _currentGroup;

  bool _isLoading = true;

  // Flag pour éviter le double-chargement lors de la création de compte
  bool _isCreatingAccount = false;

  // Subscription au stream du groupe courant (temps réel)
  StreamSubscription<DocumentSnapshot>? _groupStreamSub;
  // Subscription au stream du profil utilisateur (temps réel)
  StreamSubscription<DocumentSnapshot>? _userStreamSub;

  User? get authUser => _authUser;
  UserModel? get userProfile => _userProfile;
  GroupModel? get currentGroup => _currentGroup;
  String? get currentGroupId => _userProfile?.currentGroupId;
  bool get isLoading => _isLoading;

  /// Vrai si l'utilisateur s'est connecté via Google
  bool get isGoogleUser =>
      _authUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) async {
      _authUser = user;
      if (user != null) {
        // Si une création de compte est en cours, on laisse signUpWithEmail
        // gérer le chargement initial pour éviter la race condition.
        if (_isCreatingAccount) return;
        await _loadUserProfile(user.uid);
      } else {
        _cancelGroupStream();
        _cancelUserStream();
        _userProfile = null;
        _currentGroup = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // ─── CHARGEMENT DU PROFIL ──────────────────────────────────────────

  Future<void> _loadUserProfile(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      var doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        // Retry avec backoff progressif (3 tentatives)
        for (int i = 1; i <= 3; i++) {
          await Future.delayed(Duration(milliseconds: 300 * i));
          doc = await _firestore.collection('users').doc(uid).get();
          if (doc.exists) break;
        }
      }

      if (doc.exists) {
        _userProfile = UserModel.fromMap(doc.data()!, doc.id);
        _startUserStream(uid); // Abonnement temps réel au profil utilisateur
        await _loadCurrentGroup();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentGroup() async {
    _cancelGroupStream();

    if (_userProfile == null || _userProfile!.currentGroupId.isEmpty) return;

    final groupId = _userProfile!.currentGroupId;

    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();

      if (doc.exists) {
        _currentGroup = GroupModel.fromMap(doc.data() ?? {}, doc.id);
        // Abonnement temps réel au groupe
        _startGroupStream(groupId);
      } else {
        // Le groupe n'existe plus → nettoyer le profil utilisateur
        debugPrint('Groupe $groupId introuvable, nettoyage...');
        await _handleOrphanGroup(groupId);
      }
    } catch (e) {
      debugPrint('Error loading group: $e');
    }
  }

  void _startGroupStream(String groupId) {
    _groupStreamSub = _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentGroup = GroupModel.fromMap(snapshot.data() ?? {}, snapshot.id);
        notifyListeners();
      }
    });
  }

  void _cancelGroupStream() {
    _groupStreamSub?.cancel();
    _groupStreamSub = null;
  }

  void _startUserStream(String uid) {
    _userStreamSub?.cancel();
    _userStreamSub = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final newUserProfile = UserModel.fromMap(snapshot.data()!, snapshot.id);
        bool currentGroupChanged = _userProfile?.currentGroupId != newUserProfile.currentGroupId;
        
        _userProfile = newUserProfile;

        if (currentGroupChanged && newUserProfile.currentGroupId.isNotEmpty) {
          _loadCurrentGroup(); // Will call notifyListeners
        } else {
          notifyListeners();
        }
      }
    });
  }

  void _cancelUserStream() {
    _userStreamSub?.cancel();
    _userStreamSub = null;
  }

  /// Gère le cas où le groupe courant n'existe plus (supprimé par l'admin).
  Future<void> _handleOrphanGroup(String orphanGroupId) async {
    if (_authUser == null || _userProfile == null) return;

    final newGroupIds =
        List<String>.from(_userProfile!.groupIds)..remove(orphanGroupId);
    final newCurrentGroupId =
        newGroupIds.isNotEmpty ? newGroupIds.first : '';

    await _firestore.collection('users').doc(_authUser!.uid).update({
      'groupIds': newGroupIds,
      'currentGroupId': newCurrentGroupId,
    });

    _userProfile = UserModel(
      uid: _userProfile!.uid,
      email: _userProfile!.email,
      name: _userProfile!.name,
      currentGroupId: newCurrentGroupId,
      groupIds: newGroupIds,
      photoBase64: _userProfile!.photoBase64,
      primaryGroupId: _userProfile!.primaryGroupId,
    );
    _currentGroup = null;

    if (newCurrentGroupId.isNotEmpty) {
      await _loadCurrentGroup();
    }
  }

  // ─── AUTHENTIFICATION ──────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    _isCreatingAccount = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        // 1. Envoyer l'email de vérification
        await cred.user!.sendEmailVerification();
        // 2. Créer le document Firestore
        await _createUserDocument(cred.user!, name: name);
        // 3. Mettre à jour l'_authUser localement
        _authUser = cred.user;
        // 4. Charger le profil
        await _loadUserProfile(cred.user!.uid);
      }
    } finally {
      _isCreatingAccount = false;
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    _authUser = _auth.currentUser;
    notifyListeners();
  }

  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        var doc =
            await _firestore.collection('users').doc(cred.user!.uid).get();
        if (!doc.exists) {
          await _createUserDocument(cred.user!,
              name: cred.user!.displayName ?? 'Utilisateur');
        }
        await _loadUserProfile(cred.user!.uid);
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> logOut() async {
    _cancelGroupStream();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<void> _createUserDocument(User user, {required String name}) async {
    final groupDoc = _firestore.collection('groups').doc();
    final inviteCode = _generateRandomString(6);

    final groupMap = {
      'name': 'Ma famille',
      'createdBy': user.uid,
      'inviteCode': inviteCode,
      'members': [user.uid],
      'pendingRequests': [],
    };
    await groupDoc.set(groupMap);

    final userMap = {
      'email': user.email ?? '',
      'name': name,
      'currentGroupId': groupDoc.id,
      'groupIds': [groupDoc.id],
      'primaryGroupId': groupDoc.id, // Groupe par défaut, ne peut pas être supprimé
    };
    await _firestore.collection('users').doc(user.uid).set(userMap);
  }

  // ─── GESTION DES GROUPES ──────────────────────────────────────────

  Future<void> switchGroup(String groupId) async {
    if (_userProfile == null) return;
    if (!_userProfile!.groupIds.contains(groupId)) return;
    if (_userProfile!.currentGroupId == groupId) return;

    // Mise à jour locale immédiate pour une UX fluide
    _userProfile = UserModel(
      uid: _userProfile!.uid,
      email: _userProfile!.email,
      name: _userProfile!.name,
      currentGroupId: groupId,
      groupIds: _userProfile!.groupIds,
      photoBase64: _userProfile!.photoBase64,
      primaryGroupId: _userProfile!.primaryGroupId,
    );
    _currentGroup = null;
    notifyListeners();

    // Écriture Firestore + rechargement du nouveau groupe en parallèle
    await Future.wait([
      _firestore.collection('users').doc(_authUser!.uid).update({
        'currentGroupId': groupId,
      }),
      _loadCurrentGroup(),
    ]);
  }

  Future<void> joinGroupWithCode(String code) async {
    if (_userProfile == null) throw Exception('Non connecté');

    final upperCode = code.trim().toUpperCase();
    if (upperCode.isEmpty) throw Exception('Code invalide');

    final qs = await _firestore
        .collection('groups')
        .where('inviteCode', isEqualTo: upperCode)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) {
      throw Exception('Code invalide ou introuvable');
    }

    final groupDoc = qs.docs.first;
    final groupId = groupDoc.id;

    if (_userProfile!.groupIds.contains(groupId)) {
      throw Exception('Vous êtes déjà dans ce groupe');
    }

    final groupData = GroupModel.fromMap(groupDoc.data(), groupDoc.id);
    if (groupData.pendingRequests.contains(_authUser!.uid)) {
      throw Exception('Votre demande est déjà en attente de validation');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'pendingRequests': FieldValue.arrayUnion([_authUser!.uid]),
    });
  }

  Future<void> acceptJoinRequest(String groupId, String userId) async {
    if (_currentGroup == null || _currentGroup!.id != groupId) return;
    if (_currentGroup!.createdBy != _authUser!.uid) {
      throw Exception('Action non autorisée');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
      'pendingRequests': FieldValue.arrayRemove([userId]),
    });

    await _firestore.collection('users').doc(userId).update({
      'groupIds': FieldValue.arrayUnion([groupId]),
      'currentGroupId': groupId,
    });

    // Le stream du groupe mettra à jour _currentGroup automatiquement
  }

  Future<void> rejectJoinRequest(String groupId, String userId) async {
    if (_currentGroup == null || _currentGroup!.id != groupId) return;
    if (_currentGroup!.createdBy != _authUser!.uid) {
      throw Exception('Action non autorisée');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'pendingRequests': FieldValue.arrayRemove([userId]),
    });

    // Le stream mettra à jour automatiquement
  }

  Future<void> removeMember(String groupId, String userId) async {
    if (_currentGroup == null || _currentGroup!.id != groupId) return;
    if (_currentGroup!.createdBy != _authUser!.uid) {
      throw Exception('Action non autorisée');
    }
    if (userId == _authUser!.uid) {
      throw Exception('Vous ne pouvez pas vous retirer vous-même');
    }

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
    });

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = UserModel.fromMap(userDoc.data()!, userDoc.id);
      final newGroupIds = List<String>.from(userData.groupIds)..remove(groupId);
      final newCurrent = userData.currentGroupId == groupId
          ? (newGroupIds.isNotEmpty ? newGroupIds.first : '')
          : userData.currentGroupId;

      await _firestore.collection('users').doc(userId).update({
        'groupIds': newGroupIds,
        'currentGroupId': newCurrent,
      });
    }

    // Le stream mettra à jour automatiquement
  }

  Future<void> changeGroupName(String newName) async {
    if (_currentGroup == null) return;
    await _firestore
        .collection('groups')
        .doc(_currentGroup!.id)
        .update({'name': newName});
    // Le stream mettra à jour automatiquement
  }

  Future<void> updateWeekStartDay(int day) async {
    if (_currentGroup == null) return;
    await _firestore
        .collection('groups')
        .doc(_currentGroup!.id)
        .update({'weekStartDay': day});
  }

  Future<void> removeGroup(String groupId) async {
    if (_userProfile == null) return;

    // Protection : le groupe principal ne peut pas être supprimé ou quitté
    if (groupId == _userProfile!.primaryGroupId) {
      throw Exception('Votre groupe famille principal ne peut pas être supprimé.');
    }

    if (_userProfile!.groupIds.length <= 1) {
      throw Exception('Vous devez avoir au moins un groupe actif.');
    }

    final groupDoc =
        await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) return;

    final groupDetails = GroupModel.fromMap(groupDoc.data()!, groupDoc.id);

    if (groupDetails.createdBy == _authUser!.uid) {
      // Owner → supprimer le groupe
      // Les autres membres seront nettoyés via _handleOrphanGroup à leur prochain chargement
      await _firestore.collection('groups').doc(groupId).delete();
    } else {
      // Membre → quitter le groupe
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([_authUser!.uid]),
      });
    }

    final newGroupIds =
        List<String>.from(_userProfile!.groupIds)..remove(groupId);
    final newCurrentGroupId =
        newGroupIds.isNotEmpty ? newGroupIds.first : '';

    await _firestore.collection('users').doc(_authUser!.uid).update({
      'groupIds': newGroupIds,
      'currentGroupId': newCurrentGroupId,
    });

    await _loadUserProfile(_authUser!.uid);
  }

  // ─── REQUÊTES ──────────────────────────────────────────

  Future<List<UserModel>> fetchUsersDetails(List<String> uids) async {
    if (uids.isEmpty) return [];
    final qs = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    return qs.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<GroupModel>> fetchGroupsDetails(List<String> groupIds) async {
    if (groupIds.isEmpty) return [];
    final qs = await _firestore
        .collection('groups')
        .where(FieldPath.documentId, whereIn: groupIds)
        .get();
    return qs.docs
        .map((doc) => GroupModel.fromMap(doc.data() ?? {}, doc.id))
        .toList();
  }

  Future<void> updateUserName(String newName) async {
    if (_authUser == null) return;
    await _firestore
        .collection('users')
        .doc(_authUser!.uid)
        .update({'name': newName});
    if (_userProfile != null) {
      _userProfile = UserModel(
        uid: _userProfile!.uid,
        email: _userProfile!.email,
        name: newName,
        currentGroupId: _userProfile!.currentGroupId,
        groupIds: _userProfile!.groupIds,
        photoBase64: _userProfile!.photoBase64,
        primaryGroupId: _userProfile!.primaryGroupId,
      );
    }
    notifyListeners();
  }

  Future<void> updateProfilePicture(String base64) async {
    if (_authUser == null) return;
    await _firestore
        .collection('users')
        .doc(_authUser!.uid)
        .update({'photoBase64': base64});
    if (_userProfile != null) {
      _userProfile = UserModel(
        uid: _userProfile!.uid,
        email: _userProfile!.email,
        name: _userProfile!.name,
        currentGroupId: _userProfile!.currentGroupId,
        groupIds: _userProfile!.groupIds,
        photoBase64: base64,
        primaryGroupId: _userProfile!.primaryGroupId,
      );
    }
    notifyListeners();
  }

  // ─── UTILS ──────────────────────────────────────────

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  @override
  void dispose() {
    _cancelGroupStream();
    _cancelUserStream();
    super.dispose();
  }
}
