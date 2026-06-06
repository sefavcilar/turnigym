import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class SheetsService {
  static Future<List<List<Object?>?>> getSheetData(
    String spreadsheetId,
    String range,
  ) async {
    // 1. JSON dosyasını yükle
    final jsonString = await rootBundle.loadString(
      'assets/service-account.json',
    );
    final accountCredentials = ServiceAccountCredentials.fromJson(jsonString);

    // 2. Kimlik doğrulama
    var client = await clientViaServiceAccount(accountCredentials, [
      SheetsApi.spreadsheetsReadonlyScope,
    ]);
    var sheetsApi = SheetsApi(client);

    // 3. Veriyi çek
    var response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      range,
    );
    return response.values ?? [];
  }
}
