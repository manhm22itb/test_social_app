import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:result_dart/result_dart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/optional_x.dart';
import '../../../../common/utils/app_environment.dart';
import '../base/api_error.dart';
import '../interceptors/error_interceptor.dart';

@module
abstract class ApiModule {
  @singleton
  Talker get talker => Talker();

  @Named('baseUrl')
  String get baseUrl => AppEnvironment.apiUrl;
  // Đảm bảo AppEnvironment.apiUrl = 'http://10.0.2.2:8001'

  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @singleton
  Dio dio(
    @Named('baseUrl') String url,
    Talker talker,
    SupabaseClient supabaseClient,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: url,
        headers: {'accept': 'application/json'},

        // ⬇️ Giữ 10s cho connect + send
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),

        // ⬇️ TĂNG receiveTimeout để đỡ bị cắt sớm khi server trả hơi chậm
        receiveTimeout: const Duration(seconds: 40),
      ),
    );

    dio.interceptors.addAll([
      TalkerDioLogger(
        talker: talker,
        settings: TalkerDioLoggerSettings(
          responsePen: AnsiPen()..blue(),
          printResponseData: true,
          printRequestData: true,
          printRequestHeaders: true,
        ),
      ),
      // interceptor gắn token Supabase
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final session = supabaseClient.auth.currentSession;
          final token = session?.accessToken;
          if (kDebugMode) {
            print('🔐 Supabase access token: ${token != null}');
          }
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}

// Các extension phía dưới giữ nguyên
extension FutureX<T extends Object> on Future<T> {
  Future<T> getOrThrow() async {
    try {
      return await this;
    } on ApiError {
      rethrow;
    } on DioException catch (e) {
      throw e.toApiError();
    } catch (e) {
      throw ApiError.unexpected();
    }
  }

  Future<Result<R, ApiError>> tryGet<R extends Object>(
      R Function(T) response) async {
    try {
      return response.call(await getOrThrow()).toSuccess();
    } on ApiError catch (e) {
      return e.toFailure();
    } catch (e) {
      return ApiError.unexpected().toFailure();
    }
  }

  Future<Result<R, ApiError>> tryGetFuture<R extends Object>(
      Future<R> Function(T) response) async {
    try {
      return (await response.call(await getOrThrow())).toSuccess();
    } on ApiError catch (e) {
      return e.toFailure();
    } catch (e) {
      return ApiError.unexpected().toFailure();
    }
  }
}

extension FutureResultX<T extends Object> on Future<Result<T, ApiError>> {
  Future<W> fold<W>(
    W Function(T success) onSuccess,
    W Function(ApiError failure) onFailure,
  ) async {
    try {
      final result = await getOrThrow();
      return onSuccess(result);
    } on ApiError catch (e) {
      return onFailure(e);
    }
  }
}

extension DioExceptionX on DioException {
  ApiError toApiError() {
    if (error is ApiError) {
      return error as ApiError;
    } else {
      final statusCode = response?.statusCode ?? -1;
      String? responseMessage;
      if (response?.data is Map<String, dynamic>) {
        responseMessage = response?.data?['message'];
        if (responseMessage.isNotNullOrBlank && kDebugMode) {
          responseMessage = '$responseMessage';
        }
      }
      responseMessage = responseMessage ?? "S.Error unexpected";
      if (statusCode == 401) {
        return ApiError.unauthorized(responseMessage);
      } else if (statusCode >= 400 && statusCode < 500) {
        return ApiError.server(code: statusCode, message: responseMessage);
      } else {
        return ApiError.network(code: statusCode, message: responseMessage);
      }
    }
  }
}
