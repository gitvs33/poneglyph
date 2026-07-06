import '../models/book.dart';

/// Persistence interface for Book entities.
abstract class BookRepo {
  Future<List<Book>> getBooks();
  Future<List<Book>> getBooksByCollection(String collectionId);
  Future<Book?> getBook(String id);
  Future<void> saveBook(Book book);
  Future<void> deleteBook(String id);
}
