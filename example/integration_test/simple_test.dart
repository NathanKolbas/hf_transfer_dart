import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hf_transfer/hf_transfer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await HfTransfer.ensureInitialized(throwOnFail: true));

  test('Can get version', () async {
    expect(HfTransfer.version, isNotEmpty);
  });
}
