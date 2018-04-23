
class MalformedStringException implements Exception {
  final dynamic message;
  final dynamic stacktrace;
  MalformedStringException(this.message, this.stacktrace);

  String toString() {
    return "Instance of 'MalformedStringException': $message\nStack trace:\n$stacktrace";
  }
}
