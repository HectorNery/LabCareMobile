import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  final _debouncer = Debouncer(milliseconds: 2000); // Adjust the delay time here
  bool isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Scan result: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        setState(() {
          isProcessing = true;
          result = scanData;
        });
        _debouncer.run(() {
          _handleQRResult(result!.code);
          isProcessing = false;
        });
      }
    });
  }

  void _handleQRResult(String? qrCode) {
    if (qrCode == null) return;

    List<String> parts = qrCode.split(' ');
    String? idNumber;
    String? fullName;

    if (parts.length >= 5 && parts[1] == "PROFESOR" && parts[2] == "DE" && parts[3] == "ASIGNATURA") {
      idNumber = parts[0];
      fullName = parts.sublist(4).join(' ').split(' ')[0];
    } else if (parts.length >= 6 && parts[2].endsWith('.jpg') && parts[3].endsWith('.png') && parts.last == "PROFESOR" && parts[parts.length - 2] == "DE" && parts[parts.length - 3] == "TIEMPO" && parts[parts.length - 4] == "COMPLETO") {
      idNumber = parts[0];
      fullName = parts.sublist(4, parts.length - 4).join(' ').split(' ')[0];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code format not recognized')),
      );
      return;
    }

    // Detener la cámara
    controller!.pauseCamera();

    // Navegar a la siguiente pantalla
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessorDetailsScreen(idNumber: idNumber!, fullName: fullName!),
      ),
    ).then((_) {
      // Resumir la cámara después de volver de la pantalla de detalles
      controller!.resumeCamera();
    });
    }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class ProfessorDetailsScreen extends StatelessWidget {
  final String idNumber;
  final String fullName;

  const ProfessorDetailsScreen({super.key, required this.idNumber, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ID Number: $idNumber', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text('Full Name: $fullName', style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

/// Utility class for debouncing function calls
class Debouncer {
  final int milliseconds;
  VoidCallback? _callback;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback callback) {
    _callback = callback;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _callback!();
    });
  }
}
