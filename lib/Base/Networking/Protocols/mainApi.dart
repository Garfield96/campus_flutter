import 'dart:convert';

import 'package:campus_flutter/base/Networking/Protocols/apiResponse.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import '../cache.dart';
import 'API.dart';

class MainAPI {
  static final Cache<String, Serializable> cache = Cache();

  static Future<T> makeRequest<T extends Serializable, S extends API>(
      S endpoint,
      dynamic Function(Map<String, dynamic>) create,
      String? token,
      bool forcedRefresh) async {

    if (!forcedRefresh && cache.checkKeyInCache(key: endpoint.toString())) {
      final data = await cache.getAllRecords(key: endpoint.toString());
      return data as T;
    }

    http.Response response;

    try {
      response = await endpoint.asResponse(token: token);
    } catch (e) {
      print(e.toString());
      // TODO: Networking Error
      throw Exception();
    }

    if (response.statusCode != 200) {
      // TODO: Response Error
      throw Exception();
    } else {
      if (response.headers["content-type"]?.contains("json") ?? false) {
        final data =
            ApiResponse<T>.fromJson(jsonDecode(response.body), create).data;
        cache.saveAllRecords(value: data, key: endpoint.toString());
        return data;
      } else {
        final transformer = Xml2Json();
        transformer.parse(response.body);
        final json = transformer.toParker();
        final data = ApiResponse<T>.fromJson(jsonDecode(json), create).data;
        cache.saveAllRecords(value: data, key: endpoint.toString());
        return data;
      }
    }
  }
}
