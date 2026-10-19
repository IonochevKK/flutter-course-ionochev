sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Нет соединения с сервером');
}

class ServerFailure extends Failure {
  const ServerFailure(int statusCode) : super('Ошибка сервера ($statusCode)');
}

class DataFailure extends Failure {
  const DataFailure() : super('Некорректный ответ сервера');
}
