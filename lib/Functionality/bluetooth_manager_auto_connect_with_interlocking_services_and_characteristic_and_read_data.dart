import 'package:flutter_blue/flutter_blue.dart';

class BluetoothManager {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;

  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;

  Future<void> startScan() async {
    await flutterBlue.startScan(timeout: Duration(seconds: 5));
  }

  Future<void> stopScan() async {
    await flutterBlue.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    connectedDevice = device;
    await device.connect();
  }

  Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
    }
  }

  Future<List<BluetoothService>> discoverServices() async {
    if (connectedDevice != null) {
      return await connectedDevice!.discoverServices();
    }
    return [];
  }

  void dispose() {
    flutterBlue.stopScan();
  }
}
