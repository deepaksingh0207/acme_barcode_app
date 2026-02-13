import 'login.dart';
import 'change_password.dart';
import 'package:acme/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfileScreen> {
  String barcode = "No barcode scanned";

  String? employeeId;
  String? employeeName;
  String? employeeEmail;
  String? employeeMobile;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final id = await SessionManager.getEmployeeId();
    final name = await SessionManager.getEmployeeName();
    final email = await SessionManager.getEmployeeEmail();
    final mobile = await SessionManager.getEmployeeMobile();

    setState(() {
      employeeId = id;
      employeeName = name;
      employeeEmail = email;
      employeeMobile = mobile;
    });
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          } else if (value == "profile") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangePassword(),
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

                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 56, 87, 141),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "NAME    : ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(text: employeeName),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 10),

                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "MOBILE : ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(text: employeeMobile),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 10),

                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "EMP ID  : ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(text: employeeId),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
