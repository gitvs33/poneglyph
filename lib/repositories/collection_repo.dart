import '../models/collection.dart';

/// Persistence interface for Collection entities.
abstract class CollectionRepo {
  Future<List<Collection>> getCollections();
  Future<void> saveCollection(Collection collection);
  Future<void> deleteCollection(String id);
}
