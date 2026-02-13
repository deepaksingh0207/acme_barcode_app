import 'login.dart';
import 'change_password.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/scrap.dart';
import 'package:acme/screens/rework.dart';
import 'package:acme/screens/replace.dart';
import 'package:acme/screens/profile.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                  MaterialPageRoute(builder: (_) => ReplaceScreen()),
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Do you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), // ✅ return true
                child: const Text("Yes"),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
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
                        SvgPicture.asset(
                          "assets/images/acme_dark.svg",
                          height: 50,
                        ),
                        PopupMenuButton<String>(
                          icon: CircleAvatar(
                            backgroundColor: Color(0xFF2F82C3),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          onSelected: (value) {
                            if (value == "logout") {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                                (route) => false,
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
                            PopupMenuItem(
                              value: "logout",
                              child: Text("Logout"),
                            ),
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
                                        "assets/images/barcode-informantion.png",
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
                                        "assets/images/sales-return.png",
                                        height: 50,
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
                                        "assets/images/production-confirm.png",
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
                                        "assets/images/delivery.png",
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
                                        "assets/images/rework.png",
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
      ),
    );
  }
}
