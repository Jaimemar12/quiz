class NotANumberException implements Exception {
  NotANumberException(this.error);
  final String error;
}

class OutOfBoundsException implements Exception {
  OutOfBoundsException(this.error);
  final String error;
}