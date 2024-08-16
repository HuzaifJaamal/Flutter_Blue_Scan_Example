import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_scan_example/Functionality/bluetooth_manager_scan_with_connect.dart';


class MyHomePage2 extends StatefulWidget {
  @override
  _MyHomePage2State createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    bluetoothManager.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });
  }

  void startScan() {
    if (isScanning) return;

    setState(() {
      isScanning = true;
    });

    bluetoothManager.startScan();

    // Automatically stop scanning after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (isScanning) {
        stopScan();
      }
    });
  }

  void stopScan() {
    if (!isScanning) return;

    setState(() {
      isScanning = false;
      scanResults.clear(); // Clear the scan results
    });

    bluetoothManager.stopScan();
  }

  void connectToDevice() {
    final deviceAddress = 'B5:F3:53:F0:AD:1D';
    final deviceName = 'Arduino Analog Sensor';
    bluetoothManager.connectToDevice(deviceAddress, deviceName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Scan"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: startScan,
                  child: Text("Scan"),
                ),
                ElevatedButton(
                  onPressed: stopScan,
                  child: Text("Stop"),
                ),
                ElevatedButton(
                  onPressed: connectToDevice,
                  child: Text("Connect"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final result = scanResults[index];
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : "Unnamed Device"),
                  subtitle: Text(result.device.id.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (isScanning) {
      stopScan();
    }
    bluetoothManager.dispose();
    super.dispose();
  }
}