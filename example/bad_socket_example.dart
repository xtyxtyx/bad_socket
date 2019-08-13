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
