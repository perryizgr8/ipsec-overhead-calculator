import 'dart:developer';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPsec Overhead Calculator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'IPsec Overhead Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var greEnabled = false;
  var tunnelKeyEnabled = false;
  var natEnabled = false;
  // mode 0 = transport
  // mode 1 = tunnel
  var ipsecMode = 0;
  var chosenEspValue = 'AES128 + SHA1';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0,
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Unencrypted packet info',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Unencrypted IP packet size in bytes',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'GRE settings',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Text('GRE over IPsec'),
                          Switch(value: greEnabled, onChanged: onGreToggle),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Text('Tunnel keying'),
                          SizedBox(
                            width: 9.0,
                          ),
                          Switch(
                            value: tunnelKeyEnabled,
                            onChanged: onTunnelKeyToggle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'IPsec settings',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Text('NAT traversal'),
                          Switch(value: natEnabled, onChanged: onNatToggle),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Text('IPsec mode:'),
                          SizedBox(
                            width: 9.0,
                          ),
                          Text('Transport'),
                          Radio(
                            value: 0,
                            groupValue: ipsecMode,
                            onChanged: onModeChanged,
                          ),
                          Text('Tunnel'),
                          Radio(
                            value: 1,
                            groupValue: ipsecMode,
                            onChanged: onModeChanged,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Column(
                        children: [
                          Text('ESP encryption and integrity'),
                          DropdownButton<String>(
                            value: chosenEspValue,
                            items: <String>[
                              'AES128 + SHA1',
                              'AES128 + SHA256',
                              'AES256 + SHA1',
                              'AES256 + SHA256',
                              'AES128 GCM64',
                              'AES128 GCM128',
                              'AES256 GCM128',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (var value) {
                              setState(() {
                                chosenEspValue = value as String;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onGreToggle(bool value) {
    if (greEnabled == false) {
      setState(() {
        greEnabled = true;
      });
    } else {
      setState(() {
        greEnabled = false;
      });
    }
  }

  void onTunnelKeyToggle(bool value) {
    if (tunnelKeyEnabled == false) {
      setState(() {
        tunnelKeyEnabled = true;
      });
    } else {
      setState(() {
        tunnelKeyEnabled = false;
      });
    }
  }

  void onNatToggle(bool value) {
    if (natEnabled == false) {
      setState(() {
        natEnabled = true;
      });
    } else {
      setState(() {
        natEnabled = false;
      });
    }
  }

  void onModeChanged(var value) {
    setState(() {
      ipsecMode = value;
    });
  }
}
