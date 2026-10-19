import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/index.dart' as entities;
import 'api_exception.dart';

class SpaceApi {
  SpaceApi({required this._baseUri, required this._client});

  final Uri _baseUri;
  final http.Client _client;

  Uri get _itemsUri => _baseUri.replace(path: '${_baseUri.path}/items');

  Future<List<entities.SpaceItem>> fetchItems() async {
    final response = await _client.get(_itemsUri);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode);
    }
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => entities.SpaceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<entities.SpaceItem> createItem(entities.SpaceItem item) async {
    final response = await _client.post(
      _itemsUri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode != 201) {
      throw ApiException(response.statusCode);
    }
    return entities.SpaceItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
