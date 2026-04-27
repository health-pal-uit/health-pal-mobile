import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  Future<void> saveExpertIntent(bool isExpert);
  Future<bool> getExpertIntent();
  Future<void> clearExpertIntent();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  @override
  Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }

  @override
  Future<void> saveExpertIntent(bool isExpert) async {
    await storage.write(key: 'is_expert_intent', value: isExpert.toString());
  }

  @override
  Future<bool> getExpertIntent() async {
    final value = await storage.read(key: 'is_expert_intent');
    return value == 'true';
  }

  @override
  Future<void> clearExpertIntent() async {
    await storage.delete(key: 'is_expert_intent');
  }
}
