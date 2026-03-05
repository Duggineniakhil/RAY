import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reelify/core/theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController _controller;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _scanned = true;
    final value = barcode!.rawValue!;

    // Expected format: reelify://profile/{userId}
    if (value.startsWith('reelify://profile/')) {
      final userId = value.replaceFirst('reelify://profile/', '');
      context.go('/home/profile/$userId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unknown QR code: $value')),
      );
      setState(() => _scanned = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan Creator QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay with scanbox
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corners
                  ...List.generate(4, (i) {
                    return Positioned(
                      top: i < 2 ? 0 : null,
                      bottom: i >= 2 ? 0 : null,
                      left: i.isEven ? 0 : null,
                      right: i.isOdd ? 0 : null,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border(
                            top: i < 2
                                ? const BorderSide(
                                    color: Colors.white, width: 3)
                                : BorderSide.none,
                            bottom: i >= 2
                                ? const BorderSide(
                                    color: Colors.white, width: 3)
                                : BorderSide.none,
                            left: i.isEven
                                ? const BorderSide(
                                    color: Colors.white, width: 3)
                                : BorderSide.none,
                            right: i.isOdd
                                ? const BorderSide(
                                    color: Colors.white, width: 3)
                                : BorderSide.none,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Point camera at creator\'s QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
