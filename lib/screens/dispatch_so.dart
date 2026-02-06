import 'package:acme/api.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/login.dart';
import 'package:acme/screens/dashboard.dart';
import 'package:acme/screens/change_password.dart';

class DispatchSOScreen extends StatefulWidget {
  @override
  DispatchSOState createState() => DispatchSOState();
}

class DispatchSOState extends State<DispatchSOScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> scanSessions = [];
  final TextEditingController iptSono = TextEditingController(
    text: "0000000001",
  );
  final api = DispatchAPI();
  int? activeItemId;
  bool _lock = false;

  @override
  void initState() {
    super.initState();
    PM75Scanner.init((qrCode) async {
      if (!mounted || _isLoading) return;
      if (qrCode == "READ_FAIL") return;
      if (activeItemId == null) return;
      if (ignoreOnSaturate()) return;
      if (_lock) {
        await _getScanInfo(sono: qrCode);
      } else {
        await _getSOInfo(sono: qrCode);
      }
    });
  }

  Future<void> _getScanInfo({String sono = ""}) async {
    setState(() => _isLoading = true);
    final item = scanSessions[activeItemId!];
    final int dispatchQty = double.parse(item["ZMENG"].toString()).toInt();

    try {
      final result = await api.soScan(soNo: sono);

      if (result.status != "S") {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
        return;
      }
      final barcodes = item["barcodes"] ?? [];
      if ((result.barcode.length + barcodes.length) <= dispatchQty) {
        setState(() {
          item["barcodes"].add(result.barcode);
          item["hunos"].add(result.huno);
        });
      } else {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: "Quantity Exceeds Max Capacity",
        );
        return;
      }
    } catch (e) {
      DialogHelper.showMessage(context, title: "Error", message: e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getSOInfo({String sono = ""}) async {
    setState(() => _isLoading = true);
    try {
      if (sono == "") {
        sono = iptSono.text;
      }
      final result = await api.so(soNo: sono);

      if (result.status != "S") {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
        return;
      }
      scanSessions = result.bcList.map((e) {
        return {...e, "barcode": <String>[], "huno": <String>[]};
      }).toList();
      setState(() => _lock = true);
    } catch (e) {
      DialogHelper.showMessage(context, title: "Error", message: e.toString());
    }

    if (mounted) setState(() => _isLoading = false);
  }

  bool ignoreOnSaturate() {
    final item = scanSessions[activeItemId!];
    final int dispatchQty = double.parse(item["ZMENG"].toString()).toInt();
    final barcodes = item["barcodes"] ?? [];
    if (barcodes.length >= dispatchQty) {
      DialogHelper.showMessage(
        context,
        title: "Limit reached",
        message: "Dispatch quantity already fulfilled",
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    iptSono.dispose();
    super.dispose();
  }

  Widget _buildProgress(int id, Map item) {
    final item = scanSessions[id];
    final dispatchQty = double.parse(item["ZMENG"].toString()).toInt();
    final barcodes = item["barcodes"] ?? [];
    double progress = 0.0;
    if (barcodes.length > 0) {
      progress = barcodes.length / dispatchQty;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 55,
          height: 55,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade300,
            color: progress >= 1 ? Colors.green : Colors.blue,
          ),
        ),
        Text(
          (barcodes.length).toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
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
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/bg.png", fit: BoxFit.cover),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/images/acme_dark.png", height: 40),
                        PopupMenuButton<String>(
                          icon: const CircleAvatar(
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
                            } else if (value == "password") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangePassword(),
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
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

                    const SizedBox(height: 20),

                    const Text(
                      "Dispatch SO",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38578D),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: iptSono,
                            decoration: const InputDecoration(
                              labelText: "Enter SO",
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

                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView.builder(
                        itemCount: scanSessions.length,
                        itemBuilder: (_, index) {
                          final session = scanSessions[index];
                          final bool isActive = activeItemId == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() => activeItemId = index);
                            },
                            child: Card(
                              color: isActive
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: "Party Code: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${session["POSNR"]}",
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: "Sales Order No: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${session["VBELN"]}",
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: "Dispatch Qty: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${session["ZMENG"]} ${session["ZIEME"]}",
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 4),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Description",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${session["MAKTX"]}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildProgress(index, session),
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
      ),
    );
  }
}
