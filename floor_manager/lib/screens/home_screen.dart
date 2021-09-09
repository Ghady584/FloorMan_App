import 'package:floor_manager/screens/casino_layout.dart';
import 'package:floor_manager/screens/casino_layout_alt.dart';
import 'package:floor_manager/screens/waiting_list.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import '../main.dart';
import '../components/reusable_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/icon_content.dart';
import 'casino_layout.dart';
import '../screens/registration_list.dart';
import '../components/responsive_text.dart';
import 'daily_summary.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ParseUser currentUser;

  Future<ParseUser> getUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser;
    return currentUser;
  }

  @override
  Widget build(BuildContext context) {
    void doUserLogout() async {
      var response = await currentUser.logout();
      if (response.success) {
        Message.showSuccess(
            context: context,
            message: 'User was successfully logout!',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            });
      } else {
        Message.showError(context: context, message: response.error.message);
      }
    }

    final deviceOrientation = MediaQuery.of(context).orientation;
    print(deviceOrientation);
    if (deviceOrientation == Orientation.portrait) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: Text('Welcome'),
        ),
        body: FutureBuilder<ParseUser>(
          future: getUser(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()),
                );
                break;
              default:
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/logo.jpg",
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.list,
                                  label: ('Today\'s Registrations'),
                                ),
                              ),
                              onTap: () {
                                setState(
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return RegistrationList();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.chair,
                                  label: ('Pokerroom overview'),
                                ),
                              ),
                              onTap: () {
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
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Daily_Summary();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.file,
                                  label: ('Daily summary'),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return WaitingList();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.listAlt,
                                  label: ('Waiting List'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green[800]),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AdaptiveTextSize()
                                      .getadaptiveTextSize(context, 10)),
                            ),
                          ),
                          onPressed: () => doUserLogout(),
                        ),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: Text('Welcome'),
        ),
        body: FutureBuilder<ParseUser>(
          future: getUser(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()),
                );
                break;
              default:
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/logo.jpg",
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.list,
                                  label: ('Today\'s Registrations'),
                                ),
                              ),
                              onTap: () {
                                setState(
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return RegistrationList();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.chair,
                                  label: ('Pokerroom overview'),
                                ),
                              ),
                              onTap: () {
                                setState(
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CasinoLayOut();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Daily_Summary();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.file,
                                  label: ('Daily summary'),
                                ),
                              ),
                            ),
                          ),
                          /*    Expanded(
                            child: GestureDetector(
                              child: ReusableCard(
                                color: Colors.green[800],
                                cardChild: IconContent(
                                  icon: FontAwesomeIcons.cog,
                                  label: ('Settings'),
                                ),
                              ),
                            ),
                          ),*/
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green[800]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AdaptiveTextSize()
                                      .getadaptiveTextSize(context, 16)),
                            ),
                          ),
                          onPressed: () => doUserLogout(),
                        ),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      );
    }
  }
}
