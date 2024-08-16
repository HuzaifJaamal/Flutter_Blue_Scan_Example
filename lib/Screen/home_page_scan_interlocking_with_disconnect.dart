import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../Functionality/bluetooth_manger_scan_interlocking_with_disconnect.dart';


class MyHomePage4 extends StatefulWidget {
  @override
  _MyHomePage4State createState() => _MyHomePage4State();
}

class _MyHomePage4State extends State<MyHomePage4> {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isScanning ? null : startScan, // Disable if scanning
                  child: Text("Scan"),
                ),
                ElevatedButton(
                  onPressed: isScanning ? stopScan : null, // Disable if not scanning
                  child: Text("Stop"),
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
                  onTap: () {
                    // Connect to the device on tap
                    bluetoothManager.connectToDevice(result.device);
                  },
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