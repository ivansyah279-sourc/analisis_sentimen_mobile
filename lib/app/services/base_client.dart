import 'dart:async';
import 'dart:io';
import 'package:sentimen_mobile/config/environment/environment.dart';
import 'package:sentimen_mobile/config/storage/token_storage.dart';
import 'package:sentimen_mobile/utils/auth_util.dart';
import 'package:sentimen_mobile/utils/connection.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../config/translations/strings_enum.dart';
import '../components/custom_snackbar.dart';
import 'api_exceptions.dart';

enum RequestType {
  get,
  post,
  put,
  delete,
}

class BaseClient {
  static bool isRefreshing = false;
  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    ),
  )..interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
      InterceptorsWrapper(onRequest: (options, handler) async {
        Map tokenData = await TokenStorage.getToken();
        String accessToken = tokenData['token'];

        if (accessToken.isNotEmpty) {
          options.headers["authorization"] = "Bearer $accessToken";
        }
        handler.next(options);
      }, onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 ||
            error.response?.statusCode == 403) {
          if (isRefreshing) {
            return handler
                .reject(error); // Jangan refresh ulang jika sudah berjalan
          }

          bool refreshed = await _refreshToken();
          if (refreshed) {
            try {
              final newRequest = await _retry(error.requestOptions);
              return handler.resolve(newRequest);
            } catch (e) {
              _logout();
            }
          } else {
            _logout();
          }
        }
        handler.next(error);
      })
    ]);

  static Future<bool> _refreshToken() async {
    if (isRefreshing) return false; // Mencegah refresh ganda
    isRefreshing = true;

    try {
      bool isConnected = await ConnectionUtils.checkInternetConnection();
      if (!isConnected) {
        isRefreshing = false;
        return true; // Jangan logout, tetap pakai token lama
      }

      Map tokenData = await TokenStorage.getToken();
      String refreshToken = tokenData['refreshToken'];

      if (refreshToken.isEmpty) {
        isRefreshing = false;
        return false;
      }

      return await BaseClient.safeApiCall(
        Environment.refreshUrl,
        RequestType.post,
        data: {"time": DateTime.now().millisecondsSinceEpoch.toString()},
        onSuccess: (response) async {
          await TokenStorage.setToken(
            token: response.data['token'],
            refreshToken: response.data['refresh_token'],
          );
          isRefreshing = false;
          return true;
        },
        onError: (error) {
          isRefreshing = false;
          return false;
        },
      );
    } catch (e) {
      isRefreshing = false;
      return false;
    }
  }

  static Future<void> _logout() async {
    await TokenStorage.clear();
    AuthUtil.signout();
  }

  static Future<Response> _retry(RequestOptions requestOptions) async {
    Map tokenData = await TokenStorage.getToken();
    String newToken = tokenData['token'];

    if (newToken.isEmpty) {
      _logout();
      throw DioException(
          requestOptions: requestOptions,
          message: "Token is empty after refresh");
    }

    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, "authorization": "Bearer $newToken"},
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  static const int _timeoutInSeconds = 10;

  static Dio get dio => _dio;

  /// perform safe api request
  static Future<dynamic> safeApiCall(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    required Function(Response response) onSuccess,
    Function(ApiException)? onError,
    Function(int value, int progress)? onReceiveProgress,
    Function(int total, int progress)? onSendProgress,
    Function? onLoading,
    dynamic data,
    bool isJson = false,
  }) async {
    try {
      await onLoading?.call(); // Indikasikan loading

      late Response response;
      if (requestType == RequestType.get) {
        response = await _dio.get(
          url,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        );
      } else if (requestType == RequestType.post) {
        response = await _dio.post(
          url,
          data: isJson ? data : FormData.fromMap(data),
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(
            headers: headers,
            contentType: isJson
                ? Headers.jsonContentType
                : Headers.formUrlEncodedContentType,
          ),
        );
      } else if (requestType == RequestType.put) {
        response = await _dio.put(
          url,
          data: isJson ? data : FormData.fromMap(data),
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(
            headers: headers,
            contentType: isJson
                ? Headers.jsonContentType
                : Headers.formUrlEncodedContentType,
          ),
        );
      } else {
        response = await _dio.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        );
      }

      // **Pastikan return dari onSuccess dikembalikan**
      return onSuccess(response);
    } on DioException catch (error) {
      // dio error (api reach the server but not performed successfully
      _handleDioError(error: error, url: url, onError: onError);
    } on SocketException {
      // No internet connection
      _handleSocketException(url: url, onError: onError);
    } on TimeoutException {
      // Api call went out of time
      _handleTimeoutException(url: url, onError: onError);
    } catch (error, stackTrace) {
      // print the line of code that throw unexpected exception
      Logger().e(stackTrace);
      // unexpected error for example (parsing json error)
      _handleUnexpectedException(url: url, onError: onError, error: error);
    }
  }

  /// download file
  static download(
      {required String url, // file url
      required String savePath, // where to save file
      Function(ApiException)? onError,
      Function(int value, int progress)? onReceiveProgress,
      required Function onSuccess}) async {
    try {
      await _dio.download(
        url,
        savePath,
        options: Options(
            receiveTimeout: const Duration(seconds: _timeoutInSeconds),
            sendTimeout: const Duration(seconds: _timeoutInSeconds)),
        onReceiveProgress: onReceiveProgress,
      );
      onSuccess();
    } catch (error) {
      var exception = ApiException(url: url, message: error.toString());
      onError?.call(exception) ?? _handleError(error.toString());
    }
  }

  /// handle unexpected error
  static _handleUnexpectedException(
      {Function(ApiException)? onError,
      required String url,
      required Object error}) {
    if (onError != null) {
      onError(ApiException(
        message: error.toString(),
        url: url,
      ));
    } else {
      _handleError(error.toString());
    }
  }

  /// handle timeout exception
  static _handleTimeoutException(
      {Function(ApiException)? onError, required String url}) {
    if (onError != null) {
      onError(ApiException(
        message: Strings.serverNotResponding,
        url: url,
      ));
    } else {
      _handleError(Strings.serverNotResponding);
    }
  }

  /// handle timeout exception
  static _handleSocketException(
      {Function(ApiException)? onError, required String url}) {
    if (onError != null) {
      onError(ApiException(
        message: Strings.noInternetConnection,
        //message: Strings.noInternetConnection.tr,
        url: url,
      ));
    } else {
      _handleError(Strings.noInternetConnection);
      //_handleError(Strings.noInternetConnection.tr);
    }
  }

  /// handle Dio error
  static _handleDioError({
    required DioException error,
    Function(ApiException)? onError,
    required String? url,
  }) {
    // Handle kasus ketika 'status' dalam response adalah false
    if (error.response?.data['status'] == false) {
      var message = error.response?.data['message'] ?? 'Unknown error occurred';

      var exception = ApiException(
        message: message,
        url: url ?? '',
        statusCode: error.response?.statusCode ?? 400,
      );

      if (onError != null) {
        return onError(exception);
      } else {
        return handleApiError(exception);
      }
    }

    // Handle 404 error secara spesifik
    if (error.response?.statusCode == 404) {
      var message = error.response?.data['message'] ?? Strings.urlNotFound;

      var exception = ApiException(
        message: message,
        url: url ?? '',
        statusCode: 404,
      );

      if (onError != null) {
        return onError(exception);
      } else {
        return handleApiError(exception);
      }
    }

    // Handle no internet connection
    if (error.message != null &&
        error.message!.toLowerCase().contains('socket')) {
      var exception = ApiException(
        message: Strings.noInternetConnection,
        url: url ?? '',
      );

      if (onError != null) {
        return onError(exception);
      } else {
        return _handleError(Strings.noInternetConnection);
      }
    }

    // Handle 500 server error
    if (error.response?.statusCode == 500) {
      var exception = ApiException(
        message: Strings.serverError,
        url: url ?? '',
        statusCode: 500,
      );

      if (onError != null) {
        return onError(exception);
      } else {
        return handleApiError(exception);
      }
    }

    // Default error handling
    var exception = ApiException(
      url: url ?? '',
      message: error.message ?? 'Unexpected API Error!',
      response: error.response,
      statusCode: error.response?.statusCode,
    );

    if (onError != null) {
      return onError(exception);
    } else {
      return handleApiError(exception);
    }
  }

  /// handle error automaticly (if user didnt pass onError) method
  /// it will try to show the message from api if there is no message
  /// from api it will show the reason (the dio message)
  static handleApiError(ApiException apiException) {
    String msg = apiException.toString();
    CustomSnackBar.showCustomErrorToast(message: msg);
  }

  /// handle errors without response (500, out of time, no internet,..etc)
  static _handleError(String msg) {
    CustomSnackBar.showCustomErrorToast(message: msg);
  }
}
