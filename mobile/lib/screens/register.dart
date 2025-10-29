import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/session.dart';
import 'face_enroll.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nama = TextEditingController();
  final jabatan = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  Future<void> _submit() async {
    if (loading) return;
    setState(() => loading = true);

    // 1) Registrasi karyawan
    final r = await Api.post('/auth/register_karyawan.php', {
      'nama': nama.text.trim(),
      'jabatan': jabatan.text.trim(),
      'username': user.text.trim(),
      'password': pass.text.trim(),
    });

    if (!mounted) return;

    if (r['id_karyawan'] == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r['error']?.toString() ?? 'Gagal registrasi'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // 2) Auto-login karyawan
    final lg = await Api.post('/auth/login.php', {
      'username': user.text.trim(),
      'password': pass.text.trim(),
      'role': 'karyawan',
    });

    if (lg['token'] == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lg['error']?.toString() ?? 'Gagal login sesudah registrasi'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // Simpan token & role
    await Session.saveToken(lg['token'] as String, 'karyawan');

    // 3) Buka kamera untuk daftar wajah (mock)
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FaceEnrollScreen()),
    );

    // 4) Masuk ke Home (token sudah tersimpan)
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );

    // Info kecil
    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajah tersimpan. Anda bisa absen sekarang.')),
      );
    }

    setState(() => loading = false);
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
  Widget build(BuildContext ctx) {
    final primary = Colors.blue.shade700;
    final secondary = Colors.blue.shade400;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Registrasi Karyawan'),
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
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header / Avatar
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
                              child: Icon(Icons.person_add_alt_1_rounded,
                                  size: 38, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Buat Akun Karyawan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Isi data di bawah untuk melanjutkan',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.blueGrey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Nama
                      TextField(
                        controller: nama,
                        decoration: _fieldDecoration(
                          label: 'Nama',
                          icon: Icons.badge_outlined,
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 14),

                      // Jabatan
                      TextField(
                        controller: jabatan,
                        decoration: _fieldDecoration(
                          label: 'Jabatan',
                          icon: Icons.work_outline_rounded,
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 14),

                      // Username
                      TextField(
                        controller: user,
                        decoration: _fieldDecoration(
                          label: 'Username',
                          icon: Icons.person_outline,
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 14),

                      // Password
                      TextField(
                        controller: pass,
                        obscureText: true,
                        decoration: _fieldDecoration(
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                        ),
                        onSubmitted: (_) {
                          if (!loading) _submit();
                        },
                      ),

                      const SizedBox(height: 18),

                      // Tombol
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
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
                                      Text('Memproses...'),
                                    ],
                                  )
                                : Row(
                                    key: const ValueKey('text'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.arrow_forward_rounded),
                                      SizedBox(width: 8),
                                      Text('Daftar & Lanjutkan'),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

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
    );
  }
}
