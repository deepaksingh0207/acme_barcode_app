import 'signup.dart';
import 'dashboard.dart';
import 'forgot_password.dart';
import 'package:acme/api.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final iptEmployeeId = TextEditingController();
  final iptPassword = TextEditingController();
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
                          SizedBox(height: 30),
                          
                          SvgPicture.asset(
                            "assets/images/acme_dark.svg",
                            height: 150,
                          ),
                          
                          SizedBox(height: 50),
                          
                          Text(
                            "Log in to access your account",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),

                          SizedBox(height: 30),

                          Row(
                            children: const [
                              Icon(
                                Icons.badge_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Employee ID",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          TextField(
                            controller: iptEmployeeId,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: "Enter your Employee ID",
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

                          SizedBox(height: 30),

                          Row(
                            children: const [
                              Icon(Icons.lock, size: 18, color: Colors.grey),
                              SizedBox(width: 6),
                              Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          TextField(
                            controller: iptPassword,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Enter your Password",
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

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Color(0xFF2F82C3)),
                              ),
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
                            height: 80,
                            child: ElevatedButton(
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
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 70,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2F82C3),
                                      Color(0xFF1DD47D),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          Text(
                            "Don’t have an account?",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF606060),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(
                                    fontSize: 20,
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
