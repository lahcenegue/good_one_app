class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  const ApiResponse({
    this.data,
    this.error,
    this.success = false,
  });

  factory ApiResponse.success(T data) => ApiResponse(
        data: data,
        success: true,
      );

  factory ApiResponse.error(String message) => ApiResponse(
        error: message,
        success: false,
      );

  bool get hasData => data != null;
  bool get hasError => error != null;
}
