import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'game_room.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _permissionCameraAndMicro();
  runApp(MyApp());
}

Future<void> _permissionCameraAndMicro() async {
  await PermissionHandler().requestPermissions(
    [PermissionGroup.camera, PermissionGroup.microphone],
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameRoom(),
    );
  }
}
