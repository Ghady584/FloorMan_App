import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../components/responsive_text.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Daily_Summary extends StatefulWidget {
  const Daily_Summary({Key key}) : super(key: key);

  @override
  _Daily_SummaryState createState() => _Daily_SummaryState();
}

class _Daily_SummaryState extends State<Daily_Summary> {
  var tables = [];

  TextEditingController controllerTable = TextEditingController();
  TextEditingController controllerGame = TextEditingController();
  TextEditingController controllerBuyIn = TextEditingController();
  TextEditingController controllerStart = TextEditingController();
  TextEditingController controllerEnd = TextEditingController();
  TextEditingController controllerDuration = TextEditingController();
  TextEditingController controllerTip = TextEditingController();
  TextEditingController controllerTax = TextEditingController();

  TextEditingController controllerTable1 = TextEditingController();
  TextEditingController controllerGame1 = TextEditingController();
  TextEditingController controllerBuyIn1 = TextEditingController();
  TextEditingController controllerStart1 = TextEditingController();
  TextEditingController controllerEnd1 = TextEditingController();
  TextEditingController controllerDuration1 = TextEditingController();
  TextEditingController controllerTip1 = TextEditingController();
  TextEditingController controllerTax1 = TextEditingController();

  void create() async {
    if (controllerTable.text == '') {
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
                    Text("Please enter a table number"),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      var customer = ParseObject('daily_sum')
        ..set('Table', controllerTable.text)
        ..set('Game', controllerGame.text)
        ..set('Buy_in', controllerBuyIn.text)
        ..set('Start', controllerStart.text)
        ..set('End', controllerEnd.text)
        ..set('Duration', controllerDuration.text)
        ..set('Tip', controllerTip.text)
        ..set('Tax', controllerTax.text)
        ..set('day_date', DateTime.now());

      await customer.save();
    }
  }

  void delete(String formID) async {
    var deleteobj = ParseObject('daily_sum')..objectId = formID;
    await deleteobj.delete();
  }

  void edit(String formID) async {
    if (controllerTable1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('Table', controllerTable1.text);
      await customer.save();
    }
    if (controllerGame1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('Game', controllerGame1.text);
      await customer.save();
    }
    if (controllerBuyIn1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('Buy_in', controllerBuyIn1.text);
      await customer.save();
    }
    if (controllerStart1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('Start', controllerStart1.text);
      await customer.save();
    }
    if (controllerEnd1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('End', controllerEnd1.text);
      await customer.save();
    }
    if (controllerDuration1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('Duration', controllerDuration1.text);
      await customer.save();
    }
    if (controllerTip1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('Tip', controllerTip1.text);
      await customer.save();
    }
    if (controllerTax1.text != '') {
      var customer = ParseObject('daily_sum')
        ..objectId = formID
        ..set('Tax', controllerTax1.text);
      await customer.save();
    }
  }

  DateTime dateTodaySt;
  DateTime dateTodayEn;
  DateTime now = DateTime.now();

  void refresh() async {
    setState(() {
      dateTodaySt = DateTime(now.year, now.month, now.day, 9);
      dateTodayEn = DateTime(now.year, now.month, now.day, 4);
    });

    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('daily_sum'))
          ..whereGreaterThan('day_date', dateTodaySt)
          ..whereLessThan("day_date", dateTodayEn.add(Duration(days: 1)));

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
  }

  liveQuery() async {
    final LiveQuery liveQuery = LiveQuery();

    setState(() {
      dateTodaySt = DateTime(now.year, now.month, now.day, 9);
      dateTodayEn = DateTime(now.year, now.month, now.day, 4);
    });
    QueryBuilder<ParseObject> queryPost =
        QueryBuilder<ParseObject>(ParseObject('daily_sum'))
          ..whereGreaterThan('day_date', dateTodaySt)
          ..whereLessThan("day_date", dateTodayEn.add(Duration(days: 1)));

    var response = await queryPost.query();

    if (response.success) {
      if (response.results == null) {
        setState(() {
          tables = [''];
        });
      } else {
        setState(
          () {
            tables = response.results;
          },
        );
      }
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
        refresh();
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
        refresh();
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
        refresh();
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
        refresh();
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
        refresh();
      }
    });
  }

  Widget ifTable() {
    if (tables == null) {
      return DataTable2(
        columnSpacing: 0,
        horizontalMargin: 20,
        minWidth: 300,
        columns: [
          DataColumn2(
            label: Text('Table',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
            size: ColumnSize.L,
          ),
          DataColumn(
            label: Text('Game/Blind',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Buy In',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Start Time',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Finish Time',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Duration',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Tip',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Tax',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
        ],
        rows: [
          DataRow2(cells: [
            DataCell(TextField(
              controller: this.controllerTable,
              decoration: InputDecoration(
                hintText: 'Table',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerGame,
              decoration: InputDecoration(
                hintText: 'Game',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerBuyIn,
              decoration: InputDecoration(
                hintText: 'Buy in',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerStart,
              decoration: InputDecoration(
                hintText: 'Start',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerEnd,
              decoration: InputDecoration(
                hintText: 'End',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerDuration,
              decoration: InputDecoration(
                hintText: 'Duration',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerTip,
              decoration: InputDecoration(
                hintText: 'Tip',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerTax,
              decoration: InputDecoration(
                hintText: 'Tax',
              ),
            )),
          ])
        ],
      );
    } else {
      DataTable2(
        columnSpacing: 0,
        horizontalMargin: 20,
        minWidth: 300,
        columns: [
          DataColumn2(
            label: Text('Table',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
            size: ColumnSize.L,
          ),
          DataColumn(
            label: Text('Game/Blind',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Buy In',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Start Time',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Finish Time',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Duration',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Tip',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
          DataColumn(
            label: Text('Tax',
                style: TextStyle(
                    fontSize:
                        AdaptiveTextSize().getadaptiveTextSize(context, 10))),
          ),
        ],
        rows: [
          for (var table in tables)
            DataRow2(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Edit'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Text('Table:'),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: this.controllerTable1,

                                    //  controller: this.controllerTable = table['Table'],
                                    decoration: InputDecoration(
                                      hintText: table['Table'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Game:'),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: this.controllerGame1,
                                    decoration: InputDecoration(
                                      hintText: table['Game'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                Text('Buy in'),
                                SizedBox(
                                  width: 32,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: this.controllerBuyIn1,
                                    decoration: InputDecoration(
                                      hintText: table['Buy_in'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                Text('Start Time:'),
                                SizedBox(
                                  width: 32,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: this.controllerStart1,
                                    decoration: InputDecoration(
                                      hintText: table['Start'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Finish Time:'),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: this.controllerEnd1,
                                    decoration: InputDecoration(
                                      hintText: table['End'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Duration'),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: this.controllerDuration1,
                                    decoration: InputDecoration(
                                      hintText: table['Duration'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Tip:'),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: this.controllerTip1,
                                    decoration: InputDecoration(
                                      hintText: table['Tip'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Tax:'),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: this.controllerTax1,
                                    decoration: InputDecoration(
                                      hintText: table['Tax'],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green[800]),
                              child: Text(
                                "Apply Changes",
                              ),
                              onPressed: () async {
                                await edit(table['objectId']);
                                Navigator.pop(context);
                                controllerTable1.clear();
                                controllerGame1.clear();
                                controllerBuyIn1.clear();
                                controllerStart1.clear();
                                controllerEnd1.clear();
                                controllerDuration1.clear();
                                controllerTip1.clear();
                                controllerTax1.clear();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green[800]),
                              child: Text(
                                "Delete",
                              ),
                              onPressed: () {
                                delete(table['objectId']);
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              cells: [
                DataCell(
                  Text(table['Table'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(table['Game'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(table['Buy_in'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text((table['Start']),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text((table['End']),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(table['Duration'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(table['Tip'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
                DataCell(
                  Text(table['Tax'].toString(),
                      style: TextStyle(
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 10))),
                ),
              ],
            ),
          DataRow2(cells: [
            DataCell(TextField(
              controller: this.controllerTable,
              decoration: InputDecoration(
                hintText: 'Table',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerGame,
              decoration: InputDecoration(
                hintText: 'Game',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerBuyIn,
              decoration: InputDecoration(
                hintText: 'Buy in',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerStart,
              decoration: InputDecoration(
                hintText: 'Start',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerEnd,
              decoration: InputDecoration(
                hintText: 'End',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerDuration,
              decoration: InputDecoration(
                hintText: 'Duration',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerTip,
              decoration: InputDecoration(
                hintText: 'Tip',
              ),
            )),
            DataCell(TextField(
              controller: this.controllerTax,
              decoration: InputDecoration(
                hintText: 'Tax',
              ),
            )),
          ])
        ],
      );
    }
  }

  @override
  void initState() {
    liveQuery();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.redo),
            onPressed: () {
              refresh();
            },
          ),
        ],
        backgroundColor: Colors.green[800],
        title: Text(
          "Today\'s Summary",
        ),
      ),
      body: ifTable(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[800],
          child: Icon(
            FontAwesomeIcons.plus,
            color: Colors.white,
          ),
          onPressed: () async {
            await create();
            refresh();
            controllerTable.clear();
            controllerGame.clear();
            controllerBuyIn.clear();
            controllerStart.clear();
            controllerEnd.clear();
            controllerDuration.clear();
            controllerTip.clear();
            controllerTax.clear();
          }),
    ));
  }
}
