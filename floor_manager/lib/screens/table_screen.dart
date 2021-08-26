import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:data_table_2/data_table_2.dart';
import '../components/responsive_text.dart';

class TablePage extends StatefulWidget {
  final int tableNum;

  const TablePage({Key key, @required this.tableNum}) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  ParseUser _authUser;
  var users = [];
  List st = ['Pending', 'Checked-In'];

  var tables = [];
  String table_ID;
  bool opened = false;
  final List opentableSeats = [
    'Seat-1',
    'Seat-2',
    'Seat-3',
    'Seat-4',
    'Seat-5',
    'Seat-6',
    'Seat-7'
  ];
  final List fulltableSeats = [
    'Seat-1',
    'Seat-2',
    'Seat-3',
    'Seat-4',
    'Seat-5',
    'Seat-6',
    'Seat-7'
  ];

  final List freetableSeats = [
    'Seat-1',
    'Seat-2',
    'Seat-3',
    'Seat-4',
    'Seat-5',
    'Seat-6',
    'Seat-7'
  ];

  void freeSeats() {
    setState(
      () {
        if (seat1player != '') {
          freetableSeats.remove('Seat-1');
        }
        if (seat2player != '') {
          freetableSeats.remove('Seat-2');
        }
        if (seat3player != '') {
          freetableSeats.remove('Seat-3');
        }
        if (seat4player != '') {
          freetableSeats.remove('Seat-4');
        }
        if (seat5player != '') {
          freetableSeats.remove('Seat-5');
        }
        if (seat6player != '') {
          freetableSeats.remove('Seat-6');
        }
        if (seat7player != '') {
          freetableSeats.remove('Seat-7');
        }
      },
    );
  }

  void openSeats() {
    setState(
      () {
        if (seat1player == '') {
          opentableSeats.remove('Seat-1');
        }
        if (seat2player == '') {
          opentableSeats.remove('Seat-2');
        }
        if (seat3player == '') {
          opentableSeats.remove('Seat-3');
        }
        if (seat4player == '') {
          opentableSeats.remove('Seat-4');
        }
        if (seat5player == '') {
          opentableSeats.remove('Seat-5');
        }
        if (seat6player == '') {
          opentableSeats.remove('Seat-6');
        }
        if (seat7player == '') {
          opentableSeats.remove('Seat-7');
        }
      },
    );
  }

  final List tableTypes = ['Main Table', 'Regular Table'];
  final List games = ['NLH 5/10', 'NLH 2/4', 'PLO 5/10', 'PLO 10/10'];
  String tableSeat;
  String game;
  String tableType;
  String seat1player;
  String seat2player;
  String seat3player;
  String seat4player;
  String seat5player;
  String seat6player;
  String seat7player;
  DateTime dateToday;
  DateTime now = DateTime.now();
  DateTime dateTodaySt;
  DateTime dateTodayEn;

  Widget wButton() {
    if (opened == true) {
      return RaisedButton(
        color: Colors.green[800],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Close Table",
            style: TextStyle(
                color: Colors.white,
                fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 16)),
          ),
        ),
        onPressed: () {
          closeTableButton();
        },
      );
    } else {
      return RaisedButton(
        onPressed: () {
          openTableButton();
        },
        disabledColor: Colors.grey,
        color: Colors.green[800],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Open Table",
            style: TextStyle(
                color: Colors.white,
                fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 16)),
          ),
        ),
      );
    }
  }

  void playersList() async {
    if (opened == true) {
      setState(() {
        dateTodaySt = DateTime(now.year, now.month, now.day, 9);
        dateTodayEn = DateTime(now.year, now.month, now.day, 14);
      });

      QueryBuilder<ParseObject> queryPost =
          QueryBuilder<ParseObject>(ParseObject('registrations'))
            //  ..whereContainedIn('status', st)
            ..includeObject(['username', 'Status'])
            ..whereEqualTo('game', game)
            ..whereGreaterThan('registration_time', dateTodaySt)
            ..whereLessThan(
                "registration_time", dateTodayEn.add(Duration(days: 1)));

      var response = await queryPost.query();
      if (mounted) {
        if (response.success) {
          setState(
            () {
              users = response.results;
              users.removeWhere((user) => user['Status']['state'] == 'Seated');
              users.removeWhere(
                  (user) => user['Status']['state'] == 'Cancelled');
            },
          );
          switchFavorite();
        } else {
          print(response.error);
        }
      }
    } else {
      null;
    }
  }

  void setSeat() async {
    if (opened == false) {
      var query = ParseObject('Tables')
        ..objectId = table_ID
        ..set('seat_1', '')
        ..set('seat_2', '')
        ..set('seat_3', '')
        ..set('seat_4', '')
        ..set('seat_5', '')
        ..set('seat_6', '')
        ..set('seat_7', '');

      await query.save();
    }
  }

  void switchFavorite() {
    for (var user in users)
      if (user['favorite'] == true) {
        user['favorite'] = '❤';
      } else {
        user['favorite'] = " ";
      }
  }

  Widget ifList() {
    if (users == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('No Players Available'),
      );
    } else {
      return DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 100,
        columns: [
          DataColumn2(
            label: Text('Player',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
            size: ColumnSize.L,
          ),
          DataColumn(
            label: Text('Game',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Favorite?',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Status',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
        ],
        rows: [
          for (var user in users)
            DataRow2(
              onTap: () {
                freeSeats();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Choose Seat:'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return DropdownButton<String>(
                                  value: (tableSeat) ?? null,
                                  items: freetableSeats.map(
                                    (tableSeat) {
                                      return DropdownMenuItem<String>(
                                        value: tableSeat,
                                        child: Text(tableSeat),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        tableSeat = value;
                                      },
                                    );
                                  },
                                );
                              })
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        RaisedButton(
                          color: Colors.green[800],
                          child: Text("Submit"),
                          onPressed: () {
                            switch (tableSeat) {
                              case 'Seat-1':
                                if (seat1player == '') {
                                  seatPlayerSeat1(
                                      table_ID,
                                      user['username']['Name'],
                                      user['objectId']);
                                  checkTable();
                                  tableState();
                                  Navigator.pop(context);
                                  setState(() {
                                    tableSeat = null;
                                  });

                                  break;
                                } else {
                                  seatTaken(context);
                                  break;
                                }
                                break;
                              case 'Seat-2':
                                if (seat2player == '') {
                                  seatPlayerSeat2(
                                      table_ID,
                                      user['username']['Name'],
                                      user['objectId']);
                                  checkTable();
                                  tableState();
                                  Navigator.pop(context);
                                  setState(() {
                                    tableSeat = null;
                                  });

                                  break;
                                } else {
                                  seatTaken(context);
                                  break;
                                }
                                break;

                              case 'Seat-3':
                                if (seat3player == '') {
                                  seatPlayerSeat3(
                                      table_ID,
                                      user['username']['Name'],
                                      user['objectId']);
                                  checkTable();
                                  tableState();
                                  Navigator.pop(context);
                                  setState(() {
                                    tableSeat = null;
                                  });

                                  break;
                                } else {
                                  seatTaken(context);
                                  break;
                                }
                                break;
                              case 'Seat-4':
                                if (seat4player == '') {
                                  seatPlayerSeat4(
                                      table_ID,
                                      user['username']['Name'],
                                      user['objectId']);
                                  checkTable();
                                  tableState();
                                  Navigator.pop(context);
                                  setState(() {
                                    tableSeat = null;
                                  });

                                  break;
                                } else {
                                  seatTaken(context);
                                  break;
                                }
                                break;
                              case 'Seat-5':
                                if (seat5player == '') {
                                  seatPlayerSeat5(
                                      table_ID,
                                      user['username']['Name'],
                                      user['objectId']);
                                  checkTable();
                                  tableState();
                                  Navigator.pop(context);
                                  setState(() {
                                    tableSeat = null;
                                  });

                                  break;
                                } else {
                                  seatTaken(context);
                                  break;
                                }
                                break;
                              case 'Seat-6':
                                if (seat6player == '') {
                                  seatPlayerSeat6(
                                      table_ID,
                                      user['username']['Name'],
                                      user['objectId']);
                                  checkTable();
                                  tableState();
                                  Navigator.pop(context);
                                  setState(() {
                                    tableSeat = null;
                                  });

                                  break;
                                } else {
                                  seatTaken(context);
                                  break;
                                }
                                break;
                              case 'Seat-7':
                                if (seat7player == '') {
                                  seatPlayerSeat7(
                                      table_ID,
                                      user['username']['Name'],
                                      user['objectId']);
                                  checkTable();
                                  tableState();
                                  Navigator.pop(context);
                                  setState(() {
                                    tableSeat = null;
                                  });

                                  break;
                                } else {
                                  seatTaken(context);
                                }
                                break;
                              case '---':
                                null;
                                break;
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              cells: [
                DataCell(
                  Text(user['username']['Name'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(user['game'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(user['favorite'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(user['Status']['state'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
              ],
            ),
        ],
      );
    }
  }

  void seatTaken(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                children: [
                  Text("Seat Already Taken"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  var seatedObj;
  getSeatedObj() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('States'))
          ..whereEqualTo('state', 'Seated');

    var response = await queryPost.query();
    for (var item in response.results) {
      setState(() {
        seatedObj = item;
      });
    }
  }

  void seatPlayerSeat1(String tableID, String userName, String userID) async {
    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('seat', 'Tabel ' + widget.tableNum.toString() + ' - Seat 1');

    await player.save();

    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_1', userName)
      ..set('Status', seatedObj);

    await table.save();
  }

  void openSeat1(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_1', '');

    await table.save();
  }

  void seatPlayerSeat2(String tableID, String userName, String userID) async {
    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('Status', seatedObj)
      ..set('seat', 'Tabel ' + widget.tableNum.toString() + ' - Seat 2');

    await player.save();

    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_2', userName);

    await table.save();
  }

  void openSeat2(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_2', '');

    await table.save();
  }

  void seatPlayerSeat3(String tableID, String userName, String userID) async {
    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('Status', seatedObj)
      ..set('seat', 'Tabel ' + widget.tableNum.toString() + ' - Seat 3');

    await player.save();

    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_3', userName);

    await table.save();
  }

  void openSeat3(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_3', '');

    await table.save();
  }

  void seatPlayerSeat4(String tableID, String userName, String userID) async {
    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('Status', seatedObj)
      ..set('seat', 'Tabel ' + widget.tableNum.toString() + ' - Seat 4');

    await player.save();

    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_4', userName);

    await table.save();
  }

  void openSeat4(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_4', '');

    await table.save();
  }

  void seatPlayerSeat5(String tableID, String userName, String userID) async {
    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('Status', seatedObj)
      ..set('seat', 'Tabel ' + widget.tableNum.toString() + ' - Seat 5');

    await player.save();

    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_5', userName);

    await table.save();
  }

  void openSeat5(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_5', '');

    await table.save();
  }

  void seatPlayerSeat6(String tableID, String userName, String userID) async {
    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('Status', seatedObj)
      ..set('seat', 'Tabel ' + widget.tableNum.toString() + ' - Seat 6');

    await player.save();

    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_6', userName);

    await table.save();
  }

  void openSeat6(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_6', '');

    await table.save();
  }

  void seatPlayerSeat7(String tableID, String userName, String userID) async {
    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('Status', seatedObj)
      ..set('seat', 'Tabel ' + widget.tableNum.toString() + ' - Seat 7');

    await player.save();

    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_7', userName);

    await table.save();
  }

  void openSeat7(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('seat_7', '');

    await table.save();
  }

  Widget tableState() {
    if (opened == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Table Type:  ',
              ),
              Text(
                tableType.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Game:  ',
              ),
              Text(
                game.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Seat 1:  ',
              ),
              Text(
                seat1player.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Seat 2:  ',
              ),
              Text(
                seat2player.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Seat 3:  ',
              ),
              Text(
                seat3player.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Seat 4:  ',
              ),
              Text(
                seat4player.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Seat 5:  ',
              ),
              Text(
                seat5player.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Seat 6:  ',
              ),
              Text(
                seat6player.toString(),
              )
            ],
          ),
          Row(
            children: [
              Text(
                'Seat 7:  ',
              ),
              Text(
                seat7player.toString(),
              )
            ],
          ),
        ],
      );
    } else {
      return Text('Open Table to start');
    }
  }

  void tableSettings() {
    if (opened == true) {
      openSeats();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Change Settings'),
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
                              setState(
                                () {
                                  game = value;
                                },
                              );
                            },
                          );
                        })
                      ],
                    ),
                    Row(
                      children: [
                        Text('Open Seat:  '),
                        StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return DropdownButton<String>(
                            value: (tableSeat) ?? null,
                            items: opentableSeats.map(
                              (tableSeat) {
                                return DropdownMenuItem<String>(
                                  value: tableSeat,
                                  child: Text(tableSeat),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(
                                () {
                                  tableSeat = value;
                                },
                              );
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
              RaisedButton(
                color: Colors.green[800],
                child: Text("Submit"),
                onPressed: () {
                  setState(
                    () {
                      changeTable(table_ID);
                      checkTable();
                      playersList();
                      switch (tableSeat) {
                        case 'Seat-1':
                          openSeat1(
                            table_ID,
                          );
                          break;
                        case 'Seat-2':
                          openSeat2(
                            table_ID,
                          );
                          break;
                        case 'Seat-3':
                          openSeat3(
                            table_ID,
                          );
                          break;
                        case 'Seat-4':
                          openSeat4(
                            table_ID,
                          );
                          break;
                        case 'Seat-5':
                          openSeat5(
                            table_ID,
                          );
                          break;
                        case 'Seat-6':
                          openSeat6(
                            table_ID,
                          );
                          break;
                        case 'Seat-7':
                          openSeat7(
                            table_ID,
                          );
                          break;
                      }
                    },
                  );
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      );
    } else {
      null;
    }
  }

  liveCheckTable() async {
    final LiveQuery liveQueryTable = LiveQuery();

    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('Tables'))
          ..whereEqualTo('table_num', widget.tableNum);

    var response = await queryPost.query();

    if (response.success) {
      if (mounted) {
        setState(
          () {
            tables = response.results;
            for (var table in tables) {
              opened = table['opened'];
              table_ID = table['objectId'];
            }
          },
        );
        setState(() {
          if (opened == true) {
            for (var table in tables) {
              game = table['game'];
              tableType = table['table_type'];
              seat1player = table['seat_1'];
              seat2player = table['seat_2'];
              seat3player = table['seat_3'];
              seat4player = table['seat_4'];
              seat5player = table['seat_5'];
              seat6player = table['seat_6'];
              seat7player = table['seat_7'];
            }
          } else {
            null;
          }
        });
      }
    } else {
      print(response.error);
    }

    await liveQueryTable.subscribe(queryPost);
    if (opened == true) {
      liveQuery();
    }

    liveQueryTable.on(LiveQueryEvent.create, (value) async {
      print('*** CREATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      var response = await queryPost.query();

      checkTable();
    });

    liveQueryTable.on(LiveQueryEvent.update, (value) async {
      print('*** UPDATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      var response = await queryPost.query();

      checkTable();
    });

    liveQueryTable.on(LiveQueryEvent.enter, (value) async {
      print('*** ENTER ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      var response = await queryPost.query();

      checkTable();
    });

    liveQueryTable.on(LiveQueryEvent.leave, (value) async {
      print('*** LEAVE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      var response = await queryPost.query();

      checkTable();
    });

    liveQueryTable.on(LiveQueryEvent.delete, (value) async {
      print('*** DELETE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      var response = await queryPost.query();

      checkTable();
    });
  }

  checkTable() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('Tables'))
          ..whereEqualTo('table_num', widget.tableNum);

    var response = await queryPost.query();

    if (response.success) {
      if (mounted) {
        setState(
          () {
            tables = response.results;
            for (var table in tables) {
              opened = table['opened'];
              table_ID = table['objectId'];
            }
          },
        );
        setState(() {
          if (opened == true) {
            for (var table in tables) {
              game = table['game'];
              tableType = table['table_type'];
              seat1player = table['seat_1'];
              seat2player = table['seat_2'];
              seat3player = table['seat_3'];
              seat4player = table['seat_4'];
              seat5player = table['seat_5'];
              seat6player = table['seat_6'];
              seat7player = table['seat_7'];
            }
          } else {
            null;
          }
        });
      }
      ;
    } else {
      print(response.error);
    }
  }

  void openTable(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('game', game)
      ..set('opened', true)
      ..set('table_type', tableType);

    await table.save();

    liveQuery();
  }

  void changeTable(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('game', game)
      ..set('table_type', tableType);

    await table.save();
    switchFavorite();
  }

  void closeTable(String tableID) async {
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('game', '')
      ..set('opened', false)
      ..set('table_type', '')
      ..set('seat_1', '')
      ..set('seat_2', '')
      ..set('seat_3', '')
      ..set('seat_4', '')
      ..set('seat_5', '')
      ..set('seat_6', '')
      ..set('seat_7', '');

    await table.save();
  }

  void closeTableButton() {
    if (opened == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Close'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.green[800],
                      child: Text(
                        "With players continue (High Card)",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      onPressed: () {
                        setState(
                          () {
                            closeTable(table_ID);
                            opened = false;
                          },
                        );
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      color: Colors.green[800],
                      child: Text(
                        "      Without players continue      ",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      onPressed: () {
                        setState(
                          () {
                            closeTable(table_ID);
                            opened = false;
                          },
                        );
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      null;
    }
  }

  void openTableButton() {
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
              RaisedButton(
                color: Colors.green[800],
                child: Text("Submit"),
                onPressed: () {
                  openTable(table_ID);
                  checkTable();
                  playersList();
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      );
    } else {
      null;
    }
  }

  liveQuery() async {
    final LiveQuery liveQuery = LiveQuery();
    setState(() {
      dateToday = DateTime(now.year, now.month, now.day);

      dateTodaySt = DateTime(now.year, now.month, now.day, 9);
      dateTodayEn = DateTime(now.year, now.month, now.day, 14);
    });

    QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..includeObject(['username', 'Status'])
      ..whereEqualTo('game', game)
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)));

    var response = await query.query();
    await liveQuery.subscribe(query);

    if (response.success) {
      setState(
        () {
          users = response.results;
          users.removeWhere((user) => user['Status']['state'] == 'Seated');
          users.removeWhere((user) => user['Status']['state'] == 'Cancelled');
        },
      );
      switchFavorite();
    } else {
      print(response.error);
    }

    liveQuery.on(LiveQueryEvent.create, (value) async {
      print('*** CREATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));

      playersList();
      switchFavorite();
    });

    liveQuery.on(LiveQueryEvent.update, (value) async {
      print('*** UPDATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));

      playersList();
      switchFavorite();
    });

    liveQuery.on(LiveQueryEvent.enter, (value) async {
      print('*** ENTER ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));

      playersList();
      switchFavorite();
    });

    liveQuery.on(LiveQueryEvent.leave, (value) async {
      print('*** LEAVE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));

      playersList();
      switchFavorite();
    });

    liveQuery.on(LiveQueryEvent.delete, (value) async {
      print('*** DELETE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));

      playersList();
      switchFavorite();
    });
  }

  @override
  void initState() {
    checkTable();
    liveCheckTable();
    setSeat();
    getSeatedObj();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green[800],
            title: Text("Table"),
          ),
          body: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Hero(
                      tag: 'table1',
                      child: Image.asset(
                        'assets/images/Table1.jpg',
                        width: 200,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    tableState()
                  ],
                ),
              ),
              Container(
                child: Expanded(
                  child: ListView(
                    children: [
                      wButton(),
                      RaisedButton(
                        color: Colors.green[800],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Table Settings",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: AdaptiveTextSize()
                                    .getadaptiveTextSize(context, 16)),
                          ),
                        ),
                        onPressed: () {
                          tableSettings();
                        },
                      ),
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text('Seat Players',
                            style: TextStyle(
                                fontSize: AdaptiveTextSize()
                                    .getadaptiveTextSize(context, 11))),
                        backgroundColor: Colors.grey[200],
                        children: [ifList()],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } on Error {
      return Scaffold(
        body: Center(
          child: Container(
              width: 100, height: 100, child: CircularProgressIndicator()),
        ),
      );
    }
  }
}
