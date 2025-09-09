import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sfs_client_method_channel.dart';

abstract class SfsClientPlatform extends PlatformInterface {
  /// Constructs a SfsClientPlatform.
  SfsClientPlatform() : super(token: _token);

  static final Object _token = Object();

  static SfsClientPlatform _instance = MethodChannelSfsClient();

  /// The default instance of [SfsClientPlatform] to use.
  ///
  /// Defaults to [MethodChannelSfsClient].
  static SfsClientPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SfsClientPlatform] when
  /// they register themselves.
  static set instance(SfsClientPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
