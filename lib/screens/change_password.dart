import 'package:acme/api.dart';
import 'package:acme/screens/dashboard.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  bool _newObscure = true;
  bool _isLoading = false;
  final iptPassword = TextEditingController();

  String? employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    final id = await SessionManager.getEmployeeId();
    setState(() {
      employeeId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (employeeId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                          SizedBox(height: 60),
                          Image.asset(
                            "assets/images/acme_dark.png",
                            height: 180,
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 20),

                          _passwordField(
                            "New Password",
                            iptPassword,
                            _newObscure,
                            () => setState(() => _newObscure = !_newObscure),
                          ),

                          SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
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
                                      final password = iptPassword.text.trim();

                                      try {
                                        final result =
                                            await ResetPasswordAPI.reset(
                                              employeeId: employeeId!,
                                              password: password,
                                            );

                                        if (result["STATUS"] == "S") {
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
                                            message:
                                                result["MESSAGE"] ??
                                                "Password Change failed",
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
                                "Update Password",
                                style: TextStyle(color: Colors.white),
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

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
    );
  }
}
