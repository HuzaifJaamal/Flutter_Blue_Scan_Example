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

  Future<void> connectToDevice(String deviceAddress, String deviceName) async {
    // Stop scanning to avoid conflicts
    stopScan();

    // Discover devices
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.id.toString() == deviceAddress && result.device.name == deviceName) {
          // Connect to the device
          result.device.connect().then((connection) {
            print("Connected to $deviceName");
          }).catchError((error) {
            print("Error connecting to $deviceName: $error");
          });
          break;
        }
      }
    });

    // Start scanning again to ensure we find the device
    startScan();
  }

  void dispose() {
    _scanResultsController.close();
  }
}