/// Interface for providers that need async initialization before first use.
abstract class Initializable {
  Future<void> initialize();
  bool get isInitialized;
}
