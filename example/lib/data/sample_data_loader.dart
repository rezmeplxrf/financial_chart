import 'dart:convert';
import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

import 'yahoo_finance_response.dart';

// const _yahooFinanceDataReader = YahooFinanceDailyReader();

Future<YahooFinanceResponse> loadYahooFinanceData(String ticker) async {
  Map<String, dynamic> json = {};
  String fileName = "$ticker.json";
  final content = await rootBundle.loadString('assets/$fileName');
  json = jsonDecode(content);
  return YahooFinanceResponse.fromJson(json);
}

Future<YahooFinanceResponse> webLoadYahooFinanceData(String ticker) async {
  // there is cors issue when deploy to online so we just load from asset
  return loadYahooFinanceData(ticker);

  // uncomment and run locally
  //    flutter build web --web-browser-flag "--disable-web-security"

  // Map<String, dynamic> json = {};
  // final now = DateTime.now();
  // final period1 = now.subtract(const Duration(days: 365 * 5)).millisecondsSinceEpoch ~/ 1000;
  // final period2 = now.millisecondsSinceEpoch ~/ 1000;
  // final url =
  //     "https://query2.finance.yahoo.com/v8/finance/chart/$ticker?formatted=true&interval=1d&period1=$period1&period2=$period2&symbol=$ticker";
  // final response = await http.get(Uri.parse(url));
  // final content = response.body;
  // json = jsonDecode(content)["chart"]["result"][0];
  // return YahooFinanceResponse.fromJson(json);
}
