import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class BluetoothManager {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<List<ScanResult>> scanSubscription;
  final StreamController<List<ScanResult>> _scanResultsController = StreamController<List<ScanResult>>.broadcast();
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;

  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  Future<void> startScan() async {
    if (_isScanning) {
      return; // Prevent starting a new scan if one is already in progress
    }

    _isScanning = true;
    flutterBlue.startScan(timeout: Duration(seconds: 1));

    scanSubscription = flutterBlue.scanResults.listen((results) {
      _scanResultsController.add(results);
    });

    // Stop scan after a timeout
    await Future.delayed(Duration(seconds: 5));
    stopScan();
  }

  void stopScan() {
    if (!_isScanning) return;

    flutterBlue.stopScan();
    scanSubscription.cancel();
    _isScanning = false;
  }

  Future<void> connectToDevice(String deviceAddress, String deviceName) async {
    stopScan(); // Ensure the scan is stopped before connecting

    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.id.toString() == deviceAddress && result.device.name == deviceName) {
          result.device.connect().then((connection) {
            _connectedDevice = result.device;
            print("Connected to $deviceName");
          }).catchError((error) {
            print("Error connecting to $deviceName: $error");
          });
          break;
        }
      }
    });

    // startScan(); // Start scanning again to ensure the device is found
  }

  Future<void> disconnectFromDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        print("Disconnected from ${_connectedDevice!.name}");
        _connectedDevice = null;
      } catch (e) {
        print("Error disconnecting: $e");
      }
    } else {
      print("No device connected");
    }
  }

  void dispose() {
    _scanResultsController.close();
  }
}