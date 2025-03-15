import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
    body, {
    bool hasHeader = false,
    bool isMultiPart = false,
    File? fileList,
    String? customBaseUrl,
  }) async {
    try {
      dynamic request;
      final fullUrl =
          customBaseUrl != null ? '$customBaseUrl$url' : '$_baseUrl$url';

      if (isMultiPart) {
        request = MultipartRequest('POST', Uri.parse(fullUrl));

        if (fileList != null) {
          await _addFiles(fileList, body, request);
        }
      } else {
        request = Request('POST', Uri.parse(fullUrl));
      }

      return await _sendRequest(
        request,
        hasHeader,
        body: body,
        isMultiPart: isMultiPart,
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
    } on ClientException catch (e) {
      debugPrint('Error: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'There was a problem connecting to the server',
      );
    } on Exception catch (e) {
      debugPrint('Error: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'Something went wrong',
      );
    } catch (e) {
      debugPrint('$e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'Something went wrong',
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

  Future<ApiResponse> getData(
    String url, {
    body,
    bool hasHeader = false,
    String? key,
    bool retry = false,
  }) async {
    Request request;
    try {
      request = Request(
        'GET',
        Uri.parse(_baseUrl + url),
      );

      debugPrint('GET request to ${request.url}  ');
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

    return await _response(response);
  }
}

Future<ApiResponse> _response(
  StreamedResponse response,
) async {
  if (response.statusCode == 200 || response.statusCode == 201) {
    String responseBody = await _logResult(response);
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
    String responseBody = await _logResult(response);
    if (responseBody.isNotEmpty) {
      final responseBodyDecoded = jsonDecode(responseBody);
      debugPrint('Json  $responseBodyDecoded');

      final responseModel = ApiResponse.fromJson(responseBodyDecoded);
      responseModel.code = response.statusCode;
      return responseModel;
    }
    return ApiResponse.unknownError(response.statusCode);
  } else if (response.statusCode >= 500 && response.statusCode <= 599) {
    await _logResult(response);
    return ApiResponse.unknownError(response.statusCode);
  } else {
    await _logResult(response);
    return ApiResponse(
      isSuccessful: false,
      message: kReleaseMode
          ? 'Error occurred '
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