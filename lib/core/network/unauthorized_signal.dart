import 'dart:async';

/// One-way channel from the API layer to the auth layer.
///
/// The API client must be able to report a 401 without depending on the auth
/// controller, and the auth controller depends on the API client — this breaks
/// that cycle instead of papering over it with a service locator.
class UnauthorizedSignal {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void emit() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
