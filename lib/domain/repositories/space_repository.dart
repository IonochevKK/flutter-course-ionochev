import '../entities/space_item.dart';

abstract interface class SpaceRepository {
  Future<List<SpaceItem>> getItems();

  Future<SpaceItem> createItem(SpaceItem item);
}
