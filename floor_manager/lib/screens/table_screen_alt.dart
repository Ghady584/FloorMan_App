import 'dart:convert';
import 'dart:developer';

import 'package:floor_manager/paints/chair.dart';
import 'package:floor_manager/paints/table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TableScreenAlt extends StatefulWidget {
  var tableData;
  TableScreenAlt({this.tableData});

  @override
  _TableScreenAltState createState() => _TableScreenAltState();
}

class _TableScreenAltState extends State<TableScreenAlt> {
  List _chairs = [];

  @override
  void initState() {
    super.initState();
    this.readJson();
    log(_chairs.toString());
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/layouts/chairs10.json');
    final data = await json.decode(response);
    setState(() {
      _chairs = data["chairs"];
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var tableWidth = MediaQuery.of(context).size.height / 2;

    List _items = [
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
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Text(widget.tableData["name"]),
      ),
      body: Container(
        child: Row(
          children: [
            _items.length > 0
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey[100],
                          margin: EdgeInsets.all(2),
                          elevation: 0,
                          child: ListTile(
                            // tileColor: Colors.grey[100],
                            leading: Draggable(
                              data: _items[index]["name"],
                              child: CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.red)),
                              feedback: CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.red)),
                              childWhenDragging: CircleAvatar(
                                  backgroundColor: Colors.grey[600],
                                  child: Icon(Icons.person, color: Colors.red)),
                              dragAnchor: DragAnchor.pointer,
                            ),
                            title: Text(_items[index]["name"]),
                            subtitle: Text(_items[index]["description"]),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
            SizedBox(
              height: height / 1.5,
              child: Stack(
                  // clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: widget.tableData["name"],
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
                                              backgroundColor: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.green,
                                                size: 300 / 6,
                                              )),
                                        )
                                      : Draggable(
                                          data: chair["user"],
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
                                              backgroundColor: Colors.grey[300],
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
                                    chair["user"] = "test";
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              data + " added successfully!")));
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
                                    chair["user"] = "test";
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              data + " added successfully!")));
                                },
                              ),
                      )
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
