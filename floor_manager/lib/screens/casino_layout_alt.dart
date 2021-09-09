import 'dart:developer';

import 'package:floor_manager/paints/table.dart';
import 'package:floor_manager/screens/table_screen.dart';
import 'package:flutter/material.dart';
import 'table_screen.dart';
import 'dart:convert';
import 'dart:math' show pi;
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'table_screen_alt.dart';

class CasinoLayOutAlt extends StatefulWidget {
  const CasinoLayOutAlt({Key key}) : super(key: key);

  @override
  _CasinoLayOutAltState createState() => _CasinoLayOutAltState();
}

class _CasinoLayOutAltState extends State<CasinoLayOutAlt> {
  // List _tables = [];
  List tables = [];

  String game;
  String tableType;
  final List tableTypes = ['Main Table', 'Regular Table'];
  final List games = ['NLH 5/10', 'NLH 2/4', 'PLO 5/10', 'PLO 10/10'];

  void openTable(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('game', game)
      ..set('opened', true)
      ..set('table_type', tableType);

    await table.save();
  }

  int getplayersnum(var table) {
    int x = 0;
    if (table['seat_1'] != '') {
      x++;
    }
    if (table['seat_2'] != '') {
      x++;
    }

    if (table['seat_3'] != '') {
      x++;
    }
    if (table['seat_4'] != '') {
      x++;
    }
    if (table['seat_5'] != '') {
      x++;
    }
    if (table['seat_6'] != '') {
      x++;
    }
    if (table['seat_7'] != '') {
      x++;
    }
    if (table['seat_8'] != '') {
      x++;
    }
    if (table['seat_9'] != '') {
      x++;
    }
    if (table['seat_10'] != '') {
      x++;
    }
    return x;
  }

  DateTime dateTodaySt;
  DateTime dateTodayEn;
  DateTime now = DateTime.now();
  var users;

  void openTableButton(bool opened, String tableId, var table) {
    if (opened == false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Open table'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Text('Table type:  '),
                        StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return DropdownButton<String>(
                            value: (tableType) ?? null,
                            items: tableTypes.map(
                              (tableType) {
                                return DropdownMenuItem<String>(
                                  value: tableType,
                                  child: Text(tableType),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(
                                () {
                                  tableType = value;
                                },
                              );
                            },
                          );
                        })
                      ],
                    ),
                    Row(
                      children: [
                        Text('Game:  '),
                        StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return DropdownButton<String>(
                            value: (game) ?? null,
                            items: games.map(
                              (game) {
                                return DropdownMenuItem<String>(
                                  value: game,
                                  child: Text(game),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                game = value;
                              });
                            },
                          );
                        })
                      ],
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.green[800]),
                child: Text("Submit"),
                onPressed: () {
                  setState(() {
                    table['game'] = game;
                    table['table_type'] = tableType;
                  });
                  openTable(tableId);
                  Navigator.pop(context);

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TableScreenAlt(tableData: table);
                  }));
                },
              )
            ],
          );
        },
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TableScreenAlt(tableData: table);
      }));
    }
  }

  var color;
  dynamic checkColor(
    var table,
  ) {
    if (table['opened'] == true) {
      if (table['game'] == 'NLH 2/4') {
        setState(() {
          color = Colors.green[300];
        });
      }
      if (table['game'] == 'NLH 5/10') {
        setState(() {
          color = Colors.green[800];
        });
      }
      if (table['game'] == 'PLO 5/10') {
        setState(() {
          color = Colors.red[300];
        });
      }
      if (table['game'] == 'PLO 10/10') {
        setState(() {
          color = Colors.red[800];
        });
      }
    } else {
      setState(() {
        color = Colors.grey[700];
      });
    }
    return color;
  }

  checkTables() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('Tables'));

    var response = await queryPost.query();

    if (response.success) {
      setState(
        () {
          tables = response.results;
        },
      );

      ;
    } else {
      print(response.error);
    }
  }

  liveQuery() async {
    final LiveQuery liveQuery = LiveQuery();

    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('Tables'));

    var response = await queryPost.query();

    if (response.success) {
      setState(
        () {
          tables = response.results;
        },
      );
    } else {
      print(response.error);
    }

    Subscription subscription = await liveQuery.client.subscribe(queryPost);

    subscription.on(LiveQueryEvent.create, (value) async {
      print('*** CREATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      if (mounted) {
        checkTables();
      }
    });

    subscription.on(LiveQueryEvent.update, (value) async {
      print('*** UPDATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      if (mounted) {
        checkTables();
      }
    });

    subscription.on(LiveQueryEvent.enter, (value) async {
      print('*** ENTER ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      if (mounted) {
        checkTables();
      }
    });

    subscription.on(LiveQueryEvent.leave, (value) async {
      print('*** LEAVE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      if (mounted) {
        checkTables();
      }
    });

    subscription.on(LiveQueryEvent.delete, (value) async {
      print('*** DELETE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      if (mounted) {
        checkTables();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //  this.readJson();
    liveQuery();
  }

  /* Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/layouts/tables.json');
    final data = await json.decode(response);
    setState(() {
      tables = data["tables"];
      log(tables.toString());
    });
  }*/

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
            child: tables.length > 0
                ? Stack(
                    children: <Widget>[
                      for (var table in tables)
                        Positioned(
                          top: table["y"],
                          left: table["x"],
                          child: Transform.rotate(
                            angle: table["angle"] * pi / 180,
                            child: GestureDetector(
                              onTap: () async {
                                await openTableButton(
                                    table['opened'], table['objectId'], table);
                                //      Navigator.pop(context);
                              },
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: table["table_num"],
                                    child: CustomPaint(
                                      size: Size(tableWidth,
                                          (tableWidth * 1).toDouble()),
                                      painter: TablePainter(
                                          color: checkColor(
                                        table,
                                      )),
                                    ),
                                  ),
                                  Center(
                                      child: Text(
                                    'Table :' +
                                        table['table_num'].toString() +
                                        '  ' +
                                        table['game'] +
                                        '  ' +
                                        table['table_type'] +
                                        '  ' +
                                        getplayersnum(table).toString() +
                                        "/" +
                                        '10',
                                    style: TextStyle(fontSize: 20),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : CircularProgressIndicator()),
      ),
    );
  }
}
