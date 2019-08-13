// TODO: Put public facing types in this file.

import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

class BadSocket extends Stream<List<int>> with IOSink implements Socket {
  final Socket _socket;
  final Random _ramdom = Random.secure();

  final int readLatency;
  // final int readVolatility;
  final int writeLatency;
  // final int writeVolatility;
  final double readLoss;
  final double writeLoss;

  /// Creates a BadSocket from another Socket
  BadSocket.wrap(
    this._socket, {
    this.readLatency = 0,
    this.writeLatency = 0,
    this.readLoss = 0.0,
    this.writeLoss = 0.0,
    // this.readVolatility = 15,
    // this.writeVolatility = 15,
  });

  listen(onData, {onError, onDone, cancelOnError}) {
    return _socket
        .asyncMap<List<int>>(_afterReadDelay)
        .where(_willSurviveRead)
        .listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  @override
  void add(List<int> data) {
    _withWriteCondition(
      () => _socket.add(data),
    );
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _socket.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return _socket
        .addStream(stream.asyncMap(_afterWriteDelay).where(_willSurviveWrite));
  }

  @override
  Future close() {
    return _socket.close();
  }

  @override
  Future flush() {
    return _socket.flush();
  }

  @override
  void write(Object obj) {
    _withWriteCondition(
      () => _socket.write(obj),
    );
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    _withWriteCondition(
      () => _socket.writeAll(objects, separator),
    );
  }

  @override
  void writeCharCode(int charCode) {
    _withWriteCondition(
      () => _socket.writeCharCode(charCode),
    );
  }

  @override
  void writeln([Object obj = ""]) {
    _withWriteCondition(
      () => _socket.writeln(obj),
    );
  }

  @override
  void destroy() {
    _socket.destroy();
  }

  @override
  Uint8List getRawOption(RawSocketOption option) {
    return _socket.getRawOption(option);
  }

  @override
  void setRawOption(RawSocketOption option) {
    _socket.setRawOption(option);
  }

  @override
  bool setOption(SocketOption option, bool enabled) {
    return _socket.setOption(option, enabled);
  }

  @override
  Future get done => _socket.done;

  @override
  InternetAddress get address => _socket.address;

  @override
  int get port => _socket.port;

  @override
  InternetAddress get remoteAddress => _socket.remoteAddress;

  @override
  int get remotePort => _socket.remotePort;

  _withWriteCondition(Function fn) {
    if(!_willSurviveWrite('')) return;
    Future.delayed(Duration(milliseconds: writeLatency), fn);
  }

  Future<List<int>> _afterReadDelay(List<int> data) {
    return Future.delayed(
      Duration(milliseconds: readLatency),
      () => data,
    );
  }

  Future<List<int>> _afterWriteDelay(List<int> data) {
    return Future.delayed(
      Duration(milliseconds: writeLatency),
      () => data,
    );
  }

  bool _willSurviveRead(_) {
    return _ramdom.nextDouble() > readLoss;
  }

  bool _willSurviveWrite(_) {
    return _ramdom.nextDouble() > writeLoss;
  }
}
