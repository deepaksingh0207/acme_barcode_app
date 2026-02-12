import 'login.dart';
import 'change_password.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/scrap.dart';
import 'package:acme/screens/rework.dart';
import 'package:acme/screens/profile.dart';
import 'package:acme/screens/dispatch_so.dart';
import 'package:acme/screens/barcode_info.dart';
import 'package:acme/screens/prod_confirm.dart';
import 'package:acme/screens/dispatch_delivery.dart';

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  String barcode = "No barcode scanned";

  void _showDispatchOptions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose Dispatch Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Sales Order"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DispatchSOScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Delivery"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DispatchDeliveryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text("STO"),
              onTap: () {
                // Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => DispatchSTOScreen()),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRRSOptions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose Dispatch Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Rework"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReworkScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Replace"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DispatchDeliveryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text("Scrap"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ScrapScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/bg.png", fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/images/acme_dark.png", height: 40),
                      PopupMenuButton<String>(
                        icon: CircleAvatar(
                          backgroundColor: Color(0xFF2F82C3),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        onSelected: (value) {
                          if (value == "logout") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          } else if (value == "profile") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(),
                              ),
                            );
                          } else if (value == "password") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangePassword(),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "profile",
                            child: Text("Profile"),
                          ),
                          PopupMenuItem(
                            value: "password",
                            child: Text("Change Password"),
                          ),
                          PopupMenuItem(value: "logout", child: Text("Logout")),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HUScanScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 120,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/barcode-scanner.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Barcode Info",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HUScanScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 120,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/barcode-scanner.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Sales Return",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProdConfirmScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 120,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/manufacturing.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Production Confirm",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showDispatchOptions();
                            },
                            child: Container(
                              height: 120,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/dispatch.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Dispatch SO / Delivery / STO",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showRRSOptions();
                            },
                            child: Container(
                              height: 120,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Image.asset(
                                      "assets/images/dispatch.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Rework / Replace / Scrap",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
