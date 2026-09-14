import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthSession.instance;
  runApp(const UniparTrilhaApp());
}

class UniparTrilhaApp extends StatelessWidget {
  const UniparTrilhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Unipar Trilha', home: SizedBox.shrink());
  }
}
