/// Centralized HTTP client built on [Dio].
///
/// All outgoing requests are routed through [ApiClient] so that auth headers,
/// token refresh, and error mapping are handled in a single place.
///
/// Never instantiate this class directly — use [apiClientProvider] instead.
library;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance_dio/firebase_performance_dio.dart';

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';

class ApiClient {
  ApiClient({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
      ),
    );

    _dio.interceptors.addAll([
      DioFirebasePerformanceInterceptor(),
      _authInterceptor(),
      _tokenRefreshInterceptor(),
      _errorMappingInterceptor(),
    ]);
  }

  static const _timeout = Duration(seconds: 30);

  final FirebaseAuth _auth;
  late final Dio _dio;

  /// Exposes the configured [Dio] instance for direct use when needed.
  Dio get dio => _dio;

  // ---------------------------------------------------------------------------
  // Interceptor 1 — Auth header injection
  // ---------------------------------------------------------------------------

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = _auth.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Interceptor 2 — Token refresh on 401
  // ---------------------------------------------------------------------------

  InterceptorsWrapper _tokenRefreshInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        // Attempt a forced token refresh.
        final user = _auth.currentUser;
        if (user == null) {
          throw const AuthException.coded(
            'Session expired. Please log in again.',
            code: 'session-expired',
          );
        }

        String? newToken;
        try {
          newToken = await user.getIdToken(true);
        } catch (_) {
          // Refresh failed — surface as AuthException.
          throw const AuthException.coded(
            'Session expired. Please log in again.',
            code: 'session-expired',
          );
        }

        if (newToken == null) {
          throw const AuthException.coded(
            'Session expired. Please log in again.',
            code: 'session-expired',
          );
        }

        // Retry the original request exactly once with the fresh token.
        final options = error.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          if (retryError.response?.statusCode == 401) {
            throw const AuthException.coded(
              'Session expired. Please log in again.',
              code: 'session-expired',
            );
          }
          return handler.next(retryError);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Interceptor 3 — Error mapping
  // ---------------------------------------------------------------------------

  InterceptorsWrapper _errorMappingInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // If a typed AppException was already attached (e.g. by the refresh
        // interceptor), rethrow it directly.
        if (error.error is AppException) {
          throw error.error! as AppException;
        }

        throw _mapDioException(error);
      },
    );
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null && statusCode >= 500) {
          final body = error.response?.data;
          final serverMessage =
              body is Map<String, dynamic> ? body['message'] as String? : null;
          return ServerException(
            statusCode: statusCode,
            message: serverMessage ?? 'Server error. Please try again later.',
          );
        }
        if (statusCode != null && statusCode >= 400) {
          return ServerException(statusCode: statusCode);
        }
        return const NetworkException();

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }
}
