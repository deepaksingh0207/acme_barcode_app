import 'signup.dart';
import 'dashboard.dart';
import 'forgot_password.dart';
import 'package:acme/api.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final iptEmployeeId = TextEditingController(text: "1992");
  final iptPassword = TextEditingController(text: "12345678");
  final api = LoginScreenAPI();

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(left: 24, right: 24),
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
                            "Login",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 10),
                          Text(
                            "Enter your email and password",
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

                          SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              child: Text("Forgot Password?"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordScreen(),
                                  ),
                                );
                              },
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
                                      final password = iptPassword.text.trim();

                                      try {
                                        final result = await api.login(
                                          employeeId: employeeId,
                                          password: password,
                                        );

                                        if (result.status == "S") {
                                          await SessionManager.saveEmployeeId(
                                            employeeId,
                                            result.mobile,
                                            result.email,
                                            result.name,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                result.message,
                                                style: TextStyle(
                                                  color: Color(0xFF333D79),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              backgroundColor: Color(
                                                0xFFFAEBEF,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              elevation: 0,
                                            ),
                                          );
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => Dashboard(),
                                            ),
                                          );
                                        } else {
                                          DialogHelper.showMessage(
                                            context,
                                            title: "Error",
                                            message: result.message,
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
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don’t have an account? "),
                              GestureDetector(
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
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
