import 'package:floor_manager/screens/table_screen.dart';
import 'package:flutter/material.dart';
import 'table_screen.dart';

class CasinoLayOut extends StatefulWidget {
  const CasinoLayOut({Key key}) : super(key: key);

  @override
  _CasinoLayOutState createState() => _CasinoLayOutState();
}

class _CasinoLayOutState extends State<CasinoLayOut> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: Text('Layout'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                GestureDetector(
                  child: Hero(
                      tag: 'table1',
                      child: Image.asset('assets/images/Table.jpg')),
                  onTap: () {
                    setState(
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return TablePage(
                                tableNum: 1,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                GestureDetector(
                  child: Hero(
                      tag: 'table1',
                      child: Image.asset('assets/images/Table.jpg')),
                  onTap: () {
                    setState(
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return TablePage(
                                tableNum: 2,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
