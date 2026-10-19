
// Тут в идеале нужно разделить окружение env файлы и так далее, сделаю это в след задании, сейчас смысла не видел об нормальном конфиге думать
class AppConfig {
  static const baseUrl = String.fromEnvironment('BASE_URL');
  static const apiPrefix = '/api/v1';

  static Uri get apiBaseUri => Uri.parse('$baseUrl$apiPrefix');

  static void validate() {
    if (baseUrl.isEmpty) {
      throw StateError(
        'BASE_URL не задан: запусти с --dart-define-from-file=.env',
      );
    }
  }
}
