# HF Transfer

Speed up file transfers with the Hub.

This is based off the official [hf_transfer](https://github.com/huggingface/hf_transfer) but with bindings for Dart.

This library uses the awesome [flutter_rust_bridge](https://pub.dev/packages/flutter_rust_bridge) to make the dart <-> rust bindings easier.

Unfortunately, this library requires flutter. While flutter_rust_bridge does support pure dart, [the official toolchain](https://github.com/dart-lang/native/issues/883) for this has yet to be released. When this is done this library will be pure dart. You can find more information noted in [flutter_rust_bridge's documentation](https://cjycode.com/flutter_rust_bridge/guides/miscellaneous/pure-dart).

## DISCLAIMER

This library is a power user tool, to go beyond `~500MB/s` on very high bandwidth
network, where Python (Is Dart/Flutter effected by this?) cannot cap out the available bandwidth.

This is *not* meant to be a general usability tool.
It purposefully lacks progressbars and comes generally as-is.

Please file issues *only* if there's an issue on the underlying downloaded file.

## Differences

You might be wondering what's the difference between just using `huggingface_hub` or Xet. The best info I could find comes from this [comment on Reddit](https://www.reddit.com/r/LocalLLaMA/comments/1ise5ly/comment/mdluygv/):

```
Hey, maintainer of `huggingface_hub`/`huggingface-cli` here 👋 I can't tell why you are constantly witnessing this 10.4MB/s limitation. I can assure you this is not something we enforce server-side. Available bandwidth is supposed to be the same no matter which tool you use (huggingface-cli, hf_transfer, wget, curl, etc.) as we never prioritize downloads based on user-agents. Speed difference between these tools are due to how they work rather than a deliberate decision on HF side.

`hf_transfer` is indeed much faster to download files on machines with a high bandwidth since it splits a file in chunks and download them in parallel, using all CPU cores at once. When doing so, files are downloaded 1 by 1 otherwise the CPU could be bloated (imagine downloading 10 files in parallel and that for each file we spawn N threads). This explains why disabling hf_transfer lead to 8 parallel downloads in https://www.reddit.com/r/LocalLLaMA/comments/1ise5ly/comment/mdgtrqi.

Note that we do not enable `hf_transfer` by default in `huggingface-cli` for a few reasons:
- if anything happens during the download, it is a nightmare to debug (because of parallelization + rust<>Python binding) => more maintainer work
- in many cases, hf_transfer do not provide any boost since download speed is limited by user's machine
- UX is slightly degraded with hf_transfer (progress bar less responsive, hectic ctrl+C behavior, etc.)
- hf_transfer do not handle stuff like resumable downloads, proxies, etc
- since it spawns 1 process per CPU core, it can freeze/downgrade performances on user's machine. hf_transfer is great but in general gives a boost only on machines with a high bandwidth. That's why the repo says (>500MB/s) even though this number is arbitrary. Best way to know the speed boost it provides in a specific case is... to test it 🤷

And finally, as mentioned by jsulz in https://www.reddit.com/r/LocalLLaMA/comments/1ise5ly/comment/mdis8ln, we are actively working on drastically improving upload/download experience on the platform thanks to our collaboration with the Xet-team. Stay tuned, it'll be big!
```

## Setup

To make sure everything is set up call `HfTransfer.ensureInitialized` from the initialization of your application. Here is an example for a flutter application:

```dart
import 'package:flutter/widgets.dart';
import 'package:hf_transfer/hf_transfer.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await HfTransfer.ensureInitialized();
  
  // Rest of your main function...
}
```

### MacOS

You may need the internet permission so that models can be downloaded. To do this add the following to both your `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

If you are looking for a concrete example checkout the `example/` directory.

TODO: This might be possible to put directly in the package so others don't have to do this

### iOS

You may need the internet permission so that models can be downloaded. To do this add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
   <key>NSAllowsArbitraryLoads</key><true/>
</dict>
```

I did not have to do this but just in case you run into this issue you'll know how to fix it.

TODO: This might be possible to put directly in the package so others don't have to do this
