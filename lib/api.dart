import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarcodeScannerService {
  static const MethodChannel _channel = MethodChannel('pointmobile_scanner');
  static Future<void> startListening(Function(String code) onScan) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onBarcodeScanned") {
        final String barcode = call.arguments;
        onScan(barcode);
      }
    });
  }
}

class DialogHelper {
  static void showMessage(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class SessionManager {
  static const String _employeeIdKey = "empId";
  static const String _employeeEmailKey = "empEmail";
  static const String _employeeNameKey = "empName";
  static const String _employeeMobileKey = "empMobile";

  static Future<void> saveEmployeeId(
    String empId,
    String empMobile,
    String empEmail,
    String empName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeIdKey, empId);
    await prefs.setString(_employeeEmailKey, empEmail);
    await prefs.setString(_employeeNameKey, empName);
    await prefs.setString(_employeeMobileKey, empMobile);
  }

  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeIdKey);
  }

  static Future<String?> getEmployeeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeEmailKey);
  }

  static Future<String?> getEmployeeMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeMobileKey);
  }

  static Future<String?> getEmployeeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeNameKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_employeeIdKey);
    await prefs.remove(_employeeEmailKey);
    await prefs.remove(_employeeNameKey);
    await prefs.remove(_employeeMobileKey);
  }
}

class SAPConfig {
  static const String authUrl =
      "https://dev-acme-yf464dbr.it-cpi021-rt.cfapps.in30.hana.ondemand.com/http/ftbc/";
  static const String baseUrl =
      "https://dev-acme-yf464dbr.it-cpi021-rt.cfapps.in30.hana.ondemand.com/http/ftbc/Common_api";

  static const String sapUsername =
      "sb-e97d8d0c-6773-4c51-9cc6-713e78b1c971!b36963|it-rt-dev-acme-yf464dbr!b148";
  static const String sapPassword =
      r"0ecb25dd-a942-48bb-afb6-2e274d84d1db$FTplNc-7i91tvj9KTXA05WZNxOpTwH3JaUX28IWsNmQ=";

  static Map<String, String> get headers => {
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": _basicAuth,
  };

  static String get _basicAuth {
    final credentials = "$sapUsername:$sapPassword";
    return "Basic ${base64Encode(credentials.codeUnits)}";
  }
}

class PM75Scanner {
  static const _channel = MethodChannel('pm_scanner');

  static void init(Function(String) onScan) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onScan') {
        onScan(call.arguments as String);
      }
    });

    _channel.invokeMethod('startScanner');
  }
}

class CommonApiResponse {
  final String status;
  final String message;
  final String userid;
  final String name;
  final String email;
  final String mobile;
  final String aufnr;
  final String huno;
  final String zcan;
  final String zconfirm;
  final String matnr;
  final String maktx;
  final List<Map<String, dynamic>> bcList;
  final List<Map<String, dynamic>> soInfo;
  final List<String> barcode;
  final List<String> soList;
  final List<String> deliveryList;

  const CommonApiResponse({
    required this.status,
    required this.message,
    required this.userid,
    required this.mobile,
    required this.email,
    required this.name,
    required this.aufnr,
    required this.huno,
    required this.zcan,
    required this.zconfirm,
    required this.matnr,
    required this.maktx,
    required this.bcList,
    required this.barcode,
    required this.soList,
    required this.soInfo,
    required this.deliveryList,
  });

  factory CommonApiResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('OUTPUT_DATA') || json.containsKey('OUTPUTA_DATA')) {
      final data =
          (json['OUTPUT_DATA'] ?? json['OUTPUTA_DATA']) as Map<String, dynamic>;

      return CommonApiResponse(
        status: data['STATUS'] ?? '',
        message: data['MESSAGE'] ?? '',
        userid: data['USER_ID'] ?? '',
        mobile: data['MOBILE'] ?? '',
        email: data['EMAIL'] ?? '',
        name: data['NAME'] ?? '',
        aufnr: data['AUFNR'] ?? '',
        huno: data['HUNO'] ?? '',
        zcan: data['ZSCAN'] ?? '',
        zconfirm: data['ZCONFIRM'] ?? '',
        matnr: data['MATNR'] ?? '',
        maktx: data['MAKTX'] ?? '',
        bcList: _parseToMapData(data['BC_LIST']),
        soInfo: _parseToMapData(data['SALE_ORD_LIST']),
        barcode: _parseToListData(data['BARCODE'], 'BARCODE'),
        soList: _parseToListData(data['SO_LIST'], 'VBELN'),
        deliveryList: _parseToListData(data['DELIVERY_LIST'], 'VBELN'),
      );
    }

    return CommonApiResponse(
      status: 'E',
      message: json['message'] ?? json['error'] ?? json.toString(),
      userid: '',
      mobile: '',
      name: '',
      email: '',
      aufnr: '',
      huno: '',
      zcan: '',
      zconfirm: '',
      matnr: '',
      maktx: '',
      bcList: const [],
      soInfo: const [],
      barcode: const [],
      soList: const [],
      deliveryList: const [],
    );
  }

  static List<Map<String, dynamic>> _parseToMapData(dynamic data) {
    if (data == null) return [];
    if (data is Map<String, dynamic> && data['item'] is Map) {
      data['item'] = [data['item']];
    }
    if (data is Map<String, dynamic> && data['item'] is List) {
      return (data['item'] as List).whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  static List<String> _parseToListData(dynamic data, String key) {
    if (data == null) return [];
    if (data is Map<String, dynamic> && data['item'] is Map) {
      data['item'] = [data['item']];
    }
    if (data is Map<String, dynamic> && data['item'] is List) {
      return (data['item'] as List)
          .map((e) => e[key]?.toString())
          .whereType<String>()
          .toList();
    }
    return [];
  }
}

class LoginAPI {
  static const String loginKey = "User_Login";

  Future<CommonApiResponse> login({
    required String employeeId,
    required String password,
  }) async {
    try {
      final url = Uri.parse("${SAPConfig.authUrl}$loginKey");
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              "INPUT_DATA": {"APP_USR": employeeId, "PASSWORD": password},
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}

class RegisterAPI {
  static const String registerKey = "User_Signup";

  Future<CommonApiResponse> register({
    required String employeeId,
    required String name,
    required String mobile,
    required String password,
  }) async {
    try {
      final url = Uri.parse("${SAPConfig.authUrl}$registerKey");

      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              "INPUT_DATA": {
                "APP_USR": employeeId,
                "NAME": name,
                "PASSWORD": password,
                "MOBILE": mobile,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}

class ResetPasswordAPI {
  static const String passwordKey = "User_Reset";

  Future<CommonApiResponse> reset({
    required String employeeId,
    required String password,
  }) async {
    try {
      final url = Uri.parse("${SAPConfig.authUrl}$passwordKey");
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              "INPUT_DATA": {"APP_USR": employeeId, "PASSWORD": password},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}

class ProductionConfirmationAPI {
  static const String huScanKey = "ZFTME_HU_SCAN";
  static const String huConfirmKey = "ZFTME_PROD_RECEIPT";

  Future<CommonApiResponse> confirm({
    required List<Map<String, String>> aufnrList,
  }) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);

      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              huConfirmKey: {
                "INPUT_DATA": {
                  "HUNO": " ",
                  "AUFNR": {"item": aufnrList},
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }

  Future<CommonApiResponse> scan({
    required String barcode,
    bool delete = false,
  }) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              huScanKey: {"BARCODE": barcode, "DELETE": delete ? "X" : ""},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}

class BarcodeInfoAPI {
  static const String barcodeInfoKey = "ZFTME_BARCODE_DET";

  Future<CommonApiResponse> info({
    required String barcode,
    bool delete = false,
  }) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              barcodeInfoKey: {
                "INPUT_DATA": {
                  "APP_USR": "",
                  "HUNO": barcode,
                  "AUFNR": "",
                  "MATNR": "",
                  "VBELN": "",
                  "BARCODE": "",
                  "DELIVERY": "",
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}

class DispatchAPI {
  static const String soListKey = "ZFTME_SALESORD_LIST";
  static const String soInfoKey = "ZFTME_SALESORD_DET";
  static const String dispatchScanKey = "ZFTME_HU_DIS_SCAN";
  static const String soConfirmKey = "ZFTME_OUTB_DELIVERY";

  Future<CommonApiResponse> soList({required String appUser}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              soListKey: {
                "INPUT_DATA": {"APP_USR": appUser},
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }

  Future<CommonApiResponse> soInfo({required String soNo}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              soInfoKey: {
                "INPUT_DATA": {"VBELN": soNo},
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }

  Future<CommonApiResponse> soScan({required String soNo}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              dispatchScanKey: {"BARCODE": soNo, "DELETE": ""},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }

  Future<CommonApiResponse> soConfirm({required String soNo}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              dispatchScanKey: {
                "INPUT_DATA": {"VBELN": soNo},
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}

class ReworkAPI {
  static const String barcodeInfoKey = "ZFTME_BARCODE_DET";
  static const String reworkKey = "ZFTME_HU_PROCESS";

  Future<CommonApiResponse> soInfo({required String soNo}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              barcodeInfoKey: {
                "INPUT_DATA": {"HUNO": soNo},
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }

  Future<CommonApiResponse> rework({required String barcode}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              reworkKey: {
                "IV_ACTION": "REWK",
                "INPUT_DATA": {"BARCODE": barcode},
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}

class ScrapAPI {
  static const String barcodeInfoKey = "ZFTME_BARCODE_DET";
  static const String reworkKey = "ZFTME_HU_PROCESS";

  Future<CommonApiResponse> soInfo({required String soNo}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              barcodeInfoKey: {
                "INPUT_DATA": {"HUNO": soNo},
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }

  Future<CommonApiResponse> scrap({required String barcode}) async {
    try {
      final url = Uri.parse(SAPConfig.baseUrl);
      final response = await http
          .post(
            url,
            headers: SAPConfig.headers,
            body: jsonEncode({
              reworkKey: {
                "IV_ACTION": "SCR",
                "INPUT_DATA": {"BARCODE": barcode},
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return CommonApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return CommonApiResponse.fromJson({
        "status": "E",
        "message": response.body.isNotEmpty
            ? "[${response.statusCode}] ${response.body}"
            : "Connectivity Failed",
      });
    } on TimeoutException {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 408,
        "message": "Request timeout. Please try again.",
      });
    } catch (e) {
      return CommonApiResponse.fromJson({
        "status": "E",
        "statusCode": 500,
        "message": e.toString(),
      });
    }
  }
}
