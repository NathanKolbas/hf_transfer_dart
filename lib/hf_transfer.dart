library;

import 'dart:async' show FutureOr;

import 'src/rust/api.dart' as api;
import 'src/rust/frb_generated.dart' show RustLib;

void _callback(BigInt _) {}

/// max_files: Number of open file handles, which determines the maximum number of parallel downloads
/// parallel_failures:  Number of maximum failures of different chunks in parallel (cannot exceed max_files)
/// max_retries: Number of maximum attempts per chunk. (Retries are exponentially backed off + jitter)
///
/// The number of threads can be tuned by the environment variable `TOKIO_WORKER_THREADS` as documented in
/// https://docs.rs/tokio/latest/tokio/runtime/struct.Builder.html#method.worker_threads
Future<void> download({
  required String url,
  required String filename,
  required BigInt maxFiles,
  required BigInt chunkSize,
  BigInt? parallelFailures,
  BigInt? maxRetries,
  Map<String, String>? headers,
  FutureOr<void> Function(BigInt)? callback,
}) => api.download(
  url: url,
  filename: filename,
  maxFiles: maxFiles,
  chunkSize: chunkSize,
  parallelFailures: parallelFailures,
  maxRetries: maxRetries,
  headers: headers,
  callback: callback ?? _callback,
);

/// parts_urls: Dictionary consisting of part numbers as keys and the associated url as values
/// completion_url: The url that should be called when the upload is finished
/// max_files: Number of open file handles, which determines the maximum number of parallel uploads
/// parallel_failures:  Number of maximum failures of different chunks in parallel (cannot exceed max_files)
/// max_retries: Number of maximum attempts per chunk. (Retries are exponentially backed off + jitter)
///
/// The number of threads can be tuned by the environment variable `TOKIO_WORKER_THREADS` as documented in
/// https://docs.rs/tokio/latest/tokio/runtime/struct.Builder.html#method.worker_threads
///
/// See https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpuoverview.html for more information
/// on the multipart upload
Future<List<Map<String, String>>> multipartUpload({
  required String filePath,
  required List<String> partsUrls,
  required BigInt chunkSize,
  required BigInt maxFiles,
  BigInt? parallelFailures,
  BigInt? maxRetries,
  FutureOr<void> Function(BigInt)? callback,
}) => api.multipartUpload(
  filePath: filePath,
  partsUrls: partsUrls,
  chunkSize: chunkSize,
  maxFiles: maxFiles,
  parallelFailures: parallelFailures,
  maxRetries: maxRetries,
  callback: callback ?? _callback,
);

class HfTransfer {
  static final HfTransfer _instance = HfTransfer._internal();

  factory HfTransfer() => _instance;

  HfTransfer._internal();

  bool _initialized = false;

  /// If hf_transfer is initialized. Typically you don't need this and can just
  /// call [ensureInitialized] directly without checking if initialized prior.
  static bool get initialized => HfTransfer._instance._initialized;

  bool _supported = false;

  /// If hf_transfer is supported in the current environment. If
  /// [ensureInitialized] is not called first this will be false.
  static bool isSupported() => HfTransfer._instance._supported;

  static String get version => api.version();

  /// Make sure hf_transfer is initialized.
  ///
  /// If [throwOnFail] is set to true then an exception will be thrown if
  /// initialization fails. By default this is false so that you can check if
  /// hf_transfer is supported in the current environment.
  ///
  /// Returns [bool] whether or not initialization was successful. If
  /// [throwOnFail] is true then you must catch the error.
  static Future<bool> ensureInitialized({bool throwOnFail = false}) async {
    if (HfTransfer._instance._initialized) return true;

    try {
      await RustLib.init();

      HfTransfer._instance._initialized = true;
      HfTransfer._instance._supported = true;

      return HfTransfer._instance._initialized;
    } catch (_) {
      if (throwOnFail) {
        rethrow;
      }
    }

    return HfTransfer._instance._initialized;
  }
}
