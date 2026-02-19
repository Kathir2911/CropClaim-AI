/// Cross-platform camera service.
/// On mobile (dart:io available): uses real camera package.
/// On web: uses stub that always falls back to demo mode.
export 'camera_service_stub.dart'
    if (dart.library.io) 'camera_service_impl.dart';
