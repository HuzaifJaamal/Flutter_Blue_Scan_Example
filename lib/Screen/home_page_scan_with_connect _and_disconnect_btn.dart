import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_scan_example/Functionality/bluetooth_manager_scan_with_connect_and_disconnect_btn.dart';


class MyHomePage3 extends StatefulWidget {
  @override
  _MyHomePage3State createState() => _MyHomePage3State();
}

class _MyHomePage3State extends State<MyHomePage3> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  final String targetDeviceAddress = 'B5:F3:53:F0:AD:1D';
  final String targetDeviceName = 'Arduino Analog Sensor';

  @override
  void initState() {
    super.initState();
    bluetoothManager.scanResults.listen((results) {
      setState(() {
        // Filter scan results to show only the target device
        scanResults = results.where((result) =>
          result.device.id.toString() == targetDeviceAddress &&
          result.device.name == targetDeviceName
        ).toList();
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
    bluetoothManager.connectToDevice(targetDeviceAddress, targetDeviceName);
  }

  void disconnectFromDevice() {
    bluetoothManager.disconnectFromDevice();
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
            child: Column(
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
                ElevatedButton(
                  onPressed: disconnectFromDevice,
                  child: Text("Disconnect"),
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