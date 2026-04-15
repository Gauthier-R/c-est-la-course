import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  final _inviteCodeCtrl = TextEditingController();
  final _groupNameCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();

  // Cache des noms de groupes pour le switcher
  Map<String, String> _groupIdToName = {};
  bool _isLoadingGroupNames = false;
  String? _switchingToGroupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupNames();
    });
  }

  @override
  void dispose() {
    _inviteCodeCtrl.dispose();
    _groupNameCtrl.dispose();
    _userNameCtrl.dispose();
    super.dispose();
  }

  /// Charge uniquement les noms des groupes pour le switcher
  Future<void> _loadGroupNames() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.userProfile == null) return;

    setState(() => _isLoadingGroupNames = true);
    try {
      final groups =
          await auth.fetchGroupsDetails(auth.userProfile!.groupIds);
      final nameMap = <String, String>{};
      for (final g in groups) {
        nameMap[g.id] = g.name;
      }
      setState(() => _groupIdToName = nameMap);
    } catch (e) {
      debugPrint('Error loading group names: $e');
    } finally {
      setState(() => _isLoadingGroupNames = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    final base64 = base64Encode(bytes);
    if (!mounted) return;

    await Provider.of<AuthProvider>(context, listen: false)
        .updateProfilePicture(base64);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_buildSnackBar('Photo de profil mise à jour !', success: true));
  }

  Future<void> _joinGroup() async {
    final code = _inviteCodeCtrl.text.trim();
    if (code.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.joinGroupWithCode(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(_buildSnackBar(
          'Demande envoyée ! En attente de la validation du chef de famille.',
          success: true,
        ));
      _inviteCodeCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(_buildSnackBar(e.toString().replaceAll('Exception: ', ''), success: false));
    }
  }

  void _renameUser(String currentName) {
    _userNameCtrl.text = currentName;
    _showInputDialog(
      title: 'Changer mon nom',
      label: 'Nouveau nom',
      controller: _userNameCtrl,
      onConfirm: () {
        if (_userNameCtrl.text.trim().isNotEmpty) {
          Provider.of<AuthProvider>(context, listen: false)
              .updateUserName(_userNameCtrl.text.trim());
        }
      },
    );
  }

  void _renameGroup(String currentName) {
    _groupNameCtrl.text = currentName;
    _showInputDialog(
      title: 'Renommer la famille',
      label: 'Nouveau nom',
      controller: _groupNameCtrl,
      onConfirm: () {
        if (_groupNameCtrl.text.trim().isNotEmpty) {
          Provider.of<AuthProvider>(context, listen: false)
              .changeGroupName(_groupNameCtrl.text.trim());
        }
      },
    );
  }

  void _showInputDialog({
    required String title,
    required String label,
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            labelText: label,
            labelStyle:
                GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.primaryOrange.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Sauvegarder', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrLeaveGroup(
      GroupModel group, String currentUserId) async {
    final isOwner = group.createdBy == currentUserId;
    final action = isOwner ? 'Supprimer' : 'Quitter';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$action la famille ?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          isOwner
              ? 'Êtes-vous sûr de vouloir supprimer définitivement ce groupe ? Les repas existants ne seront plus accessibles par les autres membres.'
              : 'Êtes-vous sûr de vouloir quitter ce groupe ? Vous ne pourrez plus voir ses repas planifiés.',
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(action, style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .removeGroup(group.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(
              isOwner ? 'Groupe supprimé.' : 'Vous avez quitté le groupe.',
              success: true));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(
              e.toString().replaceAll('Exception: ', ''), success: false));
      }
    }
  }

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_buildSnackBar('Code "$code" copié dans le presse-papier !',
          success: true));
  }

  SnackBar _buildSnackBar(String message, {required bool success}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message, style: GoogleFonts.poppins(fontSize: 13))),
        ],
      ),
      backgroundColor: success ? AppColors.primaryGreen : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userProfile;
    final group = auth.currentGroup;

    if (user == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final isOwner = group?.createdBy == user.uid;

    // Si on a des groupes dans le profil qui ne sont pas dans le cache, on recharge
    final hasMissingGroupNames =
        user.groupIds.any((id) => !_groupIdToName.containsKey(id));
    if (hasMissingGroupNames && !_isLoadingGroupNames) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadGroupNames();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Réglages',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroupNames,
        color: AppColors.primaryOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PROFIL ──────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              image: user.photoBase64 != null
                                  ? DecorationImage(
                                      image: MemoryImage(
                                          base64Decode(user.photoBase64!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user.photoBase64 == null
                                ? Center(
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.poppins(
                                          color: AppColors.primaryOrange,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user.name,
                            style: GoogleFonts.poppins(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _renameUser(user.name),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded,
                                size: 16, color: AppColors.primaryOrange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── GROUPE ACTIF ─────────────────────────────────────
              _sectionTitle('Famille active'),
              const SizedBox(height: 12),
              _buildGroupCard(group, user, isOwner),
              const SizedBox(height: 24),

              // ── CHANGER DE FAMILLE ────────────────────────────────
              if (user.groupIds.length > 1) ...[
                _sectionTitle('Changer de famille'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: _isLoadingGroupNames
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGreen),
                          ),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: user.groupIds.map((gid) {
                            final isCurrent = gid == user.currentGroupId;
                            final name = _groupIdToName[gid] ?? gid;
                            final isSwitching = _switchingToGroupId == gid;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: isCurrent || isSwitching
                                    ? null
                                    : () async {
                                        setState(
                                            () => _switchingToGroupId = gid);
                                        await auth.switchGroup(gid);
                                        await _loadGroupNames();
                                        if (mounted) {
                                          setState(
                                              () => _switchingToGroupId = null);
                                        }
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.primaryGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isCurrent
                                          ? AppColors.primaryGreen
                                          : Colors.grey.shade200,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSwitching
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isCurrent
                                                ? Colors.white
                                                : AppColors.primaryGreen,
                                          ),
                                        )
                                      : Text(
                                          name,
                                          style: GoogleFonts.poppins(
                                            color: isCurrent
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 24),
              ],

              // ── MEMBRES (temps réel via StreamBuilder) ────────────
              _sectionTitle('Membres de la famille'),
              const SizedBox(height: 12),
              if (group != null)
                _MembersStreamSection(
                  groupId: group.id,
                  currentUserId: user.uid,
                  isOwner: isOwner,
                  onRemove: (uid) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: Text('Retirer le membre',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                        content: Text(
                            'Voulez-vous retirer ce membre du groupe ?',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Annuler',
                                  style: GoogleFonts.poppins())),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Retirer', style: GoogleFonts.poppins()),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await auth.removeMember(group.id, uid);
                    }
                  },
                )
              else
                Center(
                  child: Text('Aucun groupe sélectionné.',
                      style: GoogleFonts.poppins(
                          color: AppColors.textSecondary, fontSize: 13)),
                ),
              const SizedBox(height: 24),

              // ── DEMANDES D'ACCÈS (owner + temps réel) ──────────────
              if (isOwner && group != null)
                _PendingRequestsSection(
                  groupId: group.id,
                  onAccept: (uid) => auth.acceptJoinRequest(group.id, uid),
                  onReject: (uid) => auth.rejectJoinRequest(group.id, uid),
                ),

              // ── REJOINDRE UNE FAMILLE ─────────────────────────────
              _sectionTitle('Rejoindre une famille'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inviteCodeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Code d\'invitation',
                        hintStyle: GoogleFonts.poppins(
                            color: AppColors.textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryOrange.withValues(alpha: 0.5),
                              width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _joinGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Rejoindre',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // ── DÉCONNEXION ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    auth.logOut();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: Text('Se déconnecter',
                      style:
                          GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: AppColors.textPrimary),
    );
  }

  Widget _buildGroupCard(
      GroupModel? group, UserModel user, bool isOwner) {
    if (group == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text('Chargement du groupe...',
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
      );
    }

    final isPrimaryGroup = group.id == user.primaryGroupId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // ── EN-TÊTE : icône | nom + badge | bouton(s)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                // Icône famille
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.family_restroom_rounded,
                      color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                // Nom + badge + membres — prend tout l'espace disponible
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              group.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPrimaryGroup) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Principale',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${group.members.length} membre${group.members.length > 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Bouton(s) d'action
                if (isOwner)
                  if (isPrimaryGroup)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          size: 20, color: AppColors.textSecondary),
                      onPressed: () => _renameGroup(group.name),
                      tooltip: 'Renommer',
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              size: 20, color: AppColors.textSecondary),
                          onPressed: () => _renameGroup(group.name),
                          tooltip: 'Renommer',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              size: 20, color: Colors.red.shade400),
                          onPressed: () =>
                              _deleteOrLeaveGroup(group, user.uid),
                          tooltip: 'Supprimer',
                        ),
                      ],
                    )
                else if (!isPrimaryGroup)
                  IconButton(
                    icon: Icon(Icons.exit_to_app_rounded,
                        size: 20, color: Colors.red.shade400),
                    onPressed: () => _deleteOrLeaveGroup(group, user.uid),
                    tooltip: 'Quitter',
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          // Code d'invitation avec copie
          InkWell(
            onTap: () => _copyInviteCode(group.inviteCode),
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.key_rounded,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Code d\'invitation : ',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    group.inviteCode,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.copy_rounded,
                      size: 16, color: AppColors.primaryOrange.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ── MEMBRES EN TEMPS RÉEL ──────────────────────────────────────────

class _MembersStreamSection extends StatelessWidget {
  final String groupId;
  final String currentUserId;
  final bool isOwner;
  final Future<void> Function(String uid) onRemove;

  const _MembersStreamSection({
    required this.groupId,
    required this.currentUserId,
    required this.isOwner,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primaryGreen));
        }

        if (!snapshot.data!.exists) {
          return Text('Groupe introuvable.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary));
        }

        final group = GroupModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>, groupId);
        final memberIds = group.members;

        if (memberIds.isEmpty) {
          return Text('Aucun membre.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary));
        }

        return FutureBuilder<List<UserModel>>(
          future: Provider.of<AuthProvider>(context, listen: false)
              .fetchUsersDetails(memberIds),
          builder: (context, uSnap) {
            final members = uSnap.data ?? [];

            return Column(
              children: members.map((member) {
                final isMe = member.uid == currentUserId;
                final isGroupOwner = member.uid == group.createdBy;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primaryGreen.withValues(alpha: 0.12),
                      backgroundImage: member.photoBase64 != null
                          ? MemoryImage(base64Decode(member.photoBase64!))
                          : null,
                      child: member.photoBase64 == null
                          ? Text(
                              member.name.isNotEmpty
                                  ? member.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(
                      member.name + (isMe ? ' (moi)' : ''),
                      style:
                          GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: isGroupOwner
                        ? Text('Chef de famille',
                            style: GoogleFonts.poppins(
                                color: AppColors.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w500))
                        : null,
                    trailing: (isOwner && !isMe)
                        ? IconButton(
                            icon: Icon(Icons.person_remove_outlined,
                                size: 20, color: Colors.grey.shade400),
                            onPressed: () => onRemove(member.uid),
                            tooltip: 'Retirer',
                          )
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

// ── DEMANDES EN ATTENTE EN TEMPS RÉEL ─────────────────────────────

class _PendingRequestsSection extends StatelessWidget {
  final String groupId;
  final Future<void> Function(String uid) onAccept;
  final Future<void> Function(String uid) onReject;

  const _PendingRequestsSection({
    required this.groupId,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final group = GroupModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>, groupId);
        final pendingIds = group.pendingRequests;

        if (pendingIds.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.primaryOrange, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  'Demandes d\'accès (${pendingIds.length})',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<UserModel>>(
              future: Provider.of<AuthProvider>(context, listen: false)
                  .fetchUsersDetails(pendingIds),
              builder: (ctx, uSnap) {
                final pendingUsers = uSnap.data ?? [];
                return Column(
                  children: pendingUsers.map((pending) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primaryOrange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primaryOrange.withValues(alpha: 0.15),
                            child: Text(
                              pending.name.isNotEmpty
                                  ? pending.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pending.name,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600)),
                                Text(pending.email,
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded,
                                color: AppColors.primaryGreen),
                            onPressed: () => onAccept(pending.uid),
                            tooltip: 'Accepter',
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel_rounded,
                                color: Colors.red.shade400),
                            onPressed: () => onReject(pending.uid),
                            tooltip: 'Refuser',
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
