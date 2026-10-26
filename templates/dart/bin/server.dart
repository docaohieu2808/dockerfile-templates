import 'dart:io';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('listening on ${server.port}');

  // Dart as PID 1 does not exit on SIGTERM unless it is handled.
  ProcessSignal.sigterm.watch().listen((_) => exit(0));

  await for (final request in server) {
    final isHealth = request.uri.path == '/health';
    request.response
      ..headers.contentType = ContentType.text
      ..write(isHealth ? '{"status":"ok"}\n' : 'Hello from Dart\n');
    await request.response.close();
  }
}
