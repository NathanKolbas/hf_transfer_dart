import 'package:flutter/material.dart';
import 'package:hf_transfer/hf_transfer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HfTransfer.ensureInitialized(throwOnFail: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
            'Hi :)'
            '\n\n'
            'Version: ${HfTransfer.version}'
            '\n\n'
            'If you want to try out this library check out the example in hugginface_hub_dart',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
