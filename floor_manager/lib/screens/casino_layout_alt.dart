import 'dart:developer';

import 'package:floor_manager/paints/table.dart';
import 'package:floor_manager/screens/table_screen.dart';
import 'package:flutter/material.dart';
import 'table_screen.dart';
import 'dart:convert';
import 'dart:math' show pi;
import 'package:flutter/services.dart';

import 'table_screen_alt.dart';

class CasinoLayOutAlt extends StatefulWidget {
  const CasinoLayOutAlt({Key key}) : super(key: key);

  @override
  _CasinoLayOutAltState createState() => _CasinoLayOutAltState();
}

class _CasinoLayOutAltState extends State<CasinoLayOutAlt> {
  List _tables = [];

  @override
  void initState() {
    super.initState();
    this.readJson();
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/layouts/tables.json');
    final data = await json.decode(response);
    setState(() {
      _tables = data["tables"];
      log(_tables.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    var tableWidth = 0.0;
    if (orientation == Orientation.landscape) {
      tableWidth = MediaQuery.of(context).size.height / 3;
    } else {
      tableWidth = MediaQuery.of(context).size.width / 3;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: Text('Layout'),
        ),
        body: Center(
          child: _tables.length > 0
              ? Stack(
                  children: <Widget>[
                    for (var table in _tables)
                      Positioned(
                        top: table["y"],
                        left: table["x"],
                        child: Transform.rotate(
                          angle: table["angle"] * pi / 180,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TableScreenAlt(tableData: table);
                              }));
                            },
                            child: Hero(
                              tag: table["name"],
                              child: CustomPaint(
                                size: Size(
                                    tableWidth, (tableWidth * 1).toDouble()),
                                painter: TablePainter(color: Colors.green[800]),
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                )
              : Container(child: Text("No Tables")),
        ),
      ),
    );
  }
}
