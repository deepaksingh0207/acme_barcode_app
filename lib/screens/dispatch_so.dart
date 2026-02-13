import 'dart:async';
import 'package:acme/api.dart';
import 'package:flutter/material.dart';
import 'package:acme/screens/login.dart';
import 'package:acme/screens/dashboard.dart';
import 'package:acme/screens/change_password.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DispatchSOScreen extends StatefulWidget {
  @override
  DispatchSOState createState() => DispatchSOState();
}

class DispatchSOState extends State<DispatchSOScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> scanSessions = [];
  int? activeItemId;
  String? employeeId;
  bool _lock = false;
  List<String> soList = [];

  final iptSono = TextEditingController();
  final iptHuno = TextEditingController();
  final api = DispatchSOScreenAPI();

  Future<void> _loadEmployee() async {
    final id = await SessionManager.getEmployeeId();
    setState(() {
      employeeId = id;
    });
    setState(() => _isLoading = true);
    final result = await api.soList(appUser: employeeId!);
    soList = result.soList;
    if (mounted) setState(() => _isLoading = false);
  }

  void _openHunoPopup(int idx) {
    setState(() => activeItemId = idx);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hunoList = scanSessions[idx]["huno"] as List;

            return AlertDialog(
              title: const Text("Scanned HUNO"),

              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🔤 Input + Add Button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: iptHuno,
                            decoration: const InputDecoration(
                              hintText: "Enter HUNO",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _getScanInfo,
                          child: const Text("Add"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// 📋 Scrollable list (compact height)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: hunoList.length,
                        itemBuilder: (_, i) {
                          final huno = hunoList[i];

                          return ListTile(
                            title: Text(huno),
                            leading: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final hunoToDelete = hunoList[i];

                                // Optional: show loader dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                final result = await api.dispatchDeleteScan(
                                  soNo: scanSessions[idx]["VBELN"],
                                  posNr: scanSessions[idx]["POSNR"],
                                  barCode: hunoToDelete,
                                );

                                Navigator.pop(context); // close loader

                                if (result.status == "S") {
                                  setDialogState(() {
                                    hunoList.removeAt(i);
                                  });
                                  setState(() {}); // refresh main screen
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result.message)),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
  void initState() {
    super.initState();
    _loadEmployee();

    PM75Scanner.init((qrCode) async {
      if (qrCode == "READ_FAIL") return;
      if (!mounted || _isLoading) return;
      if (ignoreOnSaturate()) return;
      if (_lock) {
        await _getScanInfo(huno: qrCode);
      } else {
        await _getSOInfo(soNo: qrCode);
      }
    });
  }

  Future<void> _getSOInfo({String soNo = ""}) async {
    setState(() {
      _isLoading = true;
    });

    if (soNo.isNotEmpty) {
      setState(() {
        iptSono.text = soNo;
      });
    }
    await Future.delayed(Duration.zero);
    if (iptSono.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final result = await api.soInfo(soNo: iptSono.text);
    if (result.status != "S") {
      DialogHelper.showMessage(
        context,
        title: "Error",
        message: result.message,
      );
    } else {
      scanSessions = result.soInfo.map((e) {
        final rawBarcodeList = e["BARCODE_LIST"];

        // Handle both "" and proper object cases safely
        final List<Map<String, dynamic>> items =
            rawBarcodeList is Map && rawBarcodeList["item"] is List
            ? List<Map<String, dynamic>>.from(rawBarcodeList["item"])
            : [];

        // Optional but recommended: remove duplicate barcodes
        final uniqueItems = {
          for (var i in items) i["BARCODE"]: i,
        }.values.toList();

        // Build HUNO list from barcode entries
        final hunoList = uniqueItems
            .map((i) => i["HUNO"].toString())
            .toSet()
            .toList();

        return {
          ...e,
          "BARCODE_LIST": {"item": uniqueItems},
          "huno": hunoList,
        };
      }).toList();

      setState(() {
        _lock = true;
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getScanInfo({String huno = ""}) async {
    setState(() => _isLoading = true);
    final item = scanSessions[activeItemId!];
    final int dispatchQty = double.parse(item["ZMENG"].toString()).toInt();

    try {
      if (huno == "") {
        huno = iptHuno.text;
      }
      final result = await api.dispatchScan(
        soNo: item["VBELN"],
        posNr: item["POSNR"],
        qty: item["ZMENG"],
        barCode: huno,
      );
      if (result.status != "S") {
        DialogHelper.showMessage(
          context,
          title: "Error",
          message: result.message,
        );
      } else {
        final barcodes = item["BARCODE_LIST"]["item"] ?? [];
        if ((result.barcode.length + barcodes.length) <= dispatchQty) {
          setState(() {
            final existing = item["BARCODE_LIST"]["item"] as List;

            for (final barCode in result.barcode) {
              if (!existing.any((e) => e["BARCODE"] == barCode)) {
                existing.add({"HUNO": result.huno, "BARCODE": barCode});
              }
            }

            if (!item["huno"].contains(result.huno)) {
              item["huno"].add(result.huno);
            }
          });
        } else {
          DialogHelper.showMessage(
            context,
            title: "Error",
            message: "Quantity Exceeds Max Capacity",
          );
          return;
        }
      }
    } catch (e) {
      DialogHelper.showMessage(context, title: "Error", message: e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

  bool ignoreOnSaturate() {
    final item = scanSessions[activeItemId!];
    final int dispatchQty = double.parse(item["ZMENG"].toString()).toInt();
    final barcodes = item["BARCODE_LIST"]["item"] ?? [];
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

  Future<void> _confirmProduction({String sono = ""}) async {
    setState(() => _isLoading = true);

    try {
      if (sono.isNotEmpty) {
        iptSono.text = sono;
      }
      if (iptSono.text.isEmpty) return;

      final result = await api.soConfirm(soNo: sono);
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
    iptSono.dispose();
    super.dispose();
  }

  Widget _buildProgress(int idx) {
    final item = scanSessions[idx];
    final dispatchQty = double.parse(item["ZMENG"].toString()).toInt();
    final barcodes = item["BARCODE_LIST"]["item"] ?? [];
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
          child: GestureDetector(
            onTap: () => _openHunoPopup(idx),
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade300,
              color: progress >= 1 ? Colors.green : Colors.blue,
            ),
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
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty) {
                                return soList;
                              }
                              return soList.where(
                                (so) => so.contains(value.text),
                              );
                            },
                            onSelected: (selection) {
                              iptSono.text = selection;
                            },
                            fieldViewBuilder:
                                (
                                  context,
                                  controller,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  iptSono.text = controller.text;
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      labelText: "Enter SO",
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.indigo,
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                            onPressed: () {
                              final sono = iptSono.text;
                              _isLoading ? null : _getSOInfo(soNo: sono);
                            },
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
                                    _buildProgress(index),
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
              child: const Text("Post Dispatch"),
            ),
          ),
        ),
      ),
    );
  }
}
