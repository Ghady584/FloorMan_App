import 'dart:convert';
import 'dart:developer';
import 'package:floor_manager/screens/casino_layout_alt.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:floor_manager/paints/chair.dart';
import 'package:floor_manager/paints/table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TableScreenAlt extends StatefulWidget {
  var tableData;
  TableScreenAlt({this.tableData});

  @override
  _TableScreenAltState createState() => _TableScreenAltState();
}

class _TableScreenAltState extends State<TableScreenAlt> {
  List _chairs = [];

  DateTime dateTodaySt;
  DateTime dateTodayEn;
  DateTime now = DateTime.now();
  var users = [];
  String game;
  String tableType;
  final List tableTypes = ['Main Table', 'Regular Table'];
  final List games = ['NLH 5/10', 'NLH 2/4', 'PLO 5/10', 'PLO 10/10'];

  void switchFavorite() {
    for (var user in users)
      if (user['fav_game'] == null) {
        user['fav_game'] = '';
      }
  }

  void changeTable(String tableID) async {
    setState(() {
      widget.tableData['game'] = game;
      widget.tableData['table_type'] = tableType;
    });
    var table = ParseObject('Tables')
      ..objectId = tableID
      ..set('game', game)
      ..set('table_type', tableType);

    await table.save();
    // switchFavorite();
  }

  var user1;
  void getUser_app(String username) async {
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
      'where': '{"username": "$username"}',
    };
    var res = await _dio.get(url, options: options, queryParameters: qParams);
    if (res.statusCode == 200) {
      await setState(() {
        user1 = (res.data);

        getUser_appState(user1['results'][0]['objectId']);
      });
    } else {
      throw "Unable to retrieve posts.";
    }
  }

  var userStateId;
  void getUser_appState(String userAppId) async {
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

    String url = 'https://parseapi.back4app.com/classes/States';

    var res = await _dio.get(url, options: options, queryParameters: {
      'where':
          '{"user": { "__type": "Pointer" , "className": "_User" ,  "objectId": "$userAppId"}}'
    });
    if (res.statusCode == 200) {
      setState(() {
        userStateId = (res.data['results'][0]['objectId']);
      });
      print(user1);
    } else {
      throw "Unable to retrieve posts.";
    }
  }

  seatUserState(String stateID) async {
    var res = await http.put(
      Uri.parse('https://parseapi.back4app.com/classes/States/' + stateID),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'X-Parse-Application-Id': 'ExYGOkRIyPwaQWO52Dtz6DPFp0UecekaMU9yaVLE',
        'X-Parse-Master-Key': 'tViUC9E1rQXU6evqOiB1Ogn5M66SRp7Ug95MN2NO',
        'X-Parse-REST-API-Key': '6UgE4EoZJ4pTMkzFvD1H5VVzRenZAsoEJ32yy82I'
      },
      body: jsonEncode({
        'state': 'Seated',
      }),
    );
    if (res.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return jsonDecode(res.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception(res.statusCode);
    }
  }

  openUserState(String stateID) async {
    var res = await http.put(
      Uri.parse('https://parseapi.back4app.com/classes/States/' + stateID),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'X-Parse-Application-Id': 'ExYGOkRIyPwaQWO52Dtz6DPFp0UecekaMU9yaVLE',
        'X-Parse-Master-Key': 'tViUC9E1rQXU6evqOiB1Ogn5M66SRp7Ug95MN2NO',
        'X-Parse-REST-API-Key': '6UgE4EoZJ4pTMkzFvD1H5VVzRenZAsoEJ32yy82I'
      },
      body: jsonEncode({
        'state': 'Not Registrated',
      }),
    );
    if (res.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return jsonDecode(res.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception(res.statusCode);
    }
  }

  void tableReady(String seatX) async {
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
        'Message': 'Your Table is ready "$seatX"',
      }),
    );
    if (res.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      seatUserState(userStateId);
      return jsonDecode(res.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception(res.statusCode);
    }
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
      ..set('seat_7', '')
      ..set('seat_8', '')
      ..set('seat_9', '')
      ..set('seat_10', '');

    await table.save();
  }

  openSeat(String tableID, var chairName, String userName) async {
    await getUser_app(userName);
    openUserState(userStateId);

    var table = ParseObject('Tables')..objectId = tableID;
    switch (chairName) {
      case 'Chair 1':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_1', '');

        await table.save();

        break;
      case 'Chair 2':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_2', '');

        await table.save();

        break;
      case 'Chair 3':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_3', '');

        await table.save();

        break;
      case 'Chair 4':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_4', '');

        await table.save();

        break;
      case 'Chair 5':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_5', '');

        await table.save();

        break;
      case 'Chair 6':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_6', '');

        await table.save();

        break;
      case 'Chair 7':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_7', '');

        await table.save();

        break;
      case 'Chair 8':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_8', '');

        await table.save();

        break;
      case 'Chair 9':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_9', '');

        await table.save();

        break;
      case 'Chair 10':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_10', '');

        await table.save();

        break;
    }
    ;
    await table.save();
  }

  var seatedObj;
  getSeatedObj() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('States'))
          ..whereEqualTo('state', 'Seated');

    var response = await queryPost.query();
    for (var item in response.results) {
      if (mounted) {
        setState(() {
          seatedObj = item;
        });
      }
    }
  }

  void seatPlayer(
      String tableID, String userName, String userID, String chairName) async {
    await getUser_app(userName);

    var player = ParseObject('registrations')
      ..objectId = userID
      ..set('Status', seatedObj)
      ..set(
          'seat',
          'Tabel ' +
              widget.tableData['table_num'].toString() +
              " " +
              chairName);

    await player.save();
    switch (chairName) {
      case 'Chair 1':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_1', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 1');

        break;
      case 'Chair 2':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_2', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 2');

        break;
      case 'Chair 3':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_3', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 3');

        break;
      case 'Chair 4':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_4', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 4');

        break;
      case 'Chair 5':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_5', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 5');

        break;
      case 'Chair 6':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_6', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 6');

        break;
      case 'Chair 7':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_7', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 7');

        break;
      case 'Chair 8':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_8', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 8');

        break;
      case 'Chair 9':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_9', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 9');

        break;
      case 'Chair 10':
        var table = ParseObject('Tables')
          ..objectId = tableID
          ..set('seat_10', userName);

        await table.save();
        await tableReady(
            'Tabel ' + widget.tableData['table_num'].toString() + ' - Seat 10');

        break;
    }
  }

  var tables;
  checkTable() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('Tables'))
          ..whereEqualTo('table_num', widget.tableData['table_num']);

    var response = await queryPost.query();

    if (response.success) {
      if (mounted) {
        setState(
          () {
            tables = response.results;
            for (var table in tables) {
              widget.tableData['game'] = table['game'];
            }
          },
        );
      }
      ;
    } else {
      print(response.error);
    }
  }

  var tableSumId;
  void closeSum(String tableNum) async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('daily_sum'))
          ..whereEqualTo('Table', tableNum)
          ..whereEqualTo('End', '');
    var response = await queryPost.query();
    if (response.success) {
      setState(() {
        tableSumId = response.results[0]['objectId'];
      });
    } else {
      log(response.error.toString());
    }

    var customer = ParseObject('daily_sum')
      ..objectId = tableSumId
      ..set('End', DateTime.now().toIso8601String());

    await customer.save();
  }

  checkTableSeats() async {
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('Tables'))
          ..whereEqualTo('table_num', widget.tableData['table_num']);

    var response = await queryPost.query();

    if (response.success) {
      setState(() {
        tables = response.results;
        game = tables[0]['game'];
        tableType = tables[0]['table_type'];
        widget.tableData['seat_1'] = tables[0]['seat_1'];
        widget.tableData['seat_2'] = tables[0]['seat_2'];
        widget.tableData['seat_3'] = tables[0]['seat_3'];
        widget.tableData['seat_4'] = tables[0]['seat_4'];
        widget.tableData['seat_5'] = tables[0]['seat_5'];
        widget.tableData['seat_6'] = tables[0]['seat_6'];
        widget.tableData['seat_7'] = tables[0]['seat_7'];
        widget.tableData['seat_8'] = tables[0]['seat_8'];
        widget.tableData['seat_9'] = tables[0]['seat_9'];
        widget.tableData['seat_10'] = tables[0]['seat_10'];
      });

      ;
    } else {
      print(response.error);
    }
  }

  void setupTable() async {
    await checkTableSeats();
    for (var chair in _chairs) {
      if (chair['name'] == "Chair 1") {
        if (widget.tableData['seat_1'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_1'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 2") {
        if (widget.tableData['seat_2'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_2'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 3") {
        if (widget.tableData['seat_3'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_3'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 4") {
        if (widget.tableData['seat_4'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_4'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 5") {
        if (widget.tableData['seat_5'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_5'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 6") {
        if (widget.tableData['seat_6'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_6'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 7") {
        if (widget.tableData['seat_7'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_7'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 8") {
        if (widget.tableData['seat_8'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_8'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 9") {
        if (widget.tableData['seat_9'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_9'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
      if (chair['name'] == "Chair 10") {
        if (widget.tableData['seat_10'] != '') {
          setState(() {
            chair['user'] = widget.tableData['seat_10'];
          });
        } else {
          setState(() {
            chair['user'] = null;
          });
        }
      }
    }
  }

  List games1;

  liveQuery() async {
    final LiveQuery liveQuery = LiveQuery();
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

    QueryBuilder<ParseObject> queryPost = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..includeObject(['username', 'Status'])
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)));

    var response = await queryPost.query();
    if (response.success) {
      setState(
        () {
          usersPlay = response.results;
          usersPlay.removeWhere((user) => user['Status']['state'] == 'Seated');
          usersPlay
              .removeWhere((user) => user['Status']['state'] == 'Cancelled');
          usersPlay.removeWhere((user) => user['Status']['state'] == 'Pending');
          usersPlay.removeWhere(
              (user) => !user['game'].contains(widget.tableData['game']));
        },
      );

      switchFavorite();
    } else {
      print(response.error);
    }
    QueryBuilder<ParseObject> queryPost2 = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..whereEqualTo('type', 'Waiting')
      ..includeObject(['username', 'Status'])
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)));

    var response2 = await queryPost2.query();
    if (response2.success) {
      setState(
        () {
          usersWait = response2.results;
          usersWait.removeWhere((user) => user['Status']['state'] == 'Seated');
          usersWait
              .removeWhere((user) => user['Status']['state'] == 'Cancelled');

          usersWait.removeWhere((user) => user['Status']['state'] == 'Done');
          usersWait.removeWhere((user) =>
              user['table'] !=
              'table ' + widget.tableData['table_num'].toString());
        },
      );

      switchFavorite();
    } else {
      print(response.error);
    }
    setState(() {
      users = usersPlay + usersWait;
    });
    Subscription subscription1 = await liveQuery.client.subscribe(queryPost);

    subscription1.on(LiveQueryEvent.create, (value) async {
      print('*** CREATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      playersList();
    });

    subscription1.on(LiveQueryEvent.update, (value) async {
      print('*** UPDATE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      playersList();
    });

    subscription1.on(LiveQueryEvent.enter, (value) async {
      print('*** ENTER ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      playersList();
    });

    subscription1.on(LiveQueryEvent.leave, (value) async {
      print('*** LEAVE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      playersList();
    });

    subscription1.on(LiveQueryEvent.delete, (value) async {
      print('*** DELETE ***: ${DateTime.now().toString()}\n $value ');
      print((value as ParseObject).objectId);
      print((value as ParseObject).updatedAt);
      print((value as ParseObject).createdAt);
      print((value as ParseObject).get('objectId'));
      print((value as ParseObject).get('updatedAt'));
      print((value as ParseObject).get('createdAt'));
      print('jajajaja');
      playersList();
    });
  }

  var usersPlay = [];
  var usersWait = [];

  void playersList() async {
    // await setupTable();

    setState(() {
      game = widget.tableData['game'];
      tableType = widget.tableData['table_type'];

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

    QueryBuilder<ParseObject> queryPost = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      //  ..whereContainedIn('status', st)
      ..includeObject(['username', 'Status'])
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)));

    var response = await queryPost.query();
    if (response.success) {
      setState(
        () {
          usersPlay = response.results;
          usersPlay.removeWhere((user) => user['Status']['state'] == 'Seated');
          usersPlay
              .removeWhere((user) => user['Status']['state'] == 'Cancelled');
          usersPlay.removeWhere((user) => user['Status']['state'] == 'Pending');
          users.removeWhere(
              (user) => !user['game'].contains(widget.tableData['game']));
        },
      );

      switchFavorite();
    } else {
      print(response.error);
    }
    QueryBuilder<ParseObject> queryPost2 = QueryBuilder<ParseObject>(
        ParseObject('registrations'))
      ..whereEqualTo('type', 'Waiting')
      ..includeObject(['username', 'Status'])
      ..whereGreaterThan('registration_time', dateTodaySt)
      ..whereLessThan("registration_time", dateTodayEn.add(Duration(days: 1)));

    var response2 = await queryPost2.query();
    if (response2.success) {
      setState(
        () {
          usersWait = response2.results;
          usersWait.removeWhere((user) => user['Status']['state'] == 'Seated');
          usersWait
              .removeWhere((user) => user['Status']['state'] == 'Cancelled');

          usersWait.removeWhere((user) => user['Status']['state'] == 'Done');
          usersWait.removeWhere((user) =>
              user['table'] !=
              'table ' + widget.tableData['table_num'].toString());
        },
      );

      switchFavorite();
    } else {
      print(response.error);
    }
    setState(() {
      users = usersPlay + usersWait;
    });
  }

  @override
  void initState() {
    super.initState();
    //
    this.readJson();
    liveQuery();
    getSeatedObj();
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/layouts/chairs10.json');
    final data = await json.decode(response);
    setState(() {
      _chairs = data["chairs"];
      log(_chairs.toString());
      setupTable();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var tableWidth = MediaQuery.of(context).size.height / 2;

    /* List _items = [
      {"id": "p1", "name": "User 1", "description": "Description 1"},
      {"id": "p2", "name": "User 2", "description": "Description 2"},
      {"id": "p3", "name": "User 3", "description": "Description 2"},
      {"id": "p4", "name": "User 4", "description": "Description 2"},
      {"id": "p5", "name": "User 5", "description": "Description 2"},
      {"id": "p6", "name": "User 6", "description": "Description 2"},
      {"id": "p7", "name": "User 7", "description": "Description 2"},
      {"id": "p8", "name": "User 8", "description": "Description 2"},
      {"id": "p9", "name": "User 9", "description": "Description 2"},
      {"id": "p10", "name": "User 10", "description": "Description 2"},
      {"id": "p11", "name": "User 11", "description": "Description 2"},
      {"id": "p12", "name": "User 12", "description": "Description 2"},
      {"id": "p13", "name": "User 13", "description": "Description 2"},
      {"id": "p14", "name": "User 14", "description": "Description 2"},
      {"id": "p15", "name": "User 15", "description": "Description 2"},
      {"id": "p16", "name": "User 16", "description": "Description 2"},
      {"id": "p17", "name": "User 17", "description": "Description 2"},
      {"id": "p18", "name": "User 18", "description": "Description 2"},
      {"id": "p19", "name": "User 19", "description": "Description 2"},
      {"id": "p20", "name": "User 20", "description": "Description 3"}
    ];*/

    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => Center(
              child: IconButton(
                icon: Icon(Icons.person_pin_circle_outlined),
                onPressed: () async {
                  await checkTableSeats();
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Table: ' +
                                widget.tableData['table_num'].toString()),
                            Text('Game: ' + widget.tableData['game']),
                            Text('Seat 1: ' + widget.tableData['seat_1']),
                            Text('Seat 2: ' + widget.tableData['seat_2']),
                            Text('Seat 3: ' + widget.tableData['seat_3']),
                            Text('Seat 4: ' + widget.tableData['seat_4']),
                            Text('Seat 5: ' + widget.tableData['seat_5']),
                            Text('Seat 6: ' + widget.tableData['seat_6']),
                            Text('Seat 7: ' + widget.tableData['seat_7']),
                            Text('Seat 8: ' + widget.tableData['seat_8']),
                            Text('Seat 9: ' + widget.tableData['seat_9']),
                            Text('Seat 10: ' + widget.tableData['seat_10']),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          IconButton(
              onPressed: () {
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
                                      (BuildContext context,
                                          StateSetter setState) {
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
                                      (BuildContext context,
                                          StateSetter setState) {
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
                              TextButton(
                                  onPressed: () {
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
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green[800]),
                                                    child: Text(
                                                      "With players continue (High Card)",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    onPressed: () {
                                                      setState(
                                                        () {
                                                          closeTable(
                                                              widget.tableData[
                                                                  'objectId']);
                                                          closeSum(widget
                                                              .tableData[
                                                                  'table_num']
                                                              .toString());
                                                        },
                                                      );
                                                      Navigator.pop(context);
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                        builder: (context) {
                                                          return CasinoLayOutAlt();
                                                        },
                                                      ));
                                                    },
                                                  ),
                                                  TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.green[
                                                                      800]),
                                                      child: Text(
                                                        "      Without players continue      ",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15),
                                                      ),
                                                      onPressed: () {
                                                        setState(
                                                          () {
                                                            closeTable(widget
                                                                    .tableData[
                                                                'objectId']);
                                                            closeSum(widget
                                                                .tableData[
                                                                    'table_num']
                                                                .toString());
                                                          },
                                                        );
                                                        Navigator.pop(context);

                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                          builder: (context) {
                                                            return CasinoLayOutAlt();
                                                          },
                                                        ));
                                                      })
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text('Close Table'))
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green[800]),
                          child: Text("Submit"),
                          onPressed: () async {
                            await changeTable(widget.tableData['objectId']);
                            setupTable();
                            playersList();
                            setState(() {
                              widget.tableData['game'];
                            });
                            liveQuery();
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.settings))
        ],
        backgroundColor: Colors.green[800],
        title: Text('Table: ' +
            widget.tableData["table_num"].toString() +
            " / " +
            "Game: " +
            widget.tableData["game"].toString()),
      ),
      body: Container(
        child: Stack(children: [
          Row(
            children: [
              users != null
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.grey[100],
                            margin: EdgeInsets.all(2),
                            elevation: 0,
                            child: ListTile(
                              tileColor: Colors.grey[200],
                              leading: Draggable(
                                data: users[index],
                                child: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child:
                                        Icon(Icons.person, color: Colors.red)),
                                feedback: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child:
                                        Icon(Icons.person, color: Colors.red)),
                                childWhenDragging: CircleAvatar(
                                    backgroundColor: Colors.grey[600],
                                    child:
                                        Icon(Icons.person, color: Colors.red)),
                                dragAnchor: DragAnchor.pointer,
                              ),
                              title: Text(users[index]["username"]['Name']),
                              subtitle: Text(users[index]['game'].toString() +
                                  ' / fav: ' +
                                  users[index]['fav_game'].toString()),
                            ),
                          );
                        },
                      ),
                    )
                  : Expanded(
                      child: Center(child: Text('No Players available')),
                    ),
              SizedBox(
                height: height / 1.5,
                child: Stack(
                    // clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Hero(
                        tag: widget.tableData["table_num"].toString(),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: CustomPaint(
                            size: Size(616, (616 * 1).toDouble()),
                            painter: TablePainter(color: Colors.green[800]),
                          ),
                        ),
                      ),
                      for (var chair in _chairs)
                        Positioned(
                          top: chair["y"] + 100,
                          left: chair["x"],
                          child: chair["user"] != null
                              ? DragTarget(
                                  builder:
                                      (context, candidateData, rejectedData) {
                                    return candidateData.length > 0
                                        ? SizedBox(
                                            width: 500 / 6,
                                            height: 500 / 6,
                                            child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.green,
                                                  size: 300 / 6,
                                                )),
                                          )
                                        : Draggable(
                                            data: chair,
                                            child: SizedBox(
                                              width: 500 / 6,
                                              height: 500 / 6,
                                              child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.red,
                                                    size: 300 / 6,
                                                  )),
                                            ),
                                            feedback: CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: SizedBox(
                                                    width: 616 / 6,
                                                    height: 616 / 6,
                                                    child: Icon(Icons.person,
                                                        color: Colors.red))),
                                            dragAnchor: DragAnchor.pointer,
                                          );
                                  },
                                  onAccept: (data) {
                                    setState(() {
                                      chair['user'] = data;
                                    });
                                    seatPlayer(
                                        widget.tableData['objectId'],
                                        data["username"]['Name'],
                                        data['objectId'],
                                        chair['name']);
                                    playersList();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(data["username"]
                                                    ['Name'] +
                                                " added successfully!")));
                                  },
                                )
                              : DragTarget(
                                  builder:
                                      (context, candidateData, rejectedData) {
                                    return candidateData.length > 0
                                        ? SizedBox(
                                            width: 616 / 6,
                                            height: 616 / 6,
                                            child: Icon(Icons.person,
                                                color: Colors.red))
                                        : CustomPaint(
                                            size: Size(616 / 6,
                                                (616 / 6 * 1).toDouble()),
                                            painter: ChairPainter(),
                                          );
                                  },
                                  onAccept: (data) {
                                    setState(() {
                                      chair['user'] = data;
                                    });
                                    seatPlayer(
                                        widget.tableData['objectId'],
                                        data["username"]['Name'],
                                        data['objectId'],
                                        chair['name']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(data["username"]
                                                    ['Name'] +
                                                " added successfully!")));
                                  },
                                ),
                        ),
                    ]),
              ),
            ],
          ),
          Positioned(
            child: DragTarget(
              builder: (context, candidateData, rejectedData) {
                return ClipOval(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.green),
                    child: SizedBox(
                        width: 500 / 6,
                        height: 500 / 6,
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 300 / 6,
                        )),
                  ),
                );
              },
              onAccept: (data) async {
                await openSeat(
                    widget.tableData['objectId'], data['name'], data['user']);
                setupTable();
              },
            ),
            right: 10,
            bottom: 10,
          )
        ]),
      ),
    );
  }
}
