import 'package:http/http.dart' as http;

import '../../domain/index.dart' as domain;
import '../api_exception.dart';
import '../space_api.dart';

class SpaceRepositoryImpl implements domain.SpaceRepository {
  const SpaceRepositoryImpl(this._api);

  final SpaceApi _api;

  @override
  Future<List<domain.SpaceItem>> getItems() => _guard(_api.fetchItems);

  @override
  Future<domain.SpaceItem> createItem(domain.SpaceItem item) =>
      _guard(() => _api.createItem(item));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw domain.ServerFailure(e.statusCode);
    } on http.ClientException {
      throw const domain.NetworkFailure();
    } on FormatException {
      throw const domain.DataFailure();
    } on TypeError {
      throw const domain.DataFailure();
    }
  }
}
