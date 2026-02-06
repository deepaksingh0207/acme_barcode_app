import 'login.dart';
import 'package:acme/api.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final iptEmployeeId = TextEditingController(text: "20000");
  final iptPassword = TextEditingController(text: "12345678");
  final iptName = TextEditingController(text: "Willam Smith");
  final iptMobile = TextEditingController(text: "9876543210");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.png", // your bg image
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 10),
                          
                          Image.asset(
                            "assets/images/acme_dark.png",
                            height: 180,
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 10),
                          
                          Text(
                            "Enter your credentials to continue",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 30),

                          TextField(
                            controller: iptEmployeeId,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: "Employee ID",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 15),

                          TextField(
                            controller: iptName,
                            decoration: InputDecoration(
                              labelText: "Name",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 15),

                          TextField(
                            controller: iptMobile,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              labelText: "Mobile",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 15),

                          TextField(
                            controller: iptPassword,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2F82C3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      setState(() => _isLoading = true);
                                      final employeeId = iptEmployeeId.text
                                          .trim();
                                      final name = iptName.text.trim();
                                      final mobile = iptMobile.text.trim();
                                      final password = iptPassword.text.trim();

                                      try {
                                        final result =
                                            await RegisterAPI.register(
                                              name: name,
                                              employeeId: employeeId,
                                              mobile: mobile,
                                              password: password,
                                            );

                                        if (result["STATUS"] == "S") {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => LoginScreen(),
                                            ),
                                          );
                                        } else {
                                          DialogHelper.showMessage(
                                            context,
                                            title: "Error",
                                            message:
                                                result["MESSAGE"] ??
                                                "Login failed",
                                          );
                                        }
                                      } catch (e) {
                                        DialogHelper.showMessage(
                                          context,
                                          title: "Error",
                                          message: e.toString(),
                                        );
                                      } finally {
                                        setState(() => _isLoading = false);
                                      }
                                    },
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
