import 'package:acme/api.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/login.dart';
import 'package:acme/screens/dashboard.dart';
import 'package:acme/screens/change_password.dart';

class ReworkScreen extends StatefulWidget {
  @override
  ReworkState createState() => ReworkState();
}

class ReworkState extends State<ReworkScreen> {
  bool _isLoading = false;
  int? activeItemId;
  String? _huno;
  String? _aufnr;
  List<Map<String, dynamic>> _respBarcodes = [];

  final iptSono = TextEditingController(text: "1000000036359");
  final api = ReworkAPI();

  @override
  void initState() {
    super.initState();

    PM75Scanner.init((qrCode) async {
      if (qrCode == "READ_FAIL") return;
      if (!mounted || _isLoading) return;
      await _getSOInfo(sono: qrCode);
    });
  }

  Future<void> _getSOInfo({String sono = ""}) async {
    setState(() => _isLoading = true);
    try {
      if (sono == "") {
        sono = iptSono.text;
      }
      final result = await api.soInfo(soNo: sono);
      if (result.status != "S") {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
      } else {
        setState(() {
          _huno = result.huno;
          _aufnr = result.aufnr;
          iptSono.text = sono;

          _respBarcodes = result.barcode.map<Map<String, dynamic>>((e) {
            return {"value": e, "selected": false};
          }).toList();
        });
      }
    } catch (e) {
      DialogHelper.showMessage(context, title: "Error", message: e.toString());
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmProduction() async {
    final selected = _respBarcodes.firstWhere(
      (e) => e["selected"] == true,
      orElse: () => {},
    );

    if (selected.isEmpty) {
      DialogHelper.showMessage(
        context,
        title: "Warning",
        message: "Please select a barcode for rework",
      );
      return;
    }

    final selectedBarcode = selected["value"];

    setState(() => _isLoading = true);

    try {
      final result = await api.rework(barcode: selectedBarcode);

      if (result.status == "S") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));
      } else {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    iptSono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Dashboard()),
        );
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
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
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
                            PopupMenuItem(
                              value: "logout",
                              child: Text("Logout"),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Text(
                      "Rework",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 56, 87, 141),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: iptSono,
                            decoration: const InputDecoration(
                              labelText: "Enter / Scan Barcode",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        SizedBox(
                          height: 48,
                          width: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isLoading ? null : _getSOInfo,
                            child: const Icon(Icons.qr_code_scanner),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    if (_respBarcodes.isNotEmpty)
                      GestureDetector(
                        // onTap: _showBarcodePopup,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
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
                                            text: "HU No: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(text: _huno),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Production Order No.: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(text: _aufnr),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                CircleAvatar(
                                  radius: 22,
                                  child: Text(
                                    _respBarcodes.length.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (_respBarcodes.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _respBarcodes.length,
                          itemBuilder: (context, i) {
                            final item = _respBarcodes[i];

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  // clear previous selection
                                  for (var e in _respBarcodes) {
                                    e["selected"] = false;
                                  }
                                  // select only this one
                                  item["selected"] = true;
                                });
                              },
                              child: Card(
                                elevation: 2,
                                color: item["selected"]
                                    ? Colors.indigo.withOpacity(0.18)
                                    : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item["selected"]
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: item["selected"]
                                            ? Colors.indigo
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        item["value"],
                                        style: const TextStyle(fontSize: 14),
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
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _confirmProduction,
              child: const Text("Post for Rework"),
            ),
          ),
        ),
      ),
    );
  }
}
