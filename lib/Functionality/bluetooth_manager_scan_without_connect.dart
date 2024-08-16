import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class BluetoothManager {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<List<ScanResult>> scanSubscription;
  final StreamController<List<ScanResult>> _scanResultsController = StreamController<List<ScanResult>>.broadcast();

  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    scanSubscription = flutterBlue.scanResults.listen((results) {
      _scanResultsController.add(results);
    });
  }

  void stopScan() {
    flutterBlue.stopScan();
    scanSubscription.cancel();
  }

  void dispose() {
    _scanResultsController.close();
  }
}