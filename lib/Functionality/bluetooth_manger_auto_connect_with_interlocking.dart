// Final
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class BluetoothManager {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<List<ScanResult>> scanSubscription;
  final StreamController<List<ScanResult>> _scanResultsController = StreamController<List<ScanResult>>.broadcast();
  BluetoothDevice? _connectedDevice;

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

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      print("Connected to ${device.name}");
    } catch (e) {
      print("Error connecting to ${device.name}: $e");
    }
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