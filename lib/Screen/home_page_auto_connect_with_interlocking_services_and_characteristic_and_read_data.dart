import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

import 'package:flutter_blue_scan_example/Functionality/bluetooth_manager_auto_connect_with_interlocking_services_and_characteristic_and_read_data.dart';

class MyHomePage6 extends StatefulWidget {
  @override
  _MyHomePage6State createState() => _MyHomePage6State();
}

class _MyHomePage6State extends State<MyHomePage6> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  List<ScanResult> scanResults = [];
  bool isConnecting = false;
  bool isConnected = false;
  BluetoothCharacteristic? targetCharacteristic;
  String? characteristicValue;
  bool isReading = false;
  Timer? readTimer;

  final String targetDeviceAddress = 'B5:F3:53:F0:AD:1D';
  final String targetDeviceName = 'Arduino Analog Sensor';
  final String targetServiceUUID = '0000180c-0000-1000-8000-00805f9b34fb';
  final String targetCharacteristicUUID = '00002a5b-0000-1000-8000-00805f9b34fb';

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
          _connectToDevice(scanResults.first.device);
        }
      });
    });
  }

  void _connectToDevice(BluetoothDevice device) {
    bluetoothManager.connectToDevice(device).then((_) {
      setState(() {
        isConnected = true;
        isConnecting = false;
      });
      _discoverAndSetTargetCharacteristic(); // Auto-discover service and characteristic after connecting
    }).catchError((error) {
      print("Error connecting: $error");
      setState(() {
        isConnecting = false;
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
        targetCharacteristic = null; // Clear the target characteristic
        characteristicValue = null; // Clear the characteristic value
        isReading = false; // Reset the reading flag
      });
      _stopReadTimer(); // Stop the timer on disconnection
    }).catchError((error) {
      print("Error disconnecting: $error");
    });
  }

  void _discoverAndSetTargetCharacteristic() async {
    List<BluetoothService> services = await bluetoothManager.discoverServices();
    
    for (BluetoothService service in services) {
      if (service.uuid.toString() == targetServiceUUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == targetCharacteristicUUID) {
            setState(() {
              targetCharacteristic = characteristic;
            });
            _startReadTimer();  // Start periodic reads automatically
            break;
          }
        }
      }
    }
  }

  void _readCharacteristic() async {
    if (targetCharacteristic != null && !isReading) {
      setState(() {
        isReading = true; // Set the reading flag to true
      });

      try {
        var value = await targetCharacteristic!.read();
        setState(() {
          characteristicValue = value.map((byte) => byte.toRadixString(16)).join();
        });
        print("Read value: $characteristicValue");
      } catch (e) {
        print("Error reading characteristic: $e");
      } finally {
        setState(() {
          isReading = false; // Reset the reading flag after the operation
        });
      }
    }
  }

  void _startReadTimer() {
    _stopReadTimer();  // Ensure any existing timer is stopped
    readTimer = Timer.periodic(Duration(microseconds: 1), (timer) {
      _readCharacteristic();
    });
  }

  void _stopReadTimer() {
    readTimer?.cancel();
    readTimer = null;
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
                      _connectToDevice(result.device); // Auto-connect when tapping on the device
                    }
                  },
                );
              },
            ),
          ),
          if (targetCharacteristic != null && characteristicValue != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Read Characteristic Value: $characteristicValue"),
            ),
          ]
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (isConnecting) {
      bluetoothManager.stopScan();
    }
    _stopReadTimer();  // Ensure the timer is stopped when the screen is disposed
    bluetoothManager.dispose();
    super.dispose();
  }
}
