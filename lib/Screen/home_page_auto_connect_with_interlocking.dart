// Final
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_scan_example/Functionality/bluetooth_manger_auto_connect_with_interlocking.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  List<ScanResult> scanResults = [];
  bool isConnecting = false;
  bool isConnected = false;

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
        
        // Automatically connect if the target device is found
        if (scanResults.isNotEmpty && isConnecting) {
          bluetoothManager.connectToDevice(scanResults.first.device).then((_) {
            setState(() {
              isConnected = true;
              isConnecting = false;
            });
          }).catchError((error) {
            print("Error connecting: $error");
            setState(() {
              isConnecting = false;
            });
          });
        }
      });
    });
  }

  void connectToDevice() {
    if (isConnecting || isConnected) return;

    setState(() {
      isConnecting = true;
      scanResults.clear(); // Clear previous scan results
    });

    bluetoothManager.startScan();

    // Automatically stop scanning after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (isConnecting) {
        setState(() {
          isConnecting = false;
        });
        bluetoothManager.stopScan();
      }
    });
  }

  void disconnectFromDevice() {
    if (!isConnected) return;

    bluetoothManager.disconnectFromDevice().then((_) {
      setState(() {
        isConnected = false;
        scanResults.clear(); // Clear scan results upon disconnection
      });
    }).catchError((error) {
      print("Error disconnecting: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Connect"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (isConnecting || isConnected) ? null : connectToDevice, // Disable if connecting or connected
                  child: Text("Connect"),
                ),
                ElevatedButton(
                  onPressed: isConnected ? disconnectFromDevice : null, // Disable if not connected
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
                    if (!isConnected) {
                      bluetoothManager.connectToDevice(result.device).then((_) {
                        setState(() {
                          isConnected = true;
                        });
                      }).catchError((error) {
                        print("Error connecting: $error");
                      });
                    }
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
    if (isConnecting) {
      bluetoothManager.stopScan();
    }
    bluetoothManager.dispose();
    super.dispose();
  }
}




