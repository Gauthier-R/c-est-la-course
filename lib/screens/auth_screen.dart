import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🌐 Nécessaire pour kIsWeb
import '../utils/url_helper/url_helper.dart'; // ⬇️ Pour télécharger l'APK
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animCtrl.reverse().then((_) {
      setState(() => _isLogin = !_isLogin);
      _formKey.currentState?.reset();
      _animCtrl.forward();
    });
  }

  /// Traduit les codes d'erreur Firebase en messages lisibles en français.
  String _translateFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun compte trouvé pour cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères.';
      case 'invalid-email':
        return 'L\'adresse email est invalide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      default:
        return e.message ?? 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await auth.signInWithEmail(email, password);
      } else {
        await auth.signUpWithEmail(email, password, name);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_translateFirebaseError(e));
    } catch (e) {
      if (!mounted) return;
      _showError('Une erreur inattendue est survenue.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submitGoogle() async {
    final auth =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      await auth.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_translateFirebaseError(e));
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.contains('DEVELOPER_ERROR') ||
          errorMsg.contains('10:')) {
        errorMsg =
            'Erreur SHA-1 non configurée. Vérifiez la console Firebase.';
      }
      _showError(errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError(
          'Entrez votre email ci-dessus pour réinitialiser votre mot de passe.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Provider.of<app_auth.AuthProvider>(context, listen: false)
          .sendPasswordResetEmail(email);
      if (!mounted) return;
      _showSuccess('Email de réinitialisation envoyé à $email');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_translateFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 13))),
            ],
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 13))),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // ⬇️ Bouton pour télécharger l'app sur Android depuis le Web (Écran de connexion)
          if (kIsWeb && defaultTargetPlatform == TargetPlatform.android)
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.android_rounded, color: AppColors.primaryGreen),
                tooltip: 'Télécharger l\'application Android',
                onPressed: () {
                  // Lien direct de téléchargement GitHub Releases
                  openExternalUrl('https://github.com/Gauthier-R/DinnersApp-Releases/releases/latest/download/app-release.apk');
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── LOGO ──
                    Center(
                      child: Image.asset(
                        'assets/Logo_CLC.png',
                        width: 110,
                        height: 110,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── TITRE ──
                    Text(
                      _isLogin ? 'Bon retour !' : 'Créer un compte',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Connectez-vous pour continuer.'
                          : 'Rejoignez-nous et organisez vos repas.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // ── CHAMPS ──
                    if (!_isLogin) ...[
                      _buildField(
                        controller: _nameCtrl,
                        label: 'Prénom',
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez entrer votre prénom'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$')
                            .hasMatch(v.trim())) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      controller: _passwordCtrl,
                      label: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        if (!_isLogin && v.trim().length < 6) {
                          return 'Minimum 6 caractères';
                        }
                        return null;
                      },
                    ),

                    // ── MOT DE PASSE OUBLIÉ ──
                    if (_isLogin) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Mot de passe oublié ?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // ── BOUTON PRINCIPAL ──
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryOrange,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('submit'),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _isLogin ? 'Se connecter' : "S'inscrire",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // ── SWITCH MODE ──
                    if (!_isLoading)
                      TextButton(
                        onPressed: _toggleMode,
                        child: Text(
                          _isLogin
                              ? "Pas encore de compte ? S'inscrire"
                              : "Déjà un compte ? Se connecter",
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // ── OU ──
                    Row(
                      children: [
                        Expanded(
                            child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ),
                        Expanded(
                            child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── GOOGLE ──
                    OutlinedButton(
                      onPressed: _isLoading ? null : _submitGoogle,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GoogleLogo(),
                          const SizedBox(width: 12),
                          Text(
                            'Continuer avec Google',
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 15),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: AppColors.primaryOrange.withValues(alpha: 0.6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
        errorStyle: GoogleFonts.poppins(fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Logo Google en SVG-like via Text (évite une dépendance externe)
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4285F4),
            height: 1,
          ),
        ),
      ),
    );
  }
}
