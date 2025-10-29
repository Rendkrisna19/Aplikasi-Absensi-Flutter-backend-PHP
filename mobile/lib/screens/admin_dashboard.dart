import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ PERBAIKAN: perlu untuk DateFormat
import '../services/api.dart';
import '../services/session.dart';
import 'login.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await Session.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ DESAIN: Terapkan tema biru muda di seluruh layar dashboard ini
    // Ini akan mengubah AppBar, TabBar, FilledButton, dan komponen lainnya
    // agar menggunakan Colors.lightBlue sebagai warna utama
    // dan putih sebagai warna teks di atasnya (onPrimary).
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.lightBlue,
          // Pastikan onPrimary (teks di atas AppBar/Button) kontras
          brightness: Brightness.dark,
        ).copyWith(
          // Anda bisa override warna sekunder jika perlu, misal:
          // secondary: Colors.lightBlueAccent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true, // ✅ DESAIN: Judul di tengah
          // ✅ PERBAIKAN: hubungkan ke _tab (tidak boleh const)
          bottom: TabBar(
            controller: _tab,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.people_alt), text: 'Karyawan'),
              Tab(icon: Icon(Icons.schedule), text: 'Jadwal'),
              Tab(icon: Icon(Icons.assignment), text: 'Laporan'),
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
            ],
          ),
          actions: [
            IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          ],
        ),
        // ✅ PERBAIKAN: hubungkan ke _tab (tidak boleh const)
        body: TabBarView(
          controller: _tab,
          children: const [
            _KaryawanTab(),
            _JadwalTab(),
            _LaporanTab(),
            _AdminTab()
          ],
        ),
      ),
    );
  }
}

/* ============================= KARYAWAN ============================= */

class _KaryawanTab extends StatefulWidget {
  const _KaryawanTab();
  @override
  State<_KaryawanTab> createState() => _KaryawanTabState();
}

class _KaryawanTabState extends State<_KaryawanTab> {
  List<dynamic> rows = [];
  bool loading = false;
  final q = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final keyword = q.text.trim();
    final uri = keyword.isEmpty
        ? '/admin/karyawan_list.php'
        : '/admin/karyawan_list.php?q=${Uri.encodeQueryComponent(keyword)}';
    final r = await Api.get(uri, auth: true);
    setState(() {
      rows = (r['data'] as List?) ?? [];
      loading = false;
    });
  }

  Future<void> _openCreate() async {
    final res = await showDialog(
      context: context,
      builder: (_) => const _KaryawanForm(),
    );
    if (res == true) _load();
  }

  Future<void> _openEdit(Map item) async {
    final res = await showDialog(
      context: context,
      builder: (_) => _KaryawanForm(editing: item),
    );
    if (res == true) _load();
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Hapus karyawan?'),
            content: const Text(
              'Data terkait (cred, jadwal, absensi) akan ikut terhapus (cascade).',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Hapus')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;

    final r = await Api.post(
        '/admin/karyawan_delete.php', {'id_karyawan': id},
        auth: true);
    final msg = r['message'] ?? r['error'] ?? 'OK';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: q,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cari nama/jabatan',
                  ),
                  onSubmitted: (_) => _load(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final r = rows[i] as Map;
                final id = int.tryParse('${r['id_karyawan'] ?? 0}') ?? 0;
                final nama = (r['nama'] ?? '-').toString();
                final jab = (r['jabatan'] ?? '-').toString();
                final stt = (r['status_aktif'] ?? '-').toString();

                return Card(
                  // ✅ DESAIN: Tambahkan radius agar lebih modern
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      // ✅ DESAIN: Sesuaikan warna avatar dengan tema biru
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      child: Text(
                        id > 0 ? id.toString() : '?',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    title: Text('$nama  (ID: $id)'),
                    subtitle: Text('$jab • $stt'),
                    trailing: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Badge kecil penanda ID (akan otomatis jadi biru muda)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(.10),
                            border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(.25)),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('ID: $id',
                              style: TextStyle(color: theme.colorScheme.primary)),
                        ),
                        IconButton(
                          onPressed: () => _openEdit(r),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Ubah',
                        ),
                        IconButton(
                          onPressed: () => _delete(id),
                          icon: const Icon(Icons.delete),
                          color: theme.colorScheme.error,
                          tooltip: 'Hapus',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KaryawanForm extends StatefulWidget {
  final Map? editing;
  const _KaryawanForm({this.editing});
  @override
  State<_KaryawanForm> createState() => _KaryawanFormState();
}

class _KaryawanFormState extends State<_KaryawanForm> {
  final nama = TextEditingController();
  final jabatan = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  String status = 'aktif';
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      nama.text = (e['nama'] ?? '').toString();
      jabatan.text = (e['jabatan'] ?? '').toString();
      status = (e['status_aktif'] ?? 'aktif').toString();
    }
  }

  @override
  void dispose() {
    nama.dispose();
    jabatan.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => saving = true);
    Map<String, dynamic> body;
    String url;
    if (widget.editing == null) {
      url = '/admin/karyawan_create.php';
      body = {
        'nama': nama.text.trim(),
        'jabatan': jabatan.text.trim(),
        'username': username.text.trim(),
        'password': password.text.trim(),
      };
    } else {
      url = '/admin/karyawan_update.php';
      body = {
        'id_karyawan': widget.editing!['id_karyawan'],
        'nama': nama.text.trim(),
        'jabatan': jabatan.text.trim(),
        'status_aktif': status,
      };
      if (username.text.isNotEmpty && password.text.isNotEmpty) {
        body['username'] = username.text.trim();
        body['password'] = password.text.trim();
      }
    }
    final r = await Api.post(url, body, auth: true);
    setState(() => saving = false);
    if (!mounted) return;
    final msg = r['message'] ?? r['error'] ?? 'OK';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if (r['error'] == null) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    final idText = isEdit ? 'ID: ${widget.editing!['id_karyawan']}' : null;

    return AlertDialog(
      title: Text(isEdit ? 'Ubah Karyawan' : 'Tambah Karyawan'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (idText != null) ...[
              Text(idText,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
            ],
            TextField(
                controller: nama,
                decoration: const InputDecoration(labelText: 'Nama')),
            const SizedBox(height: 8),
            TextField(
                controller: jabatan,
                decoration: const InputDecoration(labelText: 'Jabatan')),
            const SizedBox(height: 8),
            if (isEdit)
              DropdownButtonFormField(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'aktif', child: Text('aktif')),
                  DropdownMenuItem(value: 'non-aktif', child: Text('non-aktif')),
                ],
                onChanged: (v) => setState(() => status = v!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            if (!isEdit) ...[
              const SizedBox(height: 8),
              TextField(
                  controller: username,
                  decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 8),
              TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password')),
            ] else ...[
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Ganti Kredensial (opsional)'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                            controller: username,
                            decoration:
                                const InputDecoration(labelText: 'Username baru')),
                        const SizedBox(height: 8),
                        TextField(
                            controller: password,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: 'Password baru')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
        FilledButton(
            onPressed: saving ? null : _submit,
            child: Text(saving ? 'Menyimpan...' : 'Simpan')),
      ],
    );
  }
}

/* ============================= JADWAL ============================= */

class _JadwalTab extends StatefulWidget {
  const _JadwalTab();
  @override
  State<_JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<_JadwalTab> {
  final idController = TextEditingController();
  Map<String, dynamic>? jadwal;
  bool loading = false;

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  bool _isHms(String s) => RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(s);

  Future<void> _load() async {
    final id = int.tryParse(idController.text.trim()) ?? 0;
    if (id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan ID karyawan yang valid')),
      );
      return;
    }

    setState(() => loading = true);
    final r = await Api.get('/admin/jadwal_get.php?id_karyawan=$id', auth: true);
    if (!mounted) return;

    if ((r['status'] ?? 200) == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sesi admin berakhir. Silakan login ulang.')),
      );
      setState(() {
        loading = false;
        jadwal = null;
      });
      return;
    }

    setState(() {
      jadwal = (r['data'] ?? {}) as Map<String, dynamic>;
      loading = false;
    });

    if ((r['error'] ?? '') != '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r['error'].toString())),
      );
    }
  }

  Future<void> _edit() async {
    final id = int.tryParse(idController.text.trim()) ?? 0;
    if (id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan ID karyawan yang valid')),
      );
      return;
    }

    final jm = TextEditingController(
        text: (jadwal?['jam_masuk'] ?? '08:00:00').toString());
    final jp = TextEditingController(
        text: (jadwal?['jam_pulang'] ?? '17:00:00').toString());
    final tol = TextEditingController(
        text: (jadwal?['toleransi_menit'] ?? 15).toString());

    Future<void> pickTime(TextEditingController ctrl) async {
      final parts = ctrl.text.split(':');
      final init = TimeOfDay(
        hour: int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
      final picked = await showTimePicker(context: context, initialTime: init);
      if (picked != null) {
        // jam:mm:ss
        ctrl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      }
    }

    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Atur Jadwal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: jm,
                    readOnly: true,
                    onTap: () => pickTime(jm),
                    decoration: const InputDecoration(
                      labelText: 'Jam Masuk (HH:mm:ss)',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: jp,
                    readOnly: true,
                    onTap: () => pickTime(jp),
                    decoration: const InputDecoration(
                      labelText: 'Jam Pulang (HH:mm:ss)',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tol,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Toleransi (menit)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) {
      jm.dispose();
      jp.dispose();
      tol.dispose();
      return;
    }

    final jmText = jm.text.trim();
    final jpText = jp.text.trim();
    final tolVal = int.tryParse(tol.text.trim()) ?? 15;

    if (!_isHms(jmText) || !_isHms(jpText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format jam harus HH:mm:ss')),
      );
      jm.dispose();
      jp.dispose();
      tol.dispose();
      return;
    }

    final r = await Api.post('/admin/jadwal_set.php', {
      'id_karyawan': id,
      'jam_masuk': jmText,
      'jam_pulang': jpText,
      'toleransi_menit': tolVal,
    }, auth: true);

    jm.dispose();
    jp.dispose();
    tol.dispose();

    if (!mounted) return;
    final msg = r['message'] ?? r['error'] ?? 'OK';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if ((r['error'] ?? '') == '') {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = (jadwal != null && jadwal!.isNotEmpty);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID Karyawan',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  onSubmitted: (_) => _load(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.search),
                label: const Text('Cari'),
              ),
              const SizedBox(width: 8),
              // Tombol tambah/ubah selalu tersedia setelah isi ID,
              // jadi kita bisa bikin jadwal meski belum ada.
              FilledButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_calendar),
                label: Text(hasResult ? 'Ubah' : 'Tambah'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          if (loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),

          // Kartu ringkasan jadwal (jika ada)
          if (hasResult)
            Card(
              // ✅ DESAIN: Tambahkan radius agar lebih modern
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(
                  'Masuk: ${jadwal!['jam_masuk'] ?? '-'} • Pulang: ${jadwal!['jam_pulang'] ?? '-'}',
                ),
                subtitle: Text(
                  'Toleransi: ${(jadwal!['toleransi_menit'] ?? 15).toString()} menit',
                ),
                trailing: FilledButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Ubah'),
                ),
              ),
            )
          else
            Card(
              // ✅ DESAIN: Tambahkan radius agar lebih modern
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Belum ada jadwal untuk karyawan ini'),
                subtitle: const Text('Klik "Tambah" untuk membuat jadwal baru'),
                trailing: FilledButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ============================= LAPORAN ============================= */

class _LaporanTab extends StatefulWidget {
  const _LaporanTab();
  @override
  State<_LaporanTab> createState() => _LaporanTabState();
}

class _LaporanTabState extends State<_LaporanTab> {
  // ✅ PERBAIKAN: pastikan intl terimport dan controller yang dipakai dideklarasikan
  final from = TextEditingController(
    text: DateFormat('yyyy-MM-01').format(DateTime.now()), // awal bulan berjalan
  );
  final to = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final idK = TextEditingController(); // ✅ sebelumnya hilang, sekarang dideklarasikan

  // (Opsional) Jam cantik untuk header/UI saja
  final String prettyNow =
      DateFormat('EEE, dd MM yyyy - HH:mm:ss').format(DateTime.now());

  List<dynamic> rows = [];
  bool loading = false;

  @override
  void dispose() {
    from.dispose();
    to.dispose();
    idK.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final params = {
      'from': from.text.trim(),
      'to': to.text.trim(),
      if (idK.text.trim().isNotEmpty) 'id_karyawan': idK.text.trim(),
    };
    final qs = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final r = await Api.get('/admin/laporan_list.php?$qs', auth: true);
    setState(() {
      rows = (r['data'] as List?) ?? [];
      loading = false;
    });
  }

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return '-';
    try {
      // Contoh input: "08:00:00" -> "08:00"
      return DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(t));
    } catch (_) {
      return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: from,
                  decoration: const InputDecoration(
                    labelText: 'Dari (YYYY-MM-DD)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: to,
                  decoration: const InputDecoration(
                    labelText: 'Sampai (YYYY-MM-DD)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: idK,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID Karyawan (ops)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.search),
                label: const Text('Terapkan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final r = rows[i] as Map;
                return Card(
                  // ✅ DESAIN: Tambahkan radius agar lebih modern
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: Text(
                      '${r['tanggal']} • ${r['nama']} (${r['jabatan']})',
                    ),
                    subtitle: Text(
                      'Masuk: ${_fmtTime(r['jam_masuk'])}  •  Pulang: ${_fmtTime(r['jam_pulang'])}  •  Status: ${r['status_absen']}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/*================================= LAPORAN ABSENSI ==============class===============================*/

/* ============================= ADMIN USER ============================= */

class _AdminTab extends StatefulWidget {
  const _AdminTab();
  @override
  State<_AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends State<_AdminTab> {
  List<dynamic> rows = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final r = await Api.get('/admin/admin_list.php', auth: true);
    setState(() {
      rows = (r['data'] as List?) ?? [];
      loading = false;
    });
  }

  Future<void> _openCreate() async {
    final res = await showDialog(
      context: context,
      builder: (_) => const _AdminForm(),
    );
    if (res == true) _load();
  }

  Future<void> _openEdit(Map e) async {
    final res = await showDialog(
      context: context,
      builder: (_) => _AdminForm(editing: e),
    );
    if (res == true) _load();
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Hapus admin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;

    final r = await Api.post('/admin/admin_delete.php', {
      'id_admin': id,
    }, auth: true);
    final msg = r['message'] ?? r['error'] ?? 'OK';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Admin'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final r = rows[i] as Map;
                return Card(
                  // ✅ DESAIN: Tambahkan radius agar lebih modern
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: Text(r['nama_admin'] ?? '-'),
                    subtitle: Text('${r['username']} • ${r['email']}'),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        IconButton(
                          onPressed: () => _openEdit(r),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => _delete((r['id_admin'] ?? 0) as int),
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminForm extends StatefulWidget {
  final Map? editing;
  const _AdminForm({this.editing});
  @override
  State<_AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<_AdminForm> {
  final nama = TextEditingController();
  final user = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      nama.text = (widget.editing!['nama_admin'] ?? '').toString();
      user.text = (widget.editing!['username'] ?? '').toString();
      email.text = (widget.editing!['email'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    nama.dispose();
    user.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => saving = true);
    Map body;
    String url;
    if (widget.editing == null) {
      url = '/admin/admin_create.php';
      body = {
        'nama_admin': nama.text.trim(),
        'username': user.text.trim(),
        'password': pass.text.trim(),
        'email': email.text.trim(),
      };
    } else {
      url = '/admin/admin_update.php';
      body = {
        'id_admin': widget.editing!['id_admin'],
        'nama_admin': nama.text.trim(),
        'username': user.text.trim(),
        'email': email.text.trim(),
      };
      if (pass.text.trim().isNotEmpty) body['password'] = pass.text.trim();
    }
    final r = await Api.post(url, body, auth: true);
    setState(() => saving = false);
    if (!mounted) return;
    final msg = r['message'] ?? r['error'] ?? 'OK';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if (r['error'] == null) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editing == null ? 'Tambah Admin' : 'Ubah Admin'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nama,
              decoration: const InputDecoration(labelText: 'Nama Admin'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: user,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password ', // optional on edit
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: saving ? null : _submit,
          child: Text(saving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}