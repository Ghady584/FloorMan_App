import 'dart:convert';

import 'package:floor_manager/components/empty_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/responsive_text.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class RegistrationList extends StatefulWidget {
  const RegistrationList({Key key}) : super(key: key);

  @override
  _RegistrationList createState() => _RegistrationList();
}

class _RegistrationList extends State<RegistrationList> {
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
  final List games = ['(Table change)'];

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

  void playerCreate(
    String name,
    String game,
    String registrated,
    String status,
    bool favorite,
  ) async {
    QueryBuilder<ParseObject> playerObj =
        QueryBuilder<ParseObject>(ParseObject('players'))
          ..whereEqualTo('Name', name);
    var response_playerObj = await playerObj.query();
    if (response_playerObj.result == null) {
      await playerNameCreate(name);
      QueryBuilder<ParseObject> playerObj =
          QueryBuilder<ParseObject>(ParseObject('players'))
            ..whereEqualTo('Name', name);
      var response_playerObj = await playerObj.query();

      QueryBuilder<ParseObject> query =
          QueryBuilder<ParseObject>(ParseObject('States'))
            ..whereEqualTo('state', status);
      var response = await query.query();
      for (var item in response.results) {
        var stateObj = item;
        var customer = ParseObject('registrations')
          ..set('username', response_playerObj.result[0])
          ..set('game', game)
          ..set('type', 'Registration')
          ..set('favorite', favorite)
          ..set('registrated_by', registrated)
          ..set('check_in_time', DateTime.now())
          ..set('registration_time', DateTime.now())
          ..set('Status', stateObj);
        await customer.save();
      }
    } else {
      QueryBuilder<ParseObject> query =
          QueryBuilder<ParseObject>(ParseObject('States'))
            ..whereEqualTo('state', status);
      var response = await query.query();
      for (var item in response.results) {
        var stateObj = item;
        var customer = ParseObject('registrations')
          ..set('username', response_playerObj.result[0])
          ..set('game', game)
          ..set('type', 'Registration')
          ..set('favorite', favorite)
          ..set('registrated_by', registrated)
          ..set('check_in_time', DateTime.now())
          ..set('registration_time', DateTime.now())
          ..set('Status', stateObj);
        await customer.save();
      }
    }
  }

  var selectedTime;
  DateTime selectedDate = DateTime.now();
  DateTime dateTime;

  Future _selectTime(BuildContext context) async {
    var picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
    return picked;
  }

  Future pickDateTime(BuildContext context) async {
    final date = await DateTime.now();
    final time = await _selectTime(context);

    await setState(() {
      dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void gamesGet() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('games'));

    var response = await queryPost.query();

    if (response.success) {
      setState(
        () {
          gamesList = response.results;
        },
      );
      for (var game in gamesList) {
        setState(() {
          games.add(game['game_name'].toString());
        });
      }
    } else {
      print(response.error);
    }
  }

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

  var user;

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
        user = (res.data);
      });
      print(user);
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
          "objectId": user['results'][0]['objectId'],
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
          "objectId": user['results'][0]['objectId'],
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
    setState(() {
      playerName = response.result;
      for (var item in playerName) {
        playersNames.add(item['Name'].toString());
      }
      print(playersNames);
    });
  }

  void switchFavorite() {
    for (var user in users)
      if (user['favorite'] == true) {
        user['favorite'] = '❤';
      } else {
        user['favorite'] = " ";
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
    await setDate();
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
          users.removeWhere((user) => user['game'] == 'PLO 5/10');
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
      dateTodaySt = DateTime(now.year, now.month, now.day, 9);
      dateTodayEn = DateTime(now.year, now.month, now.day, 4);
    });

    QueryBuilder<ParseObject> queryPost = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)))
      ..includeObject(['username', 'Status']);

    var response = await queryPost.query();

    if (response.success) {
      setState(
        () {
          users = response.results;
        },
      );

      switchFavorite();
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
          ..whereNotEqualTo('Registration_Time', null);
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

      dateTodaySt = DateTime(now.year, now.month, now.day, 9);
      dateTodayEn = DateTime(now.year, now.month, now.day, 4);
    });
    await setDate();
    QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..includeObject(['username', 'Status'])
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)));

    var response = await query.query();
    if (mounted) {
      setState(() {
        users = response.results;

        users.removeWhere((user) => user['Status']['state'] == 'Seated');
        users.removeWhere((user) => user['Status']['state'] == 'Cancelled');
      });
    }

    switchFavorite();
    switchCancelReason();
    switchCancelTime();
    switchComment();
    switchRegTime();
    switchSeat();
    switchSeatTime();
    switchTable();

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
    liveQuery();

    gamesGet();
    playersListGet();

    super.initState();
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
            "Today\'s Registration List ",
          ),
        ),
        body: EmptyContent(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[800],
          child: Icon(
            FontAwesomeIcons.plus,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('New Registration'),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: this._usernameController,
                              decoration: InputDecoration(
                                  hintText: 'Name',
                                  border: OutlineInputBorder()),
                            ),
                            suggestionsCallback: (pattern) =>
                                playersNames.where((item) => item
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase())),
                            itemBuilder: (_, item) {
                              return ListTile(
                                title: Text(item),
                              );
                            },
                            onSuggestionSelected: (val) {
                              this._usernameController.text = val;
                              print(val);
                            },
                            getImmediateSuggestions: true,
                            noItemsFoundBuilder: (context) => Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No players found'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text('Game:'),
                              SizedBox(
                                width: 32,
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return DropdownButton<String>(
                                    value: (game) ?? 'NLH 2/4',
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
                                },
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('Favorite?'),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Checkbox(
                                    value: favorite,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          favorite = value;
                                        },
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('Registrated By:'),
                              SizedBox(
                                width: 32,
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return DropdownButton<String>(
                                    value: (registrated) ?? 'Registrated By',
                                    items: registratedBy.map(
                                      (registrated) {
                                        return DropdownMenuItem<String>(
                                          value: registrated,
                                          child: Text(registrated),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          registrated = value;
                                        },
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('State:'),
                              SizedBox(
                                width: 32,
                              ),
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return DropdownButton<String>(
                                    value: (state) ?? 'state',
                                    items: status.map(
                                      (state) {
                                        return DropdownMenuItem<String>(
                                          value: state,
                                          child: Text(state),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          state = value;
                                        },
                                      );
                                    },
                                  );
                                },
                              )
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
                        playerCreate(_usernameController.text, game,
                            registrated, state, favorite);
                        _usernameController.clear();

                        setState(() {
                          game = 'NLH 2/4';
                          favorite = false;
                        });

                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              },
            );
          },
        ),
      );
    } else {
      // try {
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
              Builder(
                builder: (context) => Center(
                  child: IconButton(
                    icon: Icon(Icons.view_sidebar),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.green[800],
            title: Text(
              "Today\'s Registration List ",
            ),
          ),
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                  ),
                  child: Center(
                    child: Text(
                      'Filter',
                      style: TextStyle(color: Colors.white, fontSize: 35),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    children: [
                      Text('Games:'),
                      SizedBox(
                        width: 32,
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text('NLH 2/4'),
                                  Checkbox(
                                    value: filterNLH2,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterNLH2 = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('NLH 5/10'),
                                  Checkbox(
                                    value: filterNLH5,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterNLH5 = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('PLO 5/10'),
                                  Checkbox(
                                    value: filterPLO5,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterPLO5 = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('PLO 10/10'),
                                  Checkbox(
                                    value: filterPLO10,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterPLO10 = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    children: [
                      Text('States:'),
                      SizedBox(
                        width: 32,
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text('Checked-In'),
                                  Checkbox(
                                    value: filterCheckIn,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterCheckIn = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Pending'),
                                  Checkbox(
                                    value: filterPending,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterPending = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Seated'),
                                  Checkbox(
                                    value: filterSeated,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterSeated = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Cancelled'),
                                  Checkbox(
                                    value: filterCancelled,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          filterCancelled = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: RaisedButton(
                    color: Colors.green[800],
                    onPressed: () {
                      Navigator.pop(context);

                      filter();
                      setState(() {
                        game = 'NLH 2/4';
                        state = 'state';
                      });
                    },
                    child: Text(
                      'Filter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
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
                label: Text('Game',
                    style: TextStyle(
                        fontSize: AdaptiveTextSize()
                            .getadaptiveTextSize(context, 10))),
              ),
              DataColumn(
                label: Text('Favorite?',
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
                      game = user['game'];
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
                          title: Text('Edit Registration'),
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
                                      Text('Game:'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return DropdownButton<String>(
                                            value: (game) ?? user['game'],
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
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Type:'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return DropdownButton<String>(
                                            value: (type) ?? user['type'],
                                            items: types.map(
                                              (type) {
                                                return DropdownMenuItem<String>(
                                                  value: type,
                                                  child: Text(type),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  type = value;
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    children: [
                                      Text('Favorite?'),
                                      SizedBox(
                                        width: 32,
                                      ),
                                      Text(user['favorite'])
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
                                      StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return DropdownButton<String>(
                                            value: (registrated) ??
                                                user['registrated_by'],
                                            items: registratedBy.map(
                                              (registrated) {
                                                return DropdownMenuItem<String>(
                                                  value: registrated,
                                                  child: Text(registrated),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  registrated = value;
                                                },
                                              );
                                            },
                                          );
                                        },
                                      )
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
                                      IconButton(
                                          icon: Icon(Icons.edit_off),
                                          color: Colors.black,
                                          onPressed: () {
                                            pickDateTime(context);
                                          }),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('State:'),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return DropdownButton<String>(
                                            value: (state) ??
                                                user['Status']['state'],
                                            items: status.map(
                                              (state) {
                                                return DropdownMenuItem<String>(
                                                  value: state,
                                                  child: Text(state),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  state = value;
                                                },
                                              );
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                  RaisedButton(
                                    color: Colors.green[800],
                                    child: Text(
                                      "Start Dinner Break",
                                    ),
                                    onPressed: () async {
                                      await startDinner();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  RaisedButton(
                                    color: Colors.green[800],
                                    child: Text(
                                      "Cancel registration",
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: Text('Cancel registartion'),
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
                                              RaisedButton(
                                                color: Colors.green[800],
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
                                  RaisedButton(
                                    color: Colors.green[800],
                                    child: Text(
                                      "Check-In Player",
                                    ),
                                    onPressed: () {
                                      playerCheckIn(user['objectId']);
                                      checkPlayerIn();

                                      Navigator.pop(context);
                                    },
                                  ),
                                  RaisedButton(
                                    color: Colors.green[800],
                                    child: Text(
                                      "Apply Changes To Registration",
                                    ),
                                    onPressed: () {
                                      playerRegEdit(state, user['objectId']);
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
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green[800],
            child: Icon(
              FontAwesomeIcons.plus,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                game = 'NLH 2/4';
                favorite = false;
                registrated = 'Floor Manager';
                state = 'Pending';
              });

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text('New Registration'),
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            TypeAheadFormField(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: this._usernameController,
                                decoration: InputDecoration(
                                    hintText: 'Name',
                                    border: OutlineInputBorder()),
                              ),
                              suggestionsCallback: (pattern) =>
                                  playersNames.where((item) => item
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase())),
                              itemBuilder: (_, item) {
                                return ListTile(
                                  title: Text(item),
                                );
                              },
                              onSuggestionSelected: (val) {
                                this._usernameController.text = val;
                                print(val);
                              },
                              getImmediateSuggestions: true,
                              noItemsFoundBuilder: (context) => Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No players found'),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text('Game:'),
                                SizedBox(
                                  width: 32,
                                ),
                                StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return DropdownButton<String>(
                                      value: (game) ?? 'NLH 2/4',
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
                                  },
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Favorite?'),
                                StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Checkbox(
                                      value: favorite,
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            favorite = value;
                                          },
                                        );
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Registrated By:'),
                                SizedBox(
                                  width: 32,
                                ),
                                StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return DropdownButton<String>(
                                      value: (registrated) ?? 'Registrated By',
                                      items: registratedBy.map(
                                        (registrated) {
                                          return DropdownMenuItem<String>(
                                            value: registrated,
                                            child: Text(registrated),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            registrated = value;
                                          },
                                        );
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('State:'),
                                SizedBox(
                                  width: 32,
                                ),
                                StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return DropdownButton<String>(
                                      value: (state) ?? 'state',
                                      items: status.map(
                                        (state) {
                                          return DropdownMenuItem<String>(
                                            value: state,
                                            child: Text(state),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            state = value;
                                          },
                                        );
                                      },
                                    );
                                  },
                                )
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
                          playerCreate(_usernameController.text, game,
                              registrated, state, favorite);
                          _usernameController.clear();

                          setState(() {
                            game = 'NLH 2/4';
                            favorite = false;
                            registrated = 'Registrated By';
                            state = 'state';
                          });

                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }
}
