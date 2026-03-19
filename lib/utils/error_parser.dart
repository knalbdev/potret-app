String parseError(Object e) {
  final raw = e.toString();

  if (raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('NetworkException')) {
    return 'Unable to connect. Please check your internet connection and try again.';
  }
  if (raw.contains('TimeoutException')) {
    return 'Connection timed out. Please try again.';
  }
  if (raw.contains('FormatException') || raw.contains('type \'Null\'')) {
    return 'Unexpected response from server. Please try again.';
  }

  // Strip "Exception: " prefix added by Dart
  if (raw.startsWith('Exception: ')) {
    return raw.substring('Exception: '.length);
  }

  return 'Something went wrong. Please try again.';
}
