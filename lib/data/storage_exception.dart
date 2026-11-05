/// Thrown by repositories when reading or writing device storage fails.
///
/// [message] is technical and meant for logs; screens show the text chosen by
/// the controller instead.
class StorageException implements Exception {
  const StorageException(this.message, [this.cause]);

  final String message;

  /// The underlying error, when there is one.
  final Object? cause;

  @override
  String toString() =>
      'StorageException: $message${cause == null ? '' : ' ($cause)'}';
}
