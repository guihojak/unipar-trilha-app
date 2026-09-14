import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/main.dart';

void main() {
  testWidgets('inicializa somente o MaterialApp base', (tester) async {
    await tester.pumpWidget(const UniparTrilhaApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byType(Scaffold), findsNothing);
  });
}
