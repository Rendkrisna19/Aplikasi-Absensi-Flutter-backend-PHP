import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:camera/camera.dart' as cam;

import '../services/api.dart';
import 'login.dart';

class FaceEnrollScreen extends StatefulWidget {
  const FaceEnrollScreen({super.key});
  @override
  State<FaceEnrollScreen> createState() => _FaceEnrollScreenState();
}

class _FaceEnrollScreenState extends State<FaceEnrollScreen> {
  cam.CameraController? _controller;
  List<cam.CameraDescription> _cameras = [];
  int _index = 0;
  bool _busy = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _cameras = await cam.availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _err = 'Kamera tidak tersedia');
        return;
      }
      final frontIdx = _cameras.indexWhere(
        (c) => c.lensDirection == cam.CameraLensDirection.front,
      );
      _index = frontIdx >= 0 ? frontIdx : 0;
      await _start();
    } catch (e) {
      setState(() => _err = 'Gagal inisialisasi kamera: $e');
    }
  }

  Future<void> _start() async {
    await _controller?.dispose();
    _controller = cam.CameraController(
      _cameras[_index],
      cam.ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: cam.ImageFormatGroup.jpeg,
    );
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      setState(() => _err = 'Gagal membuka kamera: $e');
    }
  }

  Future<void> _switchCam() async {
    if (_cameras.length <= 1) return;
    _index = (_index + 1) % _cameras.length;
    await _start();
  }

  double _rotationFor(DeviceOrientation? o) {
    switch (o) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return math.pi / 2;
      case DeviceOrientation.portraitDown:
        return math.pi;
      case DeviceOrientation.landscapeRight:
        return -math.pi / 2;
      default:
        return 0;
    }
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final x = await c.takePicture();
      final b64 = base64Encode(await File(x.path).readAsBytes());

      final r = await Api.post('/karyawan/enroll_face.php', {
        'image_base64': 'data:image/jpeg;base64,$b64',
      }, auth: true);

      // DEBUG: tampilkan status & body mentah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'enroll: ${r['status']} • ${r['error'] ?? r['message'] ?? 'ok'}',
          ),
        ),
      );

      if ((r['status'] ?? 200) == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi berakhir. Silakan login ulang.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }

      if (r['path'] != null) {
        Navigator.pop(context, r); // sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(r['error']?.toString() ?? 'Gagal menyimpan wajah'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ambil foto: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Wajah (Mock)'),
        actions: [
          if (_cameras.length > 1)
            IconButton(
              onPressed: _switchCam,
              icon: const Icon(Icons.cameraswitch),
            ),
        ],
      ),
      body: _err != null
          ? Center(child: Text(_err!))
          : (c == null || !c.value.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, box) {
                      final rot = _rotationFor(c.value.previewPauseOrientation);
                      Widget preview = Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateZ(rot),
                        child: cam.CameraPreview(c),
                      );
                      if (c.description.lensDirection ==
                          cam.CameraLensDirection.front) {
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
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _capture,
                      child: Text(
                        _busy ? 'Menyimpan...' : 'Ambil Foto & Simpan',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
