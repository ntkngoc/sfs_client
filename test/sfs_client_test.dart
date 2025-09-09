import 'package:flutter_test/flutter_test.dart';
import 'package:sfs_client/sfs_client.dart';
import 'package:sfs_client/sfs_client_platform_interface.dart';
import 'package:sfs_client/sfs_client_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSfsClientPlatform
    with MockPlatformInterfaceMixin
    implements SfsClientPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SfsClientPlatform initialPlatform = SfsClientPlatform.instance;

  test('$MethodChannelSfsClient is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSfsClient>());
  });

  // test('getPlatformVersion', () async {
  //   SfsClient sfsClientPlugin = SfsClient();
  //   MockSfsClientPlatform fakePlatform = MockSfsClientPlatform();
  //   SfsClientPlatform.instance = fakePlatform;
  //
  //   expect(await sfsClientPlugin.getPlatformVersion(), '42');
  // });
}
