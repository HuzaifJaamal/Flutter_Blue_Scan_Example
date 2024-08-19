import 'package:flutter/material.dart';
import 'package:flutter_blue_scan_example/Screen/home_page_auto_connect_with_interlocking_services_and_characteristic_and_read_data.dart';
// import 'package:flutter_blue_scan_example/Screen/home_page_auto_connect_with_interlocking_services_and_characteristic.dart';
// import 'package:flutter_blue_scan_example/Screen/home_page_scan_interlocking_with_disconnect.dart';
// import 'package:flutter_blue_scan_example/Screen/home_page_scan_with_connect%20_and_disconnect_btn.dart';
// import 'package:flutter_blue_scan_example/Screen/home_page_scan_with_connect_devise.dart';
// import 'package:flutter_blue_scan_example/Screen/home_page_auto_connect_with_interlocking.dart';
import 'package:flutter_blue_scan_example/home_page.dart';
// import 'package:flutter_blue_scan_example/Screen/home_page_scan_without_connect_devise.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth Scan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
      // MyHomePage(),
      // MyHomePage1(),
      // MyHomePage2(),
      // MyHomePage3(),
      // MyHomePage4(),
      // MyHomePage5(),
      MyHomePage6(),
      // MyHomePage7(),
    );
  }
}