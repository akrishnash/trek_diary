import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/auth_provider.dart';

// Simulated Google accounts — in a real app this would use google_sign_in SDK
final _mockAccounts = [
  (name: 'Anurag Sharma',  email: 'anurag@gmail.com'),
  (name: 'Explorer Anon', email: 'explorer@gmail.com'),
];

class AuthGoogleScreen extends ConsumerStatefulWidget {
  const AuthGoogleScreen({super.key});

  @override
  ConsumerState<AuthGoogleScreen> createState() => _AuthGoogleScreenState();
}

class _AuthGoogleScreenState extends ConsumerState<AuthGoogleScreen> {
  bool _loading = false;

  Future<void> _selectAccount(String name, String email) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    ref.read(authPendingProvider.notifier).state = (
      name:       name,
      email:      email,
      phone:      '',
      authMethod: 'google',
    );

    setState(() => _loading = false);
    if (mounted) context.push('/auth/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1F1C), Color(0xFF252B28)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _BackChevron(onTap: () => context.pop()),
              ),
              const SizedBox(height: 36),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Google G logo area
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('G',
                              style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700,
                                color: Color(0xFF4285F4),
                              )),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Google',
                          style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Choose an account',
                      style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: Colors.white, height: 1.2,
                      )),
                    const SizedBox(height: 6),
                    Text('to continue to Trek Diary',
                      style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A9590),
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4285F4), strokeWidth: 2),
                  ),
                )
              else ...[
                // Account list
                ..._mockAccounts.map((a) => _AccountTile(
                  name: a.name,
                  email: a.email,
                  onTap: () => _selectAccount(a.name, a.email),
                )),

                const SizedBox(height: 8),

                // Use another account
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () => _showAddAccount(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252B28),
                        borderRadius: BorderRadius.circular(14),
                        border: const Border.fromBorderSide(
                          BorderSide(color: Color(0xFF3A4240))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add,
                            color: Color(0xFF8A9590), size: 18),
                          const SizedBox(width: 8),
                          Text('Use another account',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF8A9590),
                              fontSize: 13, fontWeight: FontWeight.w500,
                            )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccount(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1F1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add account',
              style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _DarkField(controller: nameCtrl, hint: 'Your name'),
            const SizedBox(height: 12),
            _DarkField(
              controller: emailCtrl,
              hint: 'Gmail address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                    _selectAccount(nameCtrl.text.trim(), emailCtrl.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A1F1C),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1F1C),
                  )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTap;
  const _AccountTile({
    required this.name, required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF252B28),
        borderRadius: BorderRadius.circular(14),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFF3A4240))),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4285F4).withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600,
                  color: const Color(0xFF4285F4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                  style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
                Text(email,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8A9590), fontSize: 12,
                  )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
            color: Color(0xFF6A7570), size: 20),
        ],
      ),
    ),
  );
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _DarkField({
    required this.controller, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6A7570), fontSize: 15),
      filled: true,
      fillColor: const Color(0xFF252B28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A4240)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A4240)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
    ),
  );
}

class _BackChevron extends StatelessWidget {
  final VoidCallback onTap;
  const _BackChevron({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2E3530),
        border: Border.all(color: const Color(0xFF3A4240), width: 1),
      ),
      child: const Icon(Icons.chevron_left_rounded,
        color: Colors.white, size: 22),
    ),
  );
}
