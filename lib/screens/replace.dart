import 'package:acme/api.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/login.dart';
import 'package:acme/screens/dashboard.dart';
import 'package:acme/screens/change_password.dart';

class ReplaceScreen extends StatefulWidget {
  @override
  ReplaceState createState() => ReplaceState();
}

class ReplaceState extends State<ReplaceScreen> {
  bool _isLoading = false;
  String? _huno;
  String? _aufnr;
  String? _maktx;
  String? _matnr;
  String? selectedBarcode;
  List<String> _respBarcodes = [];

  final iptOldBarcode = TextEditingController();
  final iptBarcode = TextEditingController();
  final api = ReplaceScreenAPI();

  @override
  void initState() {
    super.initState();

    PM75Scanner.init((qrCode) async {
      if (!mounted) return;
      if (_isLoading) return;
      if (qrCode == "READ_FAIL") return;
      setState(() => iptOldBarcode.text = qrCode);
      await _getQrInfo(barCode: qrCode);
    });
  }

  Future<void> _getQrInfo({String barCode = "", bool isDelete = false}) async {
    setState(() => _isLoading = true);
    try {
      if (barCode == "") {
        barCode = iptOldBarcode.text;
      }
      final result = await api.soInfo(soNo: barCode);
      if (result.status != "S") {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
      }
      setState(() {
        _respBarcodes = result.barcode;
        _huno = result.huno;
        _aufnr = result.aufnr;
        _matnr = result.matnr;
        _maktx = result.maktx;
      });
    } catch (e) {
      DialogHelper.showMessage(context, title: "Error", message: e.toString());
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmProduction() async {
    if (iptBarcode.text == "") return;
    if (selectedBarcode!.isEmpty) {
      DialogHelper.showMessage(
        context,
        title: "Warning",
        message: "Please select a barcode for rework",
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final result = await api.rework(
        oldBarcode: selectedBarcode!,
        barcode: iptBarcode.text,
      );

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
    iptOldBarcode.dispose();
    super.dispose();
  }

  void _showBarcodePopup() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Scanned Barcodes"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: _respBarcodes.length,
                  itemBuilder: (context, i) {
                    final item = _respBarcodes[i];

                    final isSelected = selectedBarcode == item;

                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedBarcode = item;
                        });
                      },
                      child: Card(
                        elevation: 2,
                        color: isSelected ? Colors.indigo : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
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
                      "Replace",
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
                            controller: iptOldBarcode,
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

                    SizedBox(height: 20),

                    if (_respBarcodes.isNotEmpty)
                      GestureDetector(
                        onTap: _showBarcodePopup,
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

                                    const SizedBox(height: 6),

                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Material Code: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(text: _matnr),
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
                                            text: "Material Description: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(text: _maktx),
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

                    SizedBox(height: 50),

                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 10),

                    Expanded(
                      child: TextField(
                        controller: iptBarcode,
                        decoration: const InputDecoration(
                          labelText: "Enter / Scan Replace Barcode",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.indigo),
                          ),
                        ),
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
              child: const Text("Replace"),
            ),
          ),
        ),
      ),
    );
  }
}
