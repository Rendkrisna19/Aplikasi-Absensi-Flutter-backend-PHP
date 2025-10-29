import 'package:flutter/material.dart';
import '../services/api.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List items = [];
  bool loading = true;
  Future<void> _load() async {
    final r = await Api.get('/absen/history.php', auth: true);
    setState(() {
      items = (r['data'] ?? []) as List;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absen')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final x = items[i] as Map;
                return ListTile(
                  title: Text('${x['tanggal']} (${x['status_absen']})'),
                  subtitle: Text(
                    'Masuk: ${x['jam_masuk'] ?? '-'} • Pulang: ${x['jam_pulang'] ?? '-'}',
                  ),
                );
              },
            ),
    );
  }
}
