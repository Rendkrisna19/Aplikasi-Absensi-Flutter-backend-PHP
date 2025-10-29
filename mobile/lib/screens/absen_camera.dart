import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;

import '../services/api.dart';

class AbsenCameraScreen extends StatefulWidget {
  final String endpoint; // '/absen/checkin.php' atau '/absen/checkout.php'
  final String title;    // judul appbar

  const AbsenCameraScreen({
    super.key,
    required this.endpoint,
    required this.title,
  });

  @override
  State<AbsenCameraScreen> createState() => _AbsenCameraScreenState();
}

class _AbsenCameraScreenState extends State<AbsenCameraScreen> {
  cam.CameraController? _controller;
  List<cam.CameraDescription> _cameras = [];
  bool _busy = false;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _cameras = await cam.availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamera tidak tersedia')),
        );
        Navigator.pop(context);
        return;
      }
      // pilih front camera jika ada
      var desc = _cameras.first;
      for (final c in _cameras) {
        if (c.lensDirection == cam.CameraLensDirection.front) {
          desc = c; break;
        }
      }
      _controller = cam.CameraController(
        desc,
        cam.ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: cam.ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});

      // Auto-capture setelah preview stabil 1200ms
      _autoTimer?.cancel();
      _autoTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) _captureAndSend();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka kamera: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  double _rotationFor(DeviceOrientation? o) {
    switch (o) {
      case DeviceOrientation.portraitUp: return 0;
      case DeviceOrientation.landscapeLeft: return math.pi / 2;
      case DeviceOrientation.portraitDown: return math.pi;
      case DeviceOrientation.landscapeRight: return -math.pi / 2;
      default: return 0;
    }
  }

  Future<void> _captureAndSend() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final x = await c.takePicture();
      final b64 = base64Encode(await File(x.path).readAsBytes());
      final r = await Api.post(
        widget.endpoint,
        {'image_base64': 'data:image/jpeg;base64,$b64'},
        auth: true,
      );
      if (!mounted) return;

      final ok = (r['status'] ?? 200) == 200 && (r['error'] == null);
      final msg = r['message'] ?? r['error'] ?? 'OK';
      Navigator.pop(context, {'ok': ok, 'message': msg});
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context, {'ok': false, 'message': 'Gagal mengirim absen: $e'});
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _busy ? null : _captureAndSend,
            icon: const Icon(Icons.camera),
            tooltip: 'Ambil Sekarang',
          ),
        ],
      ),
      body: (c == null || !c.value.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                // Preview dengan rotasi & mirror utk front cam
                LayoutBuilder(builder: (ctx, box) {
                  final rot = _rotationFor(c.value.previewPauseOrientation);
                  Widget preview = Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateZ(rot),
                    child: cam.CameraPreview(c),
                  );
                  if (c.description.lensDirection == cam.CameraLensDirection.front) {
                    preview = Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: preview,
                    );
                  }
                  final ar = c.value.aspectRatio;
                  final w = box.maxWidth;
                  final h = w / ar;
                  return Center(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(width: w, height: h, child: preview),
                    ),
                  );
                }),

                // Overlay sederhana (guideline wajah)
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                        border: Border.all(
                          color: Colors.white.withOpacity(.8), width: 2),
                        color: Colors.black.withOpacity(.08),
                      ),
                    ),
                  ),
                ),

                // Info status
                Positioned(
                  left: 16, right: 16, bottom: 24,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.45),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _busy ? 'Mengirim...' : 'Mendeteksi wajah… (otomatis ambil)',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: (c != null && c.value.isInitialized)
          ? FloatingActionButton.extended(
              onPressed: _busy ? null : _captureAndSend,
              label: Text(_busy ? 'Mengirim...' : 'Ambil & Kirim'),
              icon: const Icon(Icons.check),
            )
          : null,
    );
  }
}
