
## Api

```dart
BadSocket.wrap(Socket socket, {
  int readLatency,
  int readLoss,
  int writeLatency,
  int writeLoss,
});
```

## Usage

Basic example:

```dart
import 'dart:io';
import 'package:bad_socket/bad_socket.dart';

main() async {
  // 1. Create a normal socket.
  Socket socket = await Socket.bind('0.0.0.0', 1234);

  // 2. Wrap it.
  Socket badSocket = BadSocket.warp(socket,
    writeLatency: 100,
    writeLoss: 0.15,
  );

  // 3. Write to this wrapped socket will take effect
  //    after 100 ms,
  //    and 15% of write calls will be discarded.
  badSocket.add([0xCA, 0xFE]);
}
```

A complete example:
```dart
import 'dart:io';

import 'package:bad_socket/bad_socket.dart';

Future<int> startLocalEchoServer() async {
  final server = await ServerSocket.bind('0.0.0.0', 0);
  server.listen((socket) {
    final badSocket = BadSocket.wrap(
      socket,
      writeLatency: 100,
      writeLoss: 0.2,
    );
    badSocket.listen((data) {
      print('Server send: $data');
      badSocket.add(data);
      badSocket.flush();
    });
  });
  return server.port;
}

main() async {
  final port = await startLocalEchoServer();

  final client = await Socket.connect('127.0.0.1', port);
  client.listen((data) {
    print('Client recv: $data');
  });

  while (true) {
    final data = 'hello world'.runes.toList();
    data.shuffle();
    await Future.delayed(Duration(seconds: 1));
    print('Client send: $data');
    client.add(data);
    await client.flush();
  }
}

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/xtyxtyx/bad_socket/issues
