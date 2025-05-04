import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../../core/flavor_config.dart';
import '../../core/locator.dart';
import '../local_storage_service.dart';

import 'api_response.dart';

class Api {
  final AppFlavorConfig _config = locator<AppFlavorConfig>();
  String get baseUrl => _config.apiBaseUrl;
  String get _baseUrl => '$baseUrl/api';
  Map<String, String> headers = {
    HttpHeaders.acceptHeader: 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };
  final LocalStorageService localStorageService =
      locator<LocalStorageService>();

  Future<ApiResponse> postData(
    String url,
    dynamic body, {
    bool hasHeader = false,
    bool isMultiPart = false,
    File? fileList,
    String? customBaseUrl,
  }) async {
    try {
      final token = await localStorageService
          .getStorageValue(LocalStorageKeys.accessToken);
      final headers = {
        'Content-Type': 'application/json',
        if (hasHeader && token != null) 'Authorization': 'Bearer $token',
      };

      final fullUrl =
          customBaseUrl != null ? '$customBaseUrl$url' : '$_baseUrl$url';
      debugPrint('POST request to $fullUrl  ==> body: $body');

      if (isMultiPart) {
        final request = http.MultipartRequest('POST', Uri.parse(fullUrl));
        request.headers.addAll(headers);

        if (fileList != null) {
          await _addFiles(fileList, body, request);
        }
        if (body != null) {
          request.fields.addAll(Map<String, String>.from(body));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        return _handleResponse(response);
      } else {
        final response = await http.post(
          Uri.parse(fullUrl),
          body: jsonEncode(body),
          headers: headers,
        );
        return _handleResponse(response);
      }
    } catch (e) {
      debugPrint('Error in POST request: $e');
      return ApiResponse(
        isSuccessful: false,
        code: 500,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<void> _addFiles(File fileList, body, request) async {
    final file = fileList;
    final filename = file.path.split('/').last;
    var fileStream = ByteStream(file.openRead());
    var fileLength = await file.length();
    MultipartFile multipartFile;

    if (body != null) {
      multipartFile = MultipartFile(
        'file_attachments[$file]file',
        fileStream,
        fileLength,
        filename: filename,
      );
      request.fields.addAll(
        {'file_attachments[$file]attachment_type': 'png'},
      );
      request.fields.addAll(body);
    } else {
      multipartFile = MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: filename,
      );
    }
    request.files.add(multipartFile);
  }

  Future<ApiResponse> patchData(
    String url,
    body, {
    bool hasHeader = false,
  }) async {
    try {
      Request request = Request('PATCH', Uri.parse(_baseUrl + url));

      debugPrint('PATCH request to ${_baseUrl + url} with body: $body');
      return await _sendRequest(
        request,
        hasHeader,
        body: body,
      );
    } on SocketException catch (e) {
      debugPrint('$e');
      debugPrint('SocketException: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'No Internet connection',
      );
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      return ApiResponse.timeout();
    } on Exception catch (e) {
      debugPrint('Error: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    } catch (e) {
      debugPrint('$e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> getData(String url, {bool hasHeader = true}) async {
    try {
      final token = await localStorageService
          .getStorageValue(LocalStorageKeys.accessToken);
      final headers = {
        'Content-Type': 'application/json',
        if (hasHeader && token != null) 'Authorization': 'Bearer $token',
      };

      debugPrint('GET request to $_baseUrl$url');
      debugPrint('GET request to $_baseUrl$url  ==> headers: $headers');

      final response = await http.get(
        Uri.parse('$_baseUrl$url'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error in GET request: $e');
      return ApiResponse(
        isSuccessful: false,
        code: 500,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ApiResponse> deleteData(String url,
      {body, bool hasHeader = false, String? key}) async {
    Request request;
    try {
      request = Request(
        'DELETE',
        Uri.parse(_baseUrl + url),
      );

      debugPrint('DELETE request to ${request.url}  ');
      return await _sendRequest(
        request,
        hasHeader,
        body: body,
      );
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'No Internet connection',
      );
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      return ApiResponse.timeout();
    } on Exception catch (e) {
      debugPrint('Error signing in with: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse> putData(
    String url,
    dynamic body, {
    bool hasHeader = false,
  }) async {
    try {
      final token = await localStorageService
          .getStorageValue(LocalStorageKeys.accessToken);
      final headers = {
        'Content-Type': 'application/json',
        if (hasHeader && token != null) 'Authorization': 'Bearer $token',
      };

      debugPrint('PUT request to $_baseUrl$url with body: $body');

      final response = await http.put(
        Uri.parse('$_baseUrl$url'),
        body: jsonEncode(body),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error in PUT request: $e');
      return ApiResponse(
        isSuccessful: false,
        code: 500,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ApiResponse> _sendRequest(
    request,
    bool hasHeader, {
    Map<String, dynamic>? body,
    bool isMultiPart = false,
  }) async {
    if (body != null && !isMultiPart) {
      request.body = json.encode(body);
    }
    log('body: $body');
    Map<String, String> networkHeaders;

    networkHeaders = {};
    networkHeaders.addAll(headers);

    if (hasHeader) {
      final userValue = await localStorageService
          .getStorageValue(LocalStorageKeys.accessToken);

      networkHeaders['Authorization'] = 'Bearer $userValue';
    }
    if (hasHeader) {
      debugPrint(
          '${request.method.toUpperCase()} request to ${request.url} with header $networkHeaders ==> body: $body ');
    } else {
      debugPrint(
          '${request.method.toUpperCase()} request to ${request.url}  ==> body: $body ');
    }
    request.headers.addAll(networkHeaders);
    final response = await request.send();

    return _handleResponse(response);
  }

  ApiResponse _handleResponse(http.Response response) {
    debugPrint(
        'Response of ${response.statusCode} from ${response.request?.url} : ${response.body}');

    try {
      final responseBody = response.body;
      final Map<String, dynamic> parsed = jsonDecode(responseBody);

      if (response.statusCode == 401) {
        return ApiResponse(
          data: {
            "message": "Unauthorized access",
            "status": false,
            "statusCode": 401,
            "data": null,
            "error": {"statusCode": 401}
          },
          isSuccessful: false,
          message: "Unauthorized access",
          code: 401,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          isSuccessful: true,
          code: response.statusCode,
          message: parsed['message'] ?? 'Success',
          data: parsed,
        );
      }

      return ApiResponse(
        isSuccessful: false,
        code: response.statusCode,
        message: parsed['message'] ?? 'Error occurred',
        data: parsed,
      );
    } catch (e) {
      debugPrint('Error parsing response: $e');
      return ApiResponse(
        isSuccessful: false,
        code: response.statusCode,
        message: 'Error parsing response',
        data: null,
      );
    }
  }
}

Future<ApiResponse> _response(StreamedResponse response) async {
  String responseBody = await _logResult(response);

  // Handle 401 Unauthorized specifically
  if (response.statusCode == 401) {
    return ApiResponse(
      data: {
        "message": "Unauthorized access",
        "status": false,
        "statusCode": 401,
        "data": null,
        "error": {"statusCode": 401}
      },
      isSuccessful: false,
      message: "Unauthorized access",
    );
  }

  if (response.statusCode == 200 || response.statusCode == 201) {
    String? message;
    dynamic decodedJson;
    if (responseBody.isNotEmpty &&
        (responseBody.startsWith('{') || responseBody.startsWith('['))) {
      decodedJson = jsonDecode(responseBody);

      if (decodedJson is Map) {
        message = decodedJson['message'];
      }
    } else {
      decodedJson = null;
    }

    return ApiResponse(
      isSuccessful: true,
      data: decodedJson,
      message: message ?? 'success',
    );
  } else if (response.statusCode == 204) {
    return ApiResponse(
      isSuccessful: true,
      message: 'success',
    );
  } else if (response.statusCode >= 400 && response.statusCode <= 499) {
    if (responseBody.isNotEmpty) {
      try {
        final responseBodyDecoded = jsonDecode(responseBody);
        debugPrint('Json  $responseBodyDecoded');

        final responseModel = ApiResponse.fromJson(responseBodyDecoded);
        responseModel.code = response.statusCode;
        return responseModel;
      } catch (e) {
        // If we can't parse the response body, return a formatted error
        return ApiResponse(
          data: {
            "message": responseBody,
            "status": false,
            "statusCode": response.statusCode,
            "data": null,
            "error": {"statusCode": response.statusCode}
          },
          isSuccessful: false,
          message: responseBody,
          code: response.statusCode,
        );
      }
    }
    return ApiResponse.unknownError(response.statusCode);
  } else if (response.statusCode >= 500 && response.statusCode <= 599) {
    return ApiResponse.unknownError(response.statusCode);
  } else {
    return ApiResponse(
      isSuccessful: false,
      message: kReleaseMode
          ? 'Error occurred'
          : 'Error occurred : ${response.statusCode}',
    );
  }
}

Future<String> _logResult(StreamedResponse response) async {
  final responseBody = await response.stream.bytesToString();
  debugPrint(
      'Response of ${response.statusCode}  from ${response.request!.url} : $responseBody, reasonPhrase : ${response.reasonPhrase}');
  return responseBody;
}
