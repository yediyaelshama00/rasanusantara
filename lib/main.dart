import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const RasaNusantaraApp());
}
