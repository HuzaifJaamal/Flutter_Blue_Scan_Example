import 'dart:async';

import 'package:fl_chart/fl_chart.dart';  // Import the fl_chart package
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../Functionality/bluetooth_manager_with_read_and_plot_graph.dart';



class MyHomePage7 extends StatefulWidget {
  @override
  _MyHomePage7State createState() => _MyHomePage7State();
}

class _MyHomePage7State extends State<MyHomePage7> {
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

  List<FlSpot> dataPoints = [];  // List to store data points for the graph
  int xValue = 0;  // X-axis value to simulate time progression

  @override
  void initState() {
    super.initState();
    bluetoothManager.scanResults.listen((results) {
      setState(() {
        scanResults = results.where((result) =>
          result.device.id.toString() == targetDeviceAddress &&
          result.device.name == targetDeviceName
        ).toList();
        
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
        dataPoints.clear();  // Clear the graph data
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
        String hexValue = value.map((byte) => byte.toRadixString(16)).join();
        double numericValue = int.parse(hexValue, radix: 16).toDouble();  // Convert hex to numeric value

        setState(() {
          characteristicValue = hexValue;
          xValue += 1;  // Simulate time progression on x-axis
          dataPoints.add(FlSpot(xValue.toDouble(), numericValue));  // Add new data point
          if (dataPoints.length > 20) {  // Limit the number of points displayed on the graph
            dataPoints.removeAt(0);
          }
        });
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
    readTimer = Timer.periodic(Duration(seconds: 5), (timer) {
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
          Flexible(
            flex: 1,
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
          if (dataPoints.isNotEmpty) // Display graph only if there are data points
            Flexible(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: LineChart(
                  LineChartData(
                    /* minX: 0,
                    maxX: dataPoints.isNotEmpty ? dataPoints.last.x : 0,
                    minY: dataPoints.isNotEmpty ? dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) : 0,
                    maxY: dataPoints.isNotEmpty ? dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) : 0, */
                    minX: dataPoints.isNotEmpty ? dataPoints.first.x : 0,
                    maxX: dataPoints.isNotEmpty ? dataPoints.last.x + 1 : 0, // Add buffer on the right
                    minY: dataPoints.isNotEmpty ? dataPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1 : 0, // Add buffer below
                    maxY: dataPoints.isNotEmpty ? dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1 : 0, // Add buffer above
                    lineBarsData: [
                      LineChartBarData(
                        spots: dataPoints,
                        // isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                        ),
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
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
    _stopReadTimer();  // Ensure the timer is stopped when the screen is disposed
    bluetoothManager.dispose();
    super.dispose();
  }
}