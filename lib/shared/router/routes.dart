abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const catalog = '/';
  static const profile = '/profile';

  static const fromParam = 'from';

  static String book(String id) => '/book/$id';

  static String withFrom(String path, String? from) {
    if (from == null) return path;
    return Uri(path: path, queryParameters: {fromParam: from}).toString();
  }
}
