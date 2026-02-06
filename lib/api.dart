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
  static const String _employeeIdKey = "employee_id";

  static Future<void> saveEmployeeId(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeIdKey, employeeId);
  }

  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeIdKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_employeeIdKey);
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

class LoginAPI {
  static const String loginKey = "User_Login";

  static Future<Map<String, String>> login({
    required String employeeId,
    required String password,
  }) async {
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
      final json = jsonDecode(response.body);
      final output = json["OUTPUT_DATA"];
      return {"STATUS": output["STATUS"], "MESSAGE": output["MESSAGE"]};
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}

class RegisterAPI {
  static const String registerKey = "User_Signup";

  static Future<Map<String, String>> register({
    required String employeeId,
    required String name,
    required String mobile,
    required String password,
  }) async {
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

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final json = jsonDecode(response.body);
    final output = json["OUTPUT_DATA"];

    return {
      "STATUS": output["STATUS"],
      "MESSAGE": output["MESSAGE"],
      "APP_USR": output["APP_USR"],
      "BARCODE": output["BARCODE"],
    };
  }
}

class ResetPasswordAPI {
  static const String passwordKey = "User_Reset";

  static Future<Map<String, String>> reset({
    required String employeeId,
    required String password,
  }) async {
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

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final json = jsonDecode(response.body);
    final output = json["OUTPUT_DATA"];

    return {
      "STATUS": output["STATUS"],
      "MESSAGE": output["MESSAGE"],
      "APP_USR": output["APP_USR"],
      "BARCODE": output["BARCODE"],
    };
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
  final String aufnr;
  final String huno;
  final String zcan;
  final String zconfirm;
  final List<Map<String, dynamic>> bcList;
  final List<String> barcode;

  const CommonApiResponse({
    required this.status,
    required this.message,
    required this.userid,
    required this.aufnr,
    required this.huno,
    required this.zcan,
    required this.zconfirm,
    required this.bcList,
    required this.barcode,
  });

  factory CommonApiResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json['OUTPUT_DATA'] ?? json['OUTPUTA_DATA'] ?? {})
            as Map<String, dynamic>;

    return CommonApiResponse(
      status: data['STATUS'] ?? '',
      message: data['MESSAGE'] ?? '',
      userid: data['USER_ID'] ?? '',
      aufnr: data['AUFNR'] ?? '',
      huno: data['HUNO'] ?? '',
      zcan: data['ZSCAN'] ?? '',
      zconfirm: data['ZCONFIRM'] ?? '',
      bcList: _parseToMapData(data['BC_LIST']),
      barcode: _parseData(data['BARCODE']),
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

  static List<String> _parseData(dynamic data) {
    if (data == null) return [];
    if (data is Map<String, dynamic> && data['item'] is Map) {
      data['item'] = [data['item']];
    }
    if (data is Map<String, dynamic> && data['item'] is List) {
      return (data['item'] as List)
          .map((e) => e['BARCODE']?.toString())
          .whereType<String>()
          .toList();
    }
    return [];
  }
}

class HuAPI {
  static const String barcodeInfoKey = "ZFTME_BARCODE_DET";
  static const String huScanKey = "ZFTME_HU_SCAN";
  static const String huConfirmKey = "ZFTME_HU_CONFIRM";

  Future<CommonApiResponse> confirm({required String aufnr}) async {
    final url = Uri.parse(SAPConfig.baseUrl);
    final response = await http
        .post(
          url,
          headers: SAPConfig.headers,
          body: jsonEncode({
            huConfirmKey: {"AUFNR": aufnr},
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return CommonApiResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Connectivity Failed');
    }
  }

  Future<CommonApiResponse> scan({
    required String barcode,
    bool delete = false,
  }) async {
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
    } else {
      throw Exception('Connectivity Failed');
    }
  }
}

class BarcodeInfoAPI {
  static const String barcodeInfoKey = "ZFTME_BARCODE_DET";

  Future<CommonApiResponse> info({
    required String barcode,
    bool delete = false,
  }) async {
    final url = Uri.parse(SAPConfig.baseUrl);
    final response = await http
        .post(
          url,
          headers: SAPConfig.headers,
          body: jsonEncode({
            barcodeInfoKey: {"BARCODE": barcode, "DELETE": delete ? "X" : ""},
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return CommonApiResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Connectivity Failed');
    }
  }
}

class DispatchAPI {
  static const String soInfoKey = "ZFTME_SALESORD_DET";
  static const String dispatchScanKey = "ZFTME_HU_DIS_SCAN";

  Future<CommonApiResponse> so({required String soNo}) async {
    final url = Uri.parse(SAPConfig.baseUrl);
    final response = await http
        .post(
          url,
          headers: SAPConfig.headers,
          body: jsonEncode({
            soInfoKey: {
              "INPUT_DATA": {"HUNO": "", "AUFNR": "", "VBELN": soNo},
            },
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return CommonApiResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      final output = {
        "OUTPUTA_DATA": {
          "STATUS": "S",
          "MESSAGE": "Details Found",
          "USER_ID": "",
          "AUFNR": "",
          "HUNO": "",
          "MATNR": "",
          "MAKTX": "",
          "ZSCAN": "",
          "ZCONFIRM": "",
          "BC_LIST": {
            "item": {
              "VBELN": "0000000001",
              "POSNR": "000010",
              "MATNR": "000000000003000008",
              "MAKTX": "Front Fork for 3 Wheel Cargo A092S11",
              "CHARG": "",
              "LGORT": "",
              "ZMENG": "0.000",
              "ZIEME": "KG",
            },
          },
          "BARCODE": "",
        },
      };
      return CommonApiResponse.fromJson(
        output["OUTPUT_DATA"] as Map<String, dynamic>,
      );
      // throw Exception('Connectivity Failed');
    }
  }

  Future<CommonApiResponse> soScan({required String soNo}) async {
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
    } else {
      throw Exception('Connectivity Failed');
    }
  }
}
