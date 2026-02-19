/// Cross-platform image watermark service.
/// On mobile (dart:io available): applies GPS watermark and saves to folder.
/// On web: returns original path unchanged (no watermarking).
export 'image_watermark_service_stub.dart'
    if (dart.library.io) 'image_watermark_service_impl.dart';
