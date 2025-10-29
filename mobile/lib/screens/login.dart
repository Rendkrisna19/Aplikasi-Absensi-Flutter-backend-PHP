import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/session.dart';
import 'home.dart';
import 'register.dart';
import 'admin_dashboard.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final user = TextEditingController();
  final pass = TextEditingController();
  String role = 'karyawan';
  bool loading = false;


Future<void> _login() async {
  if (!_form.currentState!.validate()) return;
  setState(() => loading = true);

  final r = await Api.post('/auth/login.php', {
    'username': user.text.trim(),
    'password': pass.text.trim(),
    'role': role, // 'karyawan' | 'admin'
  });

  setState(() => loading = false);

  if ((r['status'] ?? 0) != 200 || r['token'] == null) {
    final msg = r['error'] ?? 'Gagal login (status ${r['status'] ?? '-'})';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
      ),
    );
    return;
  }

  await Session.saveToken(r['token'] as String, role);

  if (!mounted) return;
  if (role == 'admin') {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      (_) => false,
    );
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }
}


  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    final base = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.blue.shade200, width: 1),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: base,
      border: base,
      focusedBorder: base.copyWith(
        borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
      ),
      errorBorder: base.copyWith(
        borderSide: BorderSide(color: Colors.red.shade400, width: 1),
      ),
      focusedErrorBorder: base.copyWith(
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue.shade700;
    final secondary = Colors.blue.shade400;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Masuk'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header / Avatar / Judul
                        Column(
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [secondary, primary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.lock_outline, size: 38, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Selamat Datang 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Masuk untuk melanjutkan',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Role
                        DropdownButtonFormField<String>(
                          value: role,
                          decoration: _fieldDecoration(label: 'Peran', icon: Icons.badge_outlined),
                          items: const [
                            DropdownMenuItem(value: 'karyawan', child: Text('Karyawan')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (v) => setState(() => role = v ?? 'karyawan'),
                        ),

                        const SizedBox(height: 14),

                        // Username
                        TextFormField(
                          controller: user,
                          decoration: _fieldDecoration(label: 'Username', icon: Icons.person_outline),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Username wajib' : null,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 14),

                        // Password
                        TextFormField(
                          controller: pass,
                          obscureText: true,
                          decoration: _fieldDecoration(label: 'Password', icon: Icons.lock_outline_rounded),
                          validator: (v) => (v == null || v.isEmpty) ? 'Password wajib' : null,
                          onFieldSubmitted: (_) {
                            if (!loading) _login();
                          },
                        ),

                        const SizedBox(height: 18),

                        // Tombol Masuk
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              disabledBackgroundColor: Colors.blue.shade200,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: loading
                                  ? Row(
                                      key: const ValueKey('loading'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        SizedBox(width: 10),
                                        Text('Tunggu…'),
                                      ],
                                    )
                                  : Row(
                                      key: const ValueKey('text'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.login_rounded),
                                        SizedBox(width: 8),
                                        Text('Masuk'),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Link Daftar
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          icon: Icon(Icons.person_add_alt_1_outlined, color: primary),
                          label: Text(
                            'Daftar Karyawan',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Footer kecil
                        Center(
                          child: Text(
                            '© ${DateTime.now().year} — Sistem Absensi',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.blueGrey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
