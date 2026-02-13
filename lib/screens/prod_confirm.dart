import 'package:acme/api.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/login.dart';
import 'package:acme/screens/dashboard.dart';
import 'package:acme/screens/change_password.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProdConfirmScreen extends StatefulWidget {
  @override
  ProdConfirmState createState() => ProdConfirmState();
}

class ProdConfirmState extends State<ProdConfirmScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> scanSessions = [];
  final TextEditingController iptBarcode = TextEditingController();
  final api = ProductionConfirmationScreenAPI();

  @override
  void initState() {
    super.initState();

    PM75Scanner.init((qrCode) async {
      if (!mounted || _isLoading) return;
      if (qrCode == "READ_FAIL") return;

      iptBarcode.text = qrCode;
      await _getQrInfo(barCode: qrCode);
    });
  }

  bool _barcodeExists(String barcode) {
    for (final session in scanSessions) {
      if (session["huno"] == barcode) return true;
    }
    return false;
  }

  Future<void> _getQrInfo({String barCode = "", bool isDelete = false}) async {
    setState(() => _isLoading = true);

    try {
      if (barCode.isEmpty) barCode = iptBarcode.text.trim();
      if (barCode.isEmpty) {
        _isLoading = false;
        return;
      }

      final result = await api.scan(barcode: barCode, delete: isDelete);
      if (result.status != "S") {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
        _isLoading = false;
        return;
      }

      if (isDelete) {
        _isLoading = false;
        return;
      }

      if (_barcodeExists(barCode)) {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: "Barcode already scanned",
        );
        _isLoading = false;
        return;
      }

      scanSessions.add({
        "barcodes": result.barcode,
        "huno": result.huno,
        "aufnr": result.aufnr,
        "maktx": result.maktx,
        "matnr": result.matnr,
      });
    } catch (e) {
      DialogHelper.showMessage(context, title: "Error", message: e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteBarcode(int sessionIndex, int barcodeIndex) async {
    final barcode = scanSessions[sessionIndex]["barcodes"][barcodeIndex];
    final result = await api.scan(barcode: barcode, delete: true);

    if (result.status != "S") {
      DialogHelper.showMessage(
        context,
        title: "Error",
        message: result.message,
      );
      return;
    }

    setState(() {
      scanSessions[sessionIndex]["barcodes"].removeAt(barcodeIndex);

      if (scanSessions[sessionIndex]["barcodes"].isEmpty) {
        scanSessions.removeAt(sessionIndex);
      }
    });
  }

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
                  itemCount: scanSessions[sessionIndex]["barcodes"].length,
                  itemBuilder: (_, i) {
                    final barcode = scanSessions[sessionIndex]["barcodes"][i];

                    return ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _deleteBarcode(sessionIndex, i);
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

  Future<void> _confirmProduction() async {
    setState(() => _isLoading = true);
    List<Map<String, String>> aufnrlist = scanSessions
        .where((s) => s["aufnr"] != null)
        .map((s) => {"AUFNR": s["aufnr"].toString()})
        .toList();
    try {
      final result = await api.confirm(aufnrList: aufnrlist);
      if (result.status == "S") {
        setState(() {
          scanSessions.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message,
                style: TextStyle(
                  color: Color(0xFF333D79),
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Color(0xFFFAEBEF),
              behavior: SnackBarBehavior.floating,
              elevation: 0,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Dashboard()),
          );
        }
      } else {
        if (mounted) {
          DialogHelper.showMessage(
            context,
            title: "Error",
            message: result.message.isNotEmpty
                ? result.message
                : "Confirm failed",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    iptBarcode.dispose();
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
                        SvgPicture.asset(
                          "assets/images/acme_dark.svg",
                          height: 50,
                        ),
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
                          itemBuilder: (_) => const [
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

                    const SizedBox(height: 20),

                    const Text(
                      "Production Order Receipt",
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
                            controller: iptBarcode,
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
                            onTap: () => _showBarcodePopup(index),
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "HUNO: ${session["huno"]}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text("ORDER NO.: ${session["aufnr"]}"),
                                        const SizedBox(height: 4),
                                        Text(
                                          "MATERIAL CODE: ${session["matnr"]}",
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "MATERIAL DESCRIPTION: ${session["maktx"]}",
                                        ),
                                      ],
                                    ),
                                    CircleAvatar(
                                      child: Text(
                                        session["barcodes"].length.toString(),
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
              child: const Text("Confirm Production"),
            ),
          ),
        ),
      ),
    );
  }
}
