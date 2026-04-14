import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // Polling automatique toutes les 4 secondes
  Timer? _pollingTimer;

  // Cooldown de 60s avant de pouvoir renvoyer l'email
  Timer? _cooldownTimer;
  int _cooldownSecondsLeft = 0;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 4), (_) async {
      await _checkVerification(silent: true);
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (!mounted) return;

    if (!silent) setState(() => _isReloading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.reloadUser();

    if (!mounted) return;

    if (!silent) setState(() => _isReloading = false);

    // Si vérifié, le Consumer dans AuthWrapper redirigera automatiquement.
    // On signale manuellement si c'est une vérification manuelle.
    if (!silent && !(auth.authUser?.emailVerified ?? false)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Email pas encore vérifié. Vérifiez votre boîte mail.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppColors.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
    }
  }

  void _resendEmail() async {
    if (_cooldownSecondsLeft > 0) return;

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .resendVerificationEmail();
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text('Email renvoyé !', style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

      // Démarrer le cooldown de 60 secondes
      setState(() => _cooldownSecondsLeft = 60);
      _cooldownTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _cooldownSecondsLeft--;
          if (_cooldownSecondsLeft <= 0) {
            timer.cancel();
          }
        });
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = auth.authUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── ICÔNE ANIMÉE ──
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 56,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 32),

                // ── TITRE ──
                Text(
                  'Vérifiez votre email',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // ── EMAIL ──
                if (email.isNotEmpty) ...[
                  Text(
                    'Un lien a été envoyé à',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                Text(
                  'Cliquez sur le lien de confirmation pour activer votre compte. Cette page se mettra à jour automatiquement.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ── BOUTON VÉRIFIER MANUELLEMENT ──
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isReloading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                              strokeWidth: 3,
                            ),
                          )
                        : ElevatedButton.icon(
                            key: const ValueKey('check_btn'),
                            onPressed: () => _checkVerification(),
                            icon: const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 20),
                            label: Text(
                              "J'ai vérifié mon email",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── RENVOYER EMAIL avec cooldown ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _cooldownSecondsLeft > 0
                      ? Text(
                          'Renvoyer dans $_cooldownSecondsLeft s',
                          key: const ValueKey('countdown'),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : TextButton(
                          key: const ValueKey('resend_btn'),
                          onPressed: _resendEmail,
                          child: Text(
                            'Renvoyer l\'email de vérification',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // ── RETOUR ──
                TextButton.icon(
                  onPressed: () =>
                      Provider.of<AuthProvider>(context, listen: false)
                          .logOut(),
                  icon: const Icon(Icons.arrow_back_rounded,
                      size: 16, color: AppColors.textSecondary),
                  label: Text(
                    'Retour à la connexion',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
