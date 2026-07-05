import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../repositories/book_repository.dart';

/// Single source of truth for collection state.
/// Uses [BookRepository] for persistence and exposes
/// all collection operations for screens and other providers.
class CollectionsProvider extends ChangeNotifier {
  final BookRepository _repo;
  List<Collection> _collections = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  CollectionsProvider({required BookRepository repo}) : _repo = repo;

  List<Collection> get collections => List.unmodifiable(_collections);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Call once from the first screen that needs collections.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    _collections = List<Collection>.from(await _repo.getCollections());
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // ── CRUD ───────────────────────────────────────────────

  Future<void> createCollection(String name, {String? icon}) async {
    final collection = Collection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon ?? 'folder',
    );
    await _repo.saveCollection(collection);
    _collections.add(collection);
    notifyListeners();
  }

  Future<void> renameCollection(String id, String newName) async {
    final index = _collections.indexWhere((c) => c.id == id);
    if (index != -1) {
      _collections[index] = _collections[index].copyWith(name: newName);
      await _repo.saveCollection(_collections[index]);
      notifyListeners();
    }
  }

  Future<void> deleteCollection(String id) async {
    _collections.removeWhere((c) => c.id == id);
    await _repo.deleteCollection(id);
    notifyListeners();
  }

  // ── Book ↔ Collection membership ───────────────────────

  void addBookToCollection(String collectionId, String bookId) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      final currentIds = List<String>.from(_collections[index].bookIds);
      if (!currentIds.contains(bookId)) {
        currentIds.add(bookId);
        _collections[index] = _collections[index].copyWith(
          bookIds: currentIds,
          bookCount: currentIds.length,
        );
        _repo.saveCollection(_collections[index]);
        notifyListeners();
      }
    }
  }

  void removeBookFromCollection(String collectionId, String bookId) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      final currentIds = List<String>.from(_collections[index].bookIds);
      currentIds.remove(bookId);
      _collections[index] = _collections[index].copyWith(
        bookIds: currentIds,
        bookCount: currentIds.length,
      );
      _repo.saveCollection(_collections[index]);
      notifyListeners();
    }
  }

  // ── Reorder ────────────────────────────────────────────

  void reorderCollections(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _collections.removeAt(oldIndex);
    _collections.insert(newIndex, item);
    notifyListeners();
  }
}
