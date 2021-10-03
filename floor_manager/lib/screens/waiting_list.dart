import 'dart:convert';
import 'dart:developer';

import 'package:floor_manager/components/empty_content.dart';
import 'package:floor_manager/screens/casino_layout_alt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/responsive_text.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class WaitingList extends StatefulWidget {
  const WaitingList({Key key}) : super(key: key);

  @override
  _WaitingListState createState() => _WaitingListState();
}

class _WaitingListState extends State<WaitingList> {
  DateTime now = DateTime.now();
  DateTime dateToday;

  var users = [];
  bool waiting = false;
  bool checkedinlist = false;
  bool test = false;

  bool filterNLH2 = true;
  bool filterNLH5 = true;
  bool filterPLO5 = true;
  bool filterPLO10 = true;

  bool filterCheckIn = true;
  bool filterPending = true;
  bool filterSeated = false;
  bool filterCancelled = false;

  var gamesList;
  String username;
  final List games = ['(Table change)', '(Dinner Break Request)'];

  String game;

  final List cancels = ['Cancelled by floormanager', 'No Show'];
  String cancel;
  bool favorite = false;

  final List types = ['Registration', 'Waiting'];
  String type;
  final List registratedBy = [
    'Floor Manager',
    'Mobile App',
    'Phone',
    'Reception'
  ];
  String registrated;
  final List status = ['Pending', 'Seated', 'Checked-In', 'Cancelled'];
  String state;
  var players;
  String playerID;

  bool waitinglist = false;
  TextEditingController _usernameController = TextEditingController();

  String date(DateTime date) {
    return DateFormat.yMEd().add_jms().format(date.toLocal());
  }

  void playerNameCreate(String name) async {
    var customer = ParseObject('players')..set('Name', name);

    await customer.save();
  }

  var selectedTime;
  DateTime selectedDate = DateTime.now();
  DateTime dateTime;

  void playerCancel(String userID, String cancel) async {
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('States'))
          ..whereEqualTo('state', 'Cancelled');
    var response = await query.query();
    for (var item in response.results) {
      var stateObj = item;

      var customer = ParseObject('registrations')
        ..objectId = userID
        ..set('cancellation_time', DateTime.now())
        ..set('cancellation_reason', cancel)
        ..set('Status', stateObj);

      await customer.save();
    }
  }

  void apprReq(String req, String userID) async {
    if (req == '(Dinner Break Request)') {
      QueryBuilder<ParseObject> query =
          QueryBuilder<ParseObject>(ParseObject('States'))
            ..whereEqualTo('state', 'Done');
      var response = await query.query();
      for (var item in response.results) {
        var stateObj = item;

        var customer = ParseObject('registrations')
          ..objectId = userID
          ..set('Status', stateObj);

        await customer.save();
      }
      startDinner();
    } else {
      setState(
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CasinoLayOutAlt();
              },
            ),
          );
        },
      );
    }
  }

  List playerTable;
  void getTablePlayer() async {
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('Tables'));

    var response = await query.query();
    log(response.results.toString());
    for (var item in response.results) {
      playerTable.add(item['objectId']);

      /*  var customer = ParseObject('registrations')
        ..objectId = userID
        ..set('Status', stateObj)
        ..set('check_in_time', DateTime.now());

      await customer.save();*/
    }
  }

  void playerCheckIn(
    String userID,
  ) async {
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('States'))
          ..whereEqualTo('state', 'Checked-In');
    var response = await query.query();
    for (var item in response.results) {
      var stateObj = item;

      var customer = ParseObject('registrations')
        ..objectId = userID
        ..set('Status', stateObj)
        ..set('check_in_time', DateTime.now());

      await customer.save();
    }
  }

  var user1;

  void getUser_app(String nama) async {
    var _dio = new Dio();
    var options = new Options(
      followRedirects: false,
      // will not throw errors
      validateStatus: (status) => true,
    );
    options.headers = {
      'Conten-type': 'application/json',
      'Accept': 'application/json',
      'X-Parse-Application-Id': 'ExYGOkRIyPwaQWO52Dtz6DPFp0UecekaMU9yaVLE',
      'X-Parse-Master-Key': 'tViUC9E1rQXU6evqOiB1Ogn5M66SRp7Ug95MN2NO',
      'X-Parse-REST-API-Key': '6UgE4EoZJ4pTMkzFvD1H5VVzRenZAsoEJ32yy82I'
    };
    options.contentType = 'application/json';

    String url = 'https://parseapi.back4app.com/classes/_User';

    Map<String, String> qParams = {
      'where': '{"username": "$nama"}',
    };
    var res = await _dio.get(url, options: options, queryParameters: qParams);
    if (res.statusCode == 200) {
      setState(() {
        user1 = (res.data);
      });
      print(user1);
    } else {
      throw "Unable to retrieve posts.";
    }
  }

  void checkPlayerIn() async {
    var res = await http.post(
      Uri.parse('https://parseapi.back4app.com/classes/Messages'),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'X-Parse-Application-Id': 'ExYGOkRIyPwaQWO52Dtz6DPFp0UecekaMU9yaVLE',
        'X-Parse-Master-Key': 'tViUC9E1rQXU6evqOiB1Ogn5M66SRp7Ug95MN2NO',
        'X-Parse-REST-API-Key': '6UgE4EoZJ4pTMkzFvD1H5VVzRenZAsoEJ32yy82I'
      },
      body: jsonEncode({
        'player': {
          "__type": "Pointer",
          "className": "_User",
          "objectId": user1['results'][0]['objectId'],
        },
        'Message': 'You Have been checked in',
      }),
    );
    if (res.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return jsonDecode(res.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception(res.statusCode);
    }
  }

  startDinner() async {
    var res = await http.post(
      Uri.parse('https://parseapi.back4app.com/classes/Messages'),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'X-Parse-Application-Id': 'ExYGOkRIyPwaQWO52Dtz6DPFp0UecekaMU9yaVLE',
        'X-Parse-Master-Key': 'tViUC9E1rQXU6evqOiB1Ogn5M66SRp7Ug95MN2NO',
        'X-Parse-REST-API-Key': '6UgE4EoZJ4pTMkzFvD1H5VVzRenZAsoEJ32yy82I'
      },
      body: jsonEncode({
        'player': {
          "__type": "Pointer",
          "className": "_User",
          "objectId": user1['results'][0]['objectId'],
        },
        'Message':
            'Your Dinner Break has started please be back at your seat in 30 minuts',
      }),
    );
    if (res.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return jsonDecode(res.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception(res.statusCode);
    }
  }

  void playerRegEdit(
    String status,
    String userID,
  ) async {
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('States'))
          ..whereEqualTo('state', status);
    var response = await query.query();
    for (var item in response.results) {
      var stateObj = item;

      var customer = ParseObject('registrations')
        ..objectId = userID
        ..set('game', game)
        ..set('type', type)
        ..set('registration_time', dateTime)
        ..set('registrated_by', registrated)
        ..set('Status', stateObj);

      await customer.save();
    }
  }

  var playerName;
  List playersNames = [];
  void playersListGet() async {
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject('players'));
    var response = await query.query();
    if (mounted) {
      setState(() {
        playerName = response.result;
        for (var item in playerName) {
          playersNames.add(item['Name'].toString());
        }
        print(playersNames);
      });
    }
  }

  void switchTable() {
    for (var user in users)
      if (user['table'] == null) {
        user['table'] = "";
      }
  }

  void switchComment() {
    for (var user in users)
      if (user['comment'] == null) {
        user['comment'] = "";
      }
  }

  void switchRegTime() {
    for (var user in users)
      if (user['registration_time'] == null) {
        user['registration_time'] = "";
      } else {
        user['registration_time'] = date(user['registration_time']);
      }
  }

  void switchCancelTime() {
    for (var user in users)
      if (user['cancellation_time'] == null) {
        user['cancellation_time'] = "";
      } else {
        user['cancellation_time'] = date(user['cancellation_time']);
      }
  }

  void switchCancelReason() {
    for (var user in users)
      if (user['cancellation_reason'] == null) {
        user['cancellation_reason'] = "";
      }
  }

  void switchSeatTime() {
    for (var user in users)
      if (user['seated_time'] == null) {
        user['seated_time'] = "";
      }
  }

  void switchSeat() {
    for (var user in users)
      if (user['seat'] == null) {
        user['seat'] = "";
      }
  }

  void filter() async {
    await refreshAll();
    if (users == null) {
      null;
    } else {
      if (filterNLH2 == false) {
        setState(() {
          users.removeWhere((user) => user['game'] == 'NLH 2/4');
        });
      }
      if (filterNLH5 == false) {
        setState(() {
          users.removeWhere((user) => user['game'] == 'NLH 5/10');
        });
      }
      if (filterPLO5 == false) {
        setState(() {
          users.removeWhere((user) => user['game'] == 'PLO 5/5');
        });
      }
      if (filterPLO10 == false) {
        setState(() {
          users.removeWhere((user) => user['game'] == 'PLO 10/10');
        });
      }
      if (filterCheckIn == false) {
        setState(() {
          users.removeWhere((user) => user['Status']['state'] == 'Checked-In');
        });
      }
      if (filterPending == false) {
        setState(() {
          users.removeWhere((user) => user['Status']['state'] == 'Pending');
        });
      }
      if (filterSeated == false) {
        setState(() {
          users.removeWhere((user) => user['Status']['state'] == 'Seated');
        });
      }
      if (filterCancelled == false) {
        setState(() {
          users.removeWhere((user) => user['Status']['state'] == 'Cancelled');
        });
      }
    }
  }

  void refreshAll() async {
    setState(() {
      dateTodaySt = DateTime(
        now.year,
        now.month,
        now.day,
      );
      dateTodayEn = DateTime(
        now.year,
        now.month,
        now.day,
      );
    });
    await setDate();

    QueryBuilder<ParseObject> queryPost = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)))
      ..whereEqualTo('type', 'Waiting')
      ..includeObject(['username', 'Status']);

    var response = await queryPost.query();

    if (response.success) {
      setState(
        () {
          users = response.results;
        },
      );

      switchCancelReason();
      switchCancelTime();
      switchComment();
      switchRegTime();
      switchSeat();
      switchSeatTime();
      switchTable();
    } else {
      print(response.error);
    }
  }

  void setDate() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('registrations'))
          ..whereNotEqualTo('Registration_Time', null)
          ..whereEqualTo('registration_time', null);
    var response = await queryPost.query();

    if (response.success) {
      if (response.results != null) {
        for (var item in response.results) {
          if (item['registration_time'] !=
              DateTime.parse(item['Registration_Time'])) {
            var customer = ParseObject('registrations')
              ..objectId = item['objectId']
              ..set('registration_time',
                  DateTime.parse(item['Registration_Time']));
            await customer.save();
          }
        }
      }
    } else {
      print(response.error);
    }
  }

  DateTime dateTodaySt;
  DateTime dateTodayEn;

  liveQuery() async {
    final LiveQuery liveQuery = LiveQuery();

    setState(() {
      dateToday = DateTime(now.year, now.month, now.day);

      dateTodaySt = DateTime(
        now.year,
        now.month,
        now.day,
      );
      dateTodayEn = DateTime(
        now.year,
        now.month,
        now.day,
      );
    });
    await setDate();
    QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..includeObject(['username', 'Status'])
      ..whereEqualTo('type', 'Waiting')
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)));

    var response = await query.query();
    setState(() {
      users = response.results;
      switchCancelReason();
      switchCancelTime();
      switchComment();
      switchRegTime();
      switchSeat();
      switchSeatTime();
      switchTable();

      users.removeWhere((user) => user['Status']['state'] == 'Seated');
      users.removeWhere((user) => user['Status']['state'] == 'Cancelled');
    });

    Subscription subscription = await liveQuery.client.subscribe(query);

    subscription.on(LiveQueryEvent.create, (value) async {
      print('*** CREATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      if (mounted) {
        filter();
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
        filter();
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
        filter();
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
        filter();
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
        filter();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    liveQuery();
    getTablePlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (users == null) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(FontAwesomeIcons.redo),
              onPressed: () {
                filter();
                liveQuery();
              },
            ),
          ],
          backgroundColor: Colors.green[800],
          title: Text(
            "Waiting List",
          ),
        ),
        body: EmptyContent(),
      );
    } else {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(FontAwesomeIcons.redo),
                onPressed: () {
                  filter();
                },
              ),
            ],
            backgroundColor: Colors.green[800],
            title: Text(
              "Waiting List",
            ),
          ),
          body: DataTable2(
            columnSpacing: 0,
            horizontalMargin: 20,
            minWidth: 300,
            columns: [
              DataColumn2(
                label: Text('Player',
                    style: TextStyle(
                        fontSize: AdaptiveTextSize()
                            .getadaptiveTextSize(context, 10))),
                size: ColumnSize.L,
              ),
              DataColumn(
                label: Text('Request',
                    style: TextStyle(
                        fontSize: AdaptiveTextSize()
                            .getadaptiveTextSize(context, 10))),
              ),
              DataColumn(
                label: Text('Status',
                    style: TextStyle(
                        fontSize: AdaptiveTextSize()
                            .getadaptiveTextSize(context, 10))),
              ),
            ],
            rows: [
              for (var user in users)
                DataRow2(
                  onTap: () async {
                    print(user['username']['Name']);
                    await getUser_app(user['username']['Name']);
                    setState(() {
                      type = user['type'];
                      registrated = user['registrated_by'];
                      state = user['Status']['state'];
                      cancel = null;
                    });

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          scrollable: true,
                          title: Text('Currant Request'),
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  Card(
                                    color: Colors.grey[200],
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.teal[900],
                                          ),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Text(user['username']['Name'],
                                              style: TextStyle(
                                                  color: Colors.teal[900],
                                                  fontSize: 15))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text('Type:'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Text(user['type']),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    children: [
                                      Text('Comment:'),
                                      SizedBox(
                                        width: 32,
                                      ),
                                      Text(user['comment'])
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Registrated By:'),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(user['registrated_by']),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Registration Time'),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Flexible(
                                        child: Text(
                                          user['registration_time'],
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('State:'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Text(user['Status']['state']),
                                    ],
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.green[800]),
                                    child: Text(
                                      "Approve Request",
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      await apprReq(user['game'].toString(),
                                          user['objectId']);
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.green[800]),
                                    child: Text(
                                      "Cancel Request",
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: Text('Cancel Request'),
                                            content: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Form(
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      children: [
                                                        StatefulBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              StateSetter
                                                                  setState) {
                                                            return DropdownButton<
                                                                String>(
                                                              value: (cancel) ??
                                                                  'Cancelled by floormanager',
                                                              items:
                                                                  cancels.map(
                                                                (cancel) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        cancel,
                                                                    child: Text(
                                                                        cancel),
                                                                  );
                                                                },
                                                              ).toList(),
                                                              onChanged:
                                                                  (value) {
                                                                setState(
                                                                  () {
                                                                    cancel =
                                                                        value;
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green[800]),
                                                child: Text(
                                                  "Submit",
                                                ),
                                                onPressed: () {
                                                  playerCancel(
                                                      user['objectId'], cancel);
                                                  Navigator.pop(context);
                                                  cancel =
                                                      'Cancellation Reason';
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                      Text(user['Status']['state'].toString(),
                          style: TextStyle(
                              fontSize: AdaptiveTextSize()
                                  .getadaptiveTextSize(context, 10))),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }
  }
}
