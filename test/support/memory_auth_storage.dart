import 'package:unipar_trilha_app/core/auth_session.dart';

class MemoryAuthStorage implements AuthStorage {
  StoredAuthSession? value;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls++;
    value = null;
  }

  @override
  Future<StoredAuthSession?> read() async => value;

  @override
  Future<void> write(StoredAuthSession session) async {
    value = session;
  }
}
