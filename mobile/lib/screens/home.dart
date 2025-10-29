import 'dart:async';
import 'dart:ui' as ui; // untuk efek blur (glass)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api.dart';
import '../services/session.dart';
import 'absen_camera.dart';
import 'face_enroll.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _clock;
  String now = '';
  bool busy = false;

  Map<String, dynamic>? profile;

  // status absen hari ini
  bool checkedIn = false;
  bool checkedOut = false;
  String? jamMasuk; // "HH:mm:ss" (TIME)
  String? jamPulang; // "HH:mm:ss" (TIME)

  // riwayat
  List<dynamic> history = [];
  bool historyLoading = false;

  bool get hasFace => (profile?['foto_wajah'] ?? '').toString().isNotEmpty;
  String get employeeName => (profile?['nama'] ?? '').toString();

  // ===== THEME: Palet biru modern =====
  static const _blueDark = Color(0xFF0B1224);
  static const _blue900 = Color(0xFF0F172A);
  static const _blue800 = Color(0xFF0B2257);
  static const _blue700 = Color(0xFF1D4ED8);
  static const _blue500 = Color(0xFF3B82F6);
  static const _blue300 = Color(0xFF93C5FD);
  static const _glass = Colors.white24;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        now = DateFormat('EEE, dd MMM yyyy — HH:mm:ss').format(DateTime.now());
      });
    });
    _refreshAll();
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadMe(), _loadTodayStatus(), _loadHistory()]);
  }

  Future<void> _guard401(Map r) async {
    if ((r['status'] ?? 200) == 401) {
      await Session.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _loadMe() async {
    final r = await Api.get('/karyawan/me.php', auth: true);
    if (!mounted) return;
    await _guard401(r);
    setState(() {
      profile = (r['data'] ?? {}) as Map<String, dynamic>;
    });
  }

  Future<void> _loadTodayStatus() async {
    final r = await Api.get('/absen/status_today.php', auth: true);
    if (!mounted) return;
    if ((r['status'] ?? 200) == 401) {
      await _guard401(r);
      return;
    }

    final d = (r['data'] ?? {}) as Map<String, dynamic>;
    setState(() {
      checkedIn = d['checked_in'] == true;
      checkedOut = d['checked_out'] == true;
      jamMasuk = (d['jam_masuk'] as String?)?.trim();
      jamPulang = (d['jam_pulang'] as String?)?.trim();
    });
  }

  Future<void> _openAbsen(String endpoint, String title) async {
    if (!hasFace) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan daftarkan wajah dulu.')),
      );
      return;
    }
    setState(() => busy = true);
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AbsenCameraScreen(endpoint: endpoint, title: title),
      ),
    );
    setState(() => busy = false);

    if (res is Map && mounted) {
      final ok = res['ok'] == true;
      final msg = (res['message'] ?? (ok ? 'Berhasil' : 'Gagal')).toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      if (ok) {
        await _refreshAll(); // status & history ikut refresh
      }
    }
  }

  Future<void> _goEnroll() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FaceEnrollScreen()),
    );
    await _loadMe();
    if (res != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajah tersimpan. Anda bisa absen.')),
      );
    }
  }

  Future<void> _loadHistory() async {
    setState(() => historyLoading = true);
    final r = await Api.get('/absen/history.php', auth: true);
    if (!mounted) return;
    if ((r['status'] ?? 200) == 401) {
      await _guard401(r);
      return;
    }
    final list = (r['data'] as List?) ?? [];
    setState(() {
      history = list;
      historyLoading = false;
    });
  }

  // ====== Helper UI ======
  Widget _background({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue900, _blue800, _blue700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Ornamen lingkaran blur
          Positioned(
            top: -80,
            left: -40,
            child: _blurCircle(220, _blue500.withOpacity(.25)),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _blurCircle(180, _blue300.withOpacity(.25)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          color: color,
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  ButtonStyle _filledBlue({bool tonal = false}) {
    return FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      backgroundColor: tonal ? Colors.white.withOpacity(.1) : _blue500,
      foregroundColor: tonal ? Colors.white : Colors.white,
      disabledBackgroundColor: Colors.white.withOpacity(.06),
      disabledForegroundColor: Colors.white.withOpacity(.4),
    );
  }

  TextStyle _title(BuildContext ctx) =>
      Theme.of(ctx).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          );

  TextStyle _label(BuildContext ctx) =>
      Theme.of(ctx).textTheme.bodyMedium!.copyWith(
            color: Colors.white.withOpacity(.85),
          );

  @override
  Widget build(BuildContext context) {
    final name = employeeName.isNotEmpty ? employeeName : '—';

    String? faceUrl;
    final facePath = (profile?['foto_wajah'] ?? '').toString();
    if (facePath.isNotEmpty) {
      faceUrl = '${Api.base}/$facePath';
    }

    // aturan enable/disable (tetap sama, hanya UI yang berubah)
    final canCheckIn = hasFace && !busy && !checkedIn;
    final canCheckOut = hasFace && !busy && checkedIn && !checkedOut;

    String fmtTimeShort(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '-';
      try {
        final dt = DateFormat('HH:mm:ss').parse(timeStr);
        return DateFormat('HH:mm').format(dt);
      } catch (_) {
        try {
          final dt = DateTime.parse(timeStr.replaceFirst(' ', 'T'));
          return DateFormat('HH:mm').format(dt);
        } catch (_) {
          return timeStr;
        }
      }
    }

    String fmtDate(String dateStr) {
      try {
        final d = DateTime.parse(dateStr);
        return DateFormat('EEE, dd MMM yyyy', 'id_ID').format(d);
      } catch (_) {
        return dateStr;
      }
    }

    Color statusColor(String s) {
      switch (s) {
        case 'hadir':
          return const Color(0xFF22C55E); // green-500
        case 'terlambat':
          return const Color(0xFFF59E0B); // amber-500
        case 'izin':
          return const Color(0xFF38BDF8); // sky-400
        case 'sakit':
          return const Color(0xFFA78BFA); // violet-400
        default:
          return Colors.white70;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 64,
        title: const Text('Beranda', style: TextStyle(fontWeight: FontWeight.w800)),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_blue800, _blue700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _background(
        child: RefreshIndicator(
          color: _blue500,
          backgroundColor: Colors.white,
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header profile + jam (glass)
              _glassCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_blue500, _blue300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: _blueDark.withOpacity(.6),
                        backgroundImage: (faceUrl != null) ? NetworkImage(faceUrl) : null,
                        child: (faceUrl == null)
                            ? const Icon(Icons.person, size: 36, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(now, style: _label(context)),
                          const SizedBox(height: 6),
                          Text('Halo, $name', style: _title(context)),
                          if ((profile?['jabatan'] ?? '').toString().isNotEmpty)
                            Text(
                              profile!['jabatan'],
                              style: _label(context).copyWith(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Banner daftar wajah bila belum ada
              if (!hasFace)
                _glassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: _blue300),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Wajah belum terdaftar. Daftarkan untuk mengaktifkan absen.',
                          style: _label(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: _filledBlue(),
                        onPressed: _goEnroll,
                        icon: const Icon(Icons.face),
                        label: const Text('Daftarkan'),
                      ),
                    ],
                  ),
                ),

              // Kartu status hari ini
              const SizedBox(height: 12),
              _glassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: _label(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.login, size: 18, color: _blue300),
                              const SizedBox(width: 6),
                              Text('Masuk: ${fmtTimeShort(jamMasuk)}'),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.logout, size: 18, color: _blue300),
                              const SizedBox(width: 6),
                              Text('Pulang: ${fmtTimeShort(jamPulang)}'),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusDot(
                          text: checkedIn ? 'Sudah Masuk' : 'Belum Masuk',
                          ok: checkedIn,
                        ),
                        const SizedBox(height: 6),
                        _StatusDot(
                          text: checkedOut ? 'Sudah Pulang' : 'Belum Pulang',
                          ok: checkedOut,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tombol absen
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: _filledBlue(),
                      onPressed: canCheckIn
                          ? () => _openAbsen('/absen/checkin.php', 'Absen Masuk')
                          : null,
                      icon: const Icon(Icons.login),
                      label: const Text('Absen Masuk'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: _filledBlue(tonal: true),
                      onPressed: canCheckOut
                          ? () => _openAbsen('/absen/checkout.php', 'Absen Pulang')
                          : null,
                      icon: const Icon(Icons.logout),
                      label: const Text('Absen Pulang'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // RIWAYAT
              Text('Riwayat',
                  style: _title(context).copyWith(fontSize: 18)),
              const SizedBox(height: 8),

              if (historyLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: _blue300),
                  ),
                )
              else if (history.isEmpty)
                _glassCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('Belum ada riwayat', style: _label(context)),
                    ),
                  ),
                )
              else
                ...history.map((row) {
                  final tgl = (row['tanggal'] ?? '').toString();
                  final ms = (row['jam_masuk'] ?? '').toString();
                  final ps = (row['jam_pulang'] ?? '').toString();
                  final st = (row['status_absen'] ?? '').toString();
                  final fm = (row['foto_masuk'] ?? '').toString();
                  final fp = (row['foto_pulang'] ?? '').toString();

                  String? fotoMasukUrl = fm.isNotEmpty ? '${Api.base}/$fm' : null;
                  String? fotoPulangUrl = fp.isNotEmpty ? '${Api.base}/$fp' : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _glassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor(st).withOpacity(.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: statusColor(st).withOpacity(.35)),
                            ),
                            child: Text(
                              st.isEmpty ? '-' : st,
                              style: TextStyle(
                                color: statusColor(st),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Detail
                          Expanded(
                            child: DefaultTextStyle(
                              style: _label(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fmtDate(tgl),
                                      style: _label(context).copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      )),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.login, size: 16, color: _blue300),
                                      const SizedBox(width: 6),
                                      Text('Masuk: ${fmtTimeShort(ms)}'),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.logout, size: 16, color: _blue300),
                                      const SizedBox(width: 6),
                                      Text('Pulang: ${fmtTimeShort(ps)}'),
                                    ],
                                  ),
                                  if (fotoMasukUrl != null || fotoPulangUrl != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (fotoMasukUrl != null)
                                          _Thumb(url: fotoMasukUrl, label: 'Masuk'),
                                        if (fotoMasukUrl != null && fotoPulangUrl != null)
                                          const SizedBox(width: 8),
                                        if (fotoPulangUrl != null)
                                          _Thumb(url: fotoPulangUrl, label: 'Pulang'),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 24),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await Session.clear();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String text;
  final bool ok;
  const _StatusDot({required this.text, required this.ok});
  @override
  Widget build(BuildContext context) {
    final color = ok ? const Color(0xFF22C55E) : Colors.white54;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(.9))),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final String label;
  const _Thumb({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                width: 70,
                height: 70,
                color: Colors.white10,
                child: const Icon(Icons.broken_image, size: 20, color: Colors.white70),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
