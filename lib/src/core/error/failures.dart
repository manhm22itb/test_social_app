
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({this.message = ''});
  final String message;
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message: message);
}
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Không có kết nối mạng.'});
}
class CacheFailure extends Failure {
  const CacheFailure({super.message});
}
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message: message);
}

class DailyLimitException implements Exception {
  final String message;
  final int dailyRemaining;

  DailyLimitException({
    required this.message,
    required this.dailyRemaining,
  });

  @override
  String toString() => message;
}