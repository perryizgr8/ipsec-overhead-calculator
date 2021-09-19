import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        primarySwatch: Colors.lightBlue,
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
  var originalPktSize = 0;
  var greEnabled = false;
  var tunnelKeyEnabled = false;
  var natEnabled = false;
  // mode 0 = transport
  // mode 1 = tunnel
  var ipsecMode = 'Transport';
  var chosenEspValue = 'AES128 + SHA1';
  var tableRows = [];
  num totalSize = 0;
  num espIv = 0;
  num payload = 0;
  num ipsecIpHdr = 0;
  num greIpHdr = 0;
  num overhead = 0;
  num overheadPc = 0;

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
      body: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            padding: EdgeInsets.all(16.0),
            childAspectRatio: 3.0 / 1.8,
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
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            keyboardType: TextInputType.number,
                            onChanged: onPktSizeChanged,
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
                                value: 'Transport',
                                groupValue: ipsecMode,
                                onChanged: onModeChanged,
                              ),
                              Text('Tunnel'),
                              Radio(
                                value: 'Tunnel',
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
                                  print("enc = $chosenEspValue");
                                  repopulate();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Card(
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
                          'Output packet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Table(
                          //defaultColumnWidth: FixedColumnWidth(200.0),
                          columnWidths: {
                            0: FixedColumnWidth(200.0),
                            1: FixedColumnWidth(200.0),
                            2: FixedColumnWidth(75.0),
                          },
                          border: TableBorder.all(
                              color: Colors.black38,
                              style: BorderStyle.solid,
                              width: 1),
                          children: [
                            TableRow(children: [
                              TableCell(
                                child: Text(
                                  'Packet group',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  'Fields',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  'Bytes',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                            for (var row in tableRows)
                              TableRow(
                                  children: [
                                    TableCell(
                                      child: Text(
                                        row['group'] as String,
                                        style: TextStyle(
                                          color: getTextColor(row['group']),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        row['fields'] as String,
                                        style: TextStyle(
                                          color: getTextColor(row['group']),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Text(
                                        row['bytes'] as String,
                                        style: TextStyle(
                                          color: getTextColor(row['group']),
                                        ),
                                      ),
                                    ),
                                  ],
                                  decoration: BoxDecoration(
                                    color: getRowColor(row['group']),
                                  )),
                          ],
                        ),
                        Text(
                          'Total IPsec packet size is $totalSize bytes.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total overhead is $overhead bytes ($overheadPc%).',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onPktSizeChanged(var pktSize) {
    print("original pkt size = $pktSize");
    originalPktSize = int.parse(pktSize);
    repopulate();
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
    print("gre = $greEnabled");
    repopulate();
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
    print("tunnel key = $tunnelKeyEnabled");
    repopulate();
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
    print("nat = $natEnabled");
    repopulate();
  }

  void onModeChanged(var value) {
    setState(() {
      ipsecMode = value;
    });
    print("ipsec mode = $ipsecMode");
    repopulate();
  }

  void repopulate() {
    setState(() {
      print(
          'preparing list $originalPktSize $greEnabled $tunnelKeyEnabled $natEnabled $ipsecMode $chosenEspValue');
      clearEverything();
      if (originalPktSize >= 28) {
        if (ipsecMode == 'Transport' && greEnabled == false) {
          transportWithoutGre();
        } else if (ipsecMode == 'Transport' && greEnabled == true) {
          transportWithGre();
        } else if (ipsecMode == 'Tunnel' && greEnabled == false) {
          tunnelWithoutGre();
        } else if (ipsecMode == 'Tunnel' && greEnabled == true) {
          tunnelWithGre();
        }
      }
      overhead = totalSize - originalPktSize;
      overheadPc = 100 * (overhead / originalPktSize);
    });
  }

  num calculatePadding() {
    num pad4 = get4Pad();
    num pad16 = get16Pad();
    if (chosenEspValue.contains('GCM')) {
      // consider only 4pad
      return pad4;
    } else {
      // consider max of 4pad and 16pad
      return max(pad4, pad16);
    }
  }

  num get4Pad() {
    // ESP header + IV + GRE IP header + GRE header + GRE key + IPsec IP header + Payload + Trailer(2 bytes)
    num espHeader = 8;
    num greHeader = greEnabled ? 4 : 0;
    num greTunnelKey = tunnelKeyEnabled ? 4 : 0;
    num trailerPadlenNhdr = 2;
    num size = espHeader +
        espIv +
        greIpHdr +
        greHeader +
        greTunnelKey +
        ipsecIpHdr +
        payload +
        trailerPadlenNhdr;
    num pad = (4 - (size % 4)) % 4;
    print('4pad size=$size pad=$pad');
    return pad;
  }

  num get16Pad() {
    // IPsec IP header + GRE IP header + GRE header + GRE key + Payload + Trailer
    num greHeader = greEnabled ? 4 : 0;
    num greTunnelKey = tunnelKeyEnabled ? 4 : 0;
    num trailerPadlenNhdr = 2;
    num size = ipsecIpHdr +
        greIpHdr +
        greHeader +
        greTunnelKey +
        payload +
        trailerPadlenNhdr;
    num pad = (16 - (size % 16)) % 16;
    print('16pad size=$size pad=$pad');
    return pad;
  }

  void transportWithoutGre() {
    // Original IP header
    tableRows.add(
        {'group': 'Original packet', 'fields': 'IPv4 header', 'bytes': '20'});
    totalSize += 20;

    if (natEnabled == true) {
      // NAT UDP header
      tableRows.add(
          {'group': 'NAT traversal', 'fields': 'UDP header', 'bytes': '8'});
      totalSize += 8;
    }

    // ESP header
    tableRows.add({'group': 'ESP', 'fields': 'ESP header', 'bytes': '8'});
    totalSize += 8;

    // ESP IV
    if (chosenEspValue.contains('GCM')) {
      espIv = 8;
    } else {
      espIv = 16;
    }
    tableRows.add({'group': 'ESP', 'fields': 'ESP IV', 'bytes': '$espIv'});
    totalSize += espIv;

    // Original payload
    payload = originalPktSize - 20;
    tableRows.add(
        {'group': 'Original packet', 'fields': 'Payload', 'bytes': '$payload'});
    totalSize += payload;

    // ESP trailer
    // Padding
    num padding = calculatePadding();
    tableRows.add(
        {'group': 'ESP trailer', 'fields': 'Padding', 'bytes': '$padding'});
    totalSize += padding;
    // Pad length and next header
    tableRows.add({
      'group': 'ESP trailer',
      'fields': 'pad length + next header',
      'bytes': '2'
    });
    totalSize += 2;
    // ESP ICV
    var espIcv;
    if (chosenEspValue.contains('GCM')) {
      espIcv = 16;
    } else if (chosenEspValue.contains('SHA1')) {
      espIcv = 12;
    } else {
      espIcv = 16;
    }
    tableRows
        .add({'group': 'ESP trailer', 'fields': 'ESP ICV', 'bytes': '$espIcv'});
    totalSize += espIcv;
  }

  void transportWithGre() {
    // New IPsec IP header
    tableRows.add(
        {'group': 'New IPsec header', 'fields': 'IPv4 header', 'bytes': '20'});
    totalSize += 20;
    ipsecIpHdr = 20;

    if (natEnabled == true) {
      // NAT UDP header
      tableRows.add(
          {'group': 'NAT traversal', 'fields': 'UDP header', 'bytes': '8'});
      totalSize += 8;
    }

    // ESP header
    tableRows.add({'group': 'ESP', 'fields': 'ESP header', 'bytes': '8'});
    totalSize += 8;

    // ESP IV
    if (chosenEspValue.contains('GCM')) {
      espIv = 8;
    } else {
      espIv = 16;
    }
    tableRows.add({'group': 'ESP', 'fields': 'ESP IV', 'bytes': '$espIv'});
    totalSize += espIv;

    // GRE header
    tableRows.add({'group': 'GRE', 'fields': 'GRE Header', 'bytes': '4'});
    totalSize += 4;

    // GRE tunnel key
    if (tunnelKeyEnabled == true) {
      tableRows.add({'group': 'GRE', 'fields': 'GRE tunnel key', 'bytes': '4'});
      totalSize += 4;
    }

    // Original IP header
    tableRows.add(
        {'group': 'Original packet', 'fields': 'IPv4 header', 'bytes': '20'});
    totalSize += 20;

    // Original payload
    payload = originalPktSize - 20;
    tableRows.add(
        {'group': 'Original packet', 'fields': 'Payload', 'bytes': '$payload'});
    totalSize += payload;

    // ESP trailer
    // Padding
    num padding = calculatePadding();
    tableRows.add(
        {'group': 'ESP trailer', 'fields': 'Padding', 'bytes': '$padding'});
    totalSize += padding;
    // Pad length and next header
    tableRows.add({
      'group': 'ESP trailer',
      'fields': 'pad length + next header',
      'bytes': '2'
    });
    totalSize += 2;
    // ESP ICV
    var espIcv;
    if (chosenEspValue.contains('GCM')) {
      espIcv = 16;
    } else if (chosenEspValue.contains('SHA1')) {
      espIcv = 12;
    } else {
      espIcv = 16;
    }
    tableRows
        .add({'group': 'ESP trailer', 'fields': 'ESP ICV', 'bytes': '$espIcv'});
    totalSize += espIcv;
  }

  void clearEverything() {
    tableRows.clear();
    totalSize = 0;
    espIv = 0;
    payload = 0;
    ipsecIpHdr = 0;
    greIpHdr = 0;
  }

  void tunnelWithoutGre() {
    // New IPsec IP header
    tableRows.add(
        {'group': 'New IPsec header', 'fields': 'IPv4 header', 'bytes': '20'});
    totalSize += 20;
    ipsecIpHdr = 20;

    if (natEnabled == true) {
      // NAT UDP header
      tableRows.add(
          {'group': 'NAT traversal', 'fields': 'UDP header', 'bytes': '8'});
      totalSize += 8;
    }

    // ESP header
    tableRows.add({'group': 'ESP', 'fields': 'ESP header', 'bytes': '8'});
    totalSize += 8;

    // ESP IV
    if (chosenEspValue.contains('GCM')) {
      espIv = 8;
    } else {
      espIv = 16;
    }
    tableRows.add({'group': 'ESP', 'fields': 'ESP IV', 'bytes': '$espIv'});
    totalSize += espIv;

    // Original IP header
    tableRows.add(
        {'group': 'Original packet', 'fields': 'IPv4 header', 'bytes': '20'});
    totalSize += 20;

    // Original payload
    payload = originalPktSize - 20;
    tableRows.add(
        {'group': 'Original packet', 'fields': 'Payload', 'bytes': '$payload'});
    totalSize += payload;

    // ESP trailer
    // Padding
    num padding = calculatePadding();
    tableRows.add(
        {'group': 'ESP trailer', 'fields': 'Padding', 'bytes': '$padding'});
    totalSize += padding;
    // Pad length and next header
    tableRows.add({
      'group': 'ESP trailer',
      'fields': 'pad length + next header',
      'bytes': '2'
    });
    totalSize += 2;
    // ESP ICV
    var espIcv;
    if (chosenEspValue.contains('GCM')) {
      espIcv = 16;
    } else if (chosenEspValue.contains('SHA1')) {
      espIcv = 12;
    } else {
      espIcv = 16;
    }
    tableRows
        .add({'group': 'ESP trailer', 'fields': 'ESP ICV', 'bytes': '$espIcv'});
    totalSize += espIcv;
  }

  void tunnelWithGre() {
    // New IPsec IP header
    tableRows.add(
        {'group': 'New IPsec header', 'fields': 'IPv4 header', 'bytes': '20'});
    totalSize += 20;
    ipsecIpHdr = 20;

    if (natEnabled == true) {
      // NAT UDP header
      tableRows.add(
          {'group': 'NAT traversal', 'fields': 'UDP header', 'bytes': '8'});
      totalSize += 8;
    }

    // ESP header
    tableRows.add({'group': 'ESP', 'fields': 'ESP header', 'bytes': '8'});
    totalSize += 8;

    // ESP IV
    if (chosenEspValue.contains('GCM')) {
      espIv = 8;
    } else {
      espIv = 16;
    }
    tableRows.add({'group': 'ESP', 'fields': 'ESP IV', 'bytes': '$espIv'});
    totalSize += espIv;

    // New GRE IP header
    tableRows.add({'group': 'GRE', 'fields': 'New IP Header', 'bytes': '20'});
    totalSize += 20;
    greIpHdr = 20;

    // GRE header
    tableRows.add({'group': 'GRE', 'fields': 'GRE Header', 'bytes': '4'});
    totalSize += 4;

    // GRE tunnel key
    if (tunnelKeyEnabled == true) {
      tableRows.add({'group': 'GRE', 'fields': 'GRE tunnel key', 'bytes': '4'});
      totalSize += 4;
    }

    // Original IP header
    tableRows.add(
        {'group': 'Original packet', 'fields': 'IPv4 header', 'bytes': '20'});
    totalSize += 20;

    // Original payload
    payload = originalPktSize - 20;
    tableRows.add(
        {'group': 'Original packet', 'fields': 'Payload', 'bytes': '$payload'});
    totalSize += payload;

    // ESP trailer
    // Padding
    num padding = calculatePadding();
    tableRows.add(
        {'group': 'ESP trailer', 'fields': 'Padding', 'bytes': '$padding'});
    totalSize += padding;
    // Pad length and next header
    tableRows.add({
      'group': 'ESP trailer',
      'fields': 'pad length + next header',
      'bytes': '2'
    });
    totalSize += 2;
    // ESP ICV
    var espIcv;
    if (chosenEspValue.contains('GCM')) {
      espIcv = 16;
    } else if (chosenEspValue.contains('SHA1')) {
      espIcv = 12;
    } else {
      espIcv = 16;
    }
    tableRows
        .add({'group': 'ESP trailer', 'fields': 'ESP ICV', 'bytes': '$espIcv'});
    totalSize += espIcv;
  }

  getTextColor(group) {
    return getColor('text', group);
  }

  getRowColor(group) {
    return getColor('row', group);
  }

  getColor(String s, group) {
    switch (group) {
      case 'Original packet':
        if (s == 'row') {
          return Color(0xFFFEF9EF);
        } else if (s == 'text') {
          return Color(0xFF000000);
        }
        break;
      case 'NAT traversal':
        if (s == 'row') {
          return Color(0xFF227C9D);
        } else if (s == 'text') {
          return Color(0xFFFFFFFF);
        }
        break;
      case 'ESP':
        if (s == 'row') {
          return Color(0xFFFFCB77);
        } else if (s == 'text') {
          return Color(0xFF000000);
        }
        break;
      case 'ESP trailer':
        if (s == 'row') {
          return Color(0xFFFFCB77);
        } else if (s == 'text') {
          return Color(0xFF000000);
        }
        break;
      case 'New IPsec header':
        if (s == 'row') {
          return Color(0xFF17C3B2);
        } else if (s == 'text') {
          return Color(0xFFFFFFFF);
        }
        break;
      case 'GRE':
        if (s == 'row') {
          return Color(0xFFFE6D73);
        } else if (s == 'text') {
          return Color(0xFFFFFFFF);
        }
        break;
      default:
        if (s == 'row') {
          return Color(0xFFFFFFFF);
        } else if (s == 'text') {
          return Color(0xFF000000);
        }
        break;
    }
  }
}
