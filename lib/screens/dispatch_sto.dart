import 'package:acme/api.dart';
import 'package:acme/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/login.dart';
import 'package:acme/screens/change_password.dart';

class DispatchSTOScreen extends StatefulWidget {
  @override
  DispatchSTOState createState() => DispatchSTOState();
}

class DispatchSTOState extends State<DispatchSTOScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> scanSessions = [
    {
      "sales_order_no": "123456",
      "party_code": "123456",
      "desc":
          "Lorem Ipsum is simply dummy text of the printing and typesetting",
      "dispatch_qty": "6",
    },
  ];
  final TextEditingController iptSono = TextEditingController(text: "1");
  final api = DispatchAPI();

  @override
  void initState() {
    super.initState();

    PM75Scanner.init((qrCode) async {
      if (!mounted || _isLoading) return;
      if (qrCode == "READ_FAIL") return;

      iptSono.text = qrCode;
      await _getQrInfo(sono: qrCode);
    });
  }

  Future<void> _getQrInfo({String sono = ""}) async {
    setState(() => _isLoading = true);

    try {
      if (sono.isEmpty) sono = iptSono.text.trim();
      final result = await api.so(soNo: sono);

      if (result.status != "S") {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
        return;
      }
      scanSessions.add({
        "huno": result.huno,
        "aufnr": result.aufnr,
        "barcodes": result.barcode,
      });
    } catch (e) {
      DialogHelper.showMessage(context, title: "Error", message: e.toString());
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // Future<void> _deleteBarcode(int sessionIndex, int barcodeIndex) async {
  //   final barcode = scanSessions[sessionIndex]["barcodes"][barcodeIndex];

  //   final result = await api.scan(barcode: barcode, delete: true);

  //   if (result.status != "S") {
  //     DialogHelper.showMessage(
  //       context,
  //       title: "Error",
  //       message: result.message,
  //     );
  //     return;
  //   }

  //   setState(() {
  //     scanSessions[sessionIndex]["barcodes"].removeAt(barcodeIndex);

  //     if (scanSessions[sessionIndex]["barcodes"].isEmpty) {
  //       scanSessions.removeAt(sessionIndex);
  //     }
  //   });
  // }

  void _showBarcodePopup(int sessionIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Scanned Barcodes"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: scanSessions[sessionIndex]["dispatch_qty"],
                  itemBuilder: (_, i) {
                    final barcode =
                        scanSessions[sessionIndex]["dispatch_qty"][i];

                    return ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // await _deleteBarcode(sessionIndex, i);
                          setDialogState(() {});
                        },
                      ),
                      title: Text(barcode),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
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
                      "Dispatch STO",
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
                            onPressed: _isLoading ? null : _getQrInfo,
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

                          return GestureDetector(
                            // onTap: () => _showBarcodePopup(index),
                            child: Card(
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
                                                  text: "Purchase Order No: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${session["sales_order_no"]}",
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
                                                  text: "Delivery No: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${session["sales_order_no"]}",
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
                                                  text:
                                                      "Supplying Plant / To Plant: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${session["sales_order_no"]}",
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
                                                  text: "Pick Qty: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${session["party_code"]}",
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
                                                  text: "Description: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${session["desc"]}",
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
                                                      "${session["dispatch_qty"]}",
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CircleAvatar(
                                      child: Text(session["dispatch_qty"]),
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
      ),
    );
  }
}
