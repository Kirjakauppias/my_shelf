import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.ean13],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _hasHandledBarcode = false;

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  void _handleBarcodeCapture(BarcodeCapture capture) {
    if (_hasHandledBarcode) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;

      if (rawValue == null) {
        continue;
      }

      final normalizedValue = rawValue.replaceAll(RegExp(r'[^0-9]'), '');

      if (!_isValidBookIsbn13(normalizedValue)) {
        continue;
      }

      _hasHandledBarcode = true;
      unawaited(_scannerController.stop());

      Navigator.of(context).pop(normalizedValue);
      return;
    }
  }

  /// Tarkistaa, että tunnus näyttää kirjan ISBN-13-tunnukselta.
  ///
  /// ISBN-13 alkaa tavallisesti 978- tai 979-etuliitteellä.
  /// Lisäksi tarkistetaan viimeinen tarkistusnumero.
  bool _isValidBookIsbn13(String value) {
    if (!RegExp(r'^(978|979)\d{10}$').hasMatch(value)) {
      return false;
    }

    var sum = 0;

    for (var index = 0; index < 12; index++) {
      final digit = int.parse(value[index]);
      final multiplier = index.isEven ? 1 : 3;

      sum += digit * multiplier;
    }

    final expectedCheckDigit = (10 - (sum % 10)) % 10;
    final actualCheckDigit = int.parse(value[12]);

    return expectedCheckDigit == actualCheckDigit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Skannaa kirja'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Taskulamppu',
            onPressed: () {
              unawaited(_scannerController.toggleTorch());
            },
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
          IconButton(
            tooltip: 'Vaihda kameraa',
            onPressed: () {
              unawaited(_scannerController.switchCamera());
            },
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcodeCapture,
          ),
          const _ScannerOverlay(),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          const Expanded(child: ColoredBox(color: Color(0x66000000))),
          Row(
            children: [
              const Expanded(
                child: SizedBox(
                  height: 180,
                  child: ColoredBox(color: Color(0x66000000)),
                ),
              ),
              Container(
                width: 310,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const Expanded(
                child: SizedBox(
                  height: 180,
                  child: ColoredBox(color: Color(0x66000000)),
                ),
              ),
            ],
          ),
          const Expanded(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text(
                    'Kohdista kirjan ISBN-viivakoodi kehykseen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
