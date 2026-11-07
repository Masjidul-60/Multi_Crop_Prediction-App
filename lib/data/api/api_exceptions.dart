class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => 'ApiException($statusCode, $errorCode): $message';
}

class InvalidImageException extends ApiException {
  const InvalidImageException([String message = 'The provided image file is corrupted or unsupported.'])
      : super(statusCode: 400, errorCode: 'INVALID_IMAGE', message: message);
}

class ImageTooLargeException extends ApiException {
  const ImageTooLargeException([String message = 'The image file exceeds the maximum allowed size.'])
      : super(statusCode: 413, errorCode: 'IMAGE_TOO_LARGE', message: message);
}

class NoLeafFoundException extends ApiException {
  const NoLeafFoundException([String message = 'No crop leaf could be detected in the uploaded photo.'])
      : super(statusCode: 422, errorCode: 'NO_LEAF_DETECTED', message: message);
}

class ServerException extends ApiException {
  const ServerException([String message = 'An internal inference server error occurred. Please try again later.'])
      : super(statusCode: 500, errorCode: 'SERVER_ERROR', message: message);
}

class NetworkTimeoutException extends ApiException {
  const NetworkTimeoutException([String message = 'The server request timed out after 20 seconds.'])
      : super(statusCode: 408, errorCode: 'TIMEOUT', message: message);
}

class BackendUnavailableException extends ApiException {
  const BackendUnavailableException(String baseUrl)
      : super(
          statusCode: 503,
          errorCode: 'BACKEND_UNAVAILABLE',
          message:
              'Backend পাওয়া যাচ্ছে না ($baseUrl)। ফোন ও PC একই Wi-Fi-তে রাখুন; localhost নয়, PC-র Wi-Fi IP ব্যবহার করুন।',
        );
}

class OfflineException extends ApiException {
  const OfflineException([String message = 'No active internet connection. Image has been queued locally.'])
      : super(statusCode: 0, errorCode: 'OFFLINE', message: message);
}
