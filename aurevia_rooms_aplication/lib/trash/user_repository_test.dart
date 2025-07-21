import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../data/services/user_model_repository.dart';
import '../../provider/auth_provider.dart';

class UserModelRepositoryTestScreen extends StatefulWidget {
  const UserModelRepositoryTestScreen({super.key});

  @override
  State<UserModelRepositoryTestScreen> createState() => _UserModelRepositoryTestScreenState();
}

class _UserModelRepositoryTestScreenState extends State<UserModelRepositoryTestScreen> {
  UserModel? _createdUser;
  List<UserModel> _searchResults = [];
  String _log = '';
  bool _isTesting = false;

  void _addLog(String message) {
    setState(() => _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log');
    debugPrint(message);
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isTesting = true;
      _log = '';
    });
    _addLog('=== INICIANDO PRUEBAS DE USUARIOS ===');

    //await _testCreateUser();
    await _testUpdateUser();
    await _testSearchUsers();
    //await _testDeleteUser();

    _addLog('=== PRUEBAS DE USUARIOS COMPLETADAS ===');
    setState(() => _isTesting = false);
  }

  Future<void> _testCreateUser() async {
    final ownerId = context.read<AuthProvider>().userId;
    if (ownerId == null) {
      _addLog('⚠️ Usuario no autenticado. Cancelando prueba de crear usuario.');
      return;
    }

    _addLog('▶️ Creando usuario para el usuario autenticado $ownerId...');
    final repo = context.read<UserModelRepository>();

    final newUser = UserModel(
      authUserId: ownerId,
      username: 'testuser-$ownerId',
      userType: 'client',
      email: 'testuser-$ownerId@example.com',
      createdAt: DateTime.now(),
      preferredLanguage: 'es',
      preferredTheme: {'color': 'dark'},
      profileImageUrl: 'https://example.com/test-profile.png',
      phoneNumber: '+51999999999',
    );

    try {
      final created = await repo.createUser(newUser);
      setState(() => _createdUser = created);
      _addLog('✅ Usuario creado: ${created.username}');
    } catch (e) {
      _addLog('❌ Error al crear usuario: $e');
    }
  }

Future<void> _testUpdateUser() async {
  final ownerId = context.read<AuthProvider>().userId;
  if (ownerId == null) {
    _addLog('⚠️ Usuario no autenticado. Cancelando prueba de actualizar usuario.');
    return;
  }

  _addLog('▶️ Actualizando usuario autenticado $ownerId...');
  final repo = context.read<UserModelRepository>();

  try {
    final currentUser = await repo.getUserById(ownerId);
    final updatedUser = currentUser.copyWith(
      preferredLanguage: 'fr',
      username: 'updateduser',
      email: 'updateduser-@example.com',
    );
    final result = await repo.updateUser(updatedUser);
    setState(() => _createdUser = result);
    _addLog('🔄 Usuario actualizado: Username: ${result.username}, Email: ${result.email}, Idioma: ${result.preferredLanguage}');
  } catch (e) {
    _addLog('❌ Error al actualizar usuario: $e');
  }
}


  Future<void> _testSearchUsers() async {
    _addLog('▶️ Buscando usuarios con "Alex"...');
    final repo = context.read<UserModelRepository>();

    try {
      final results = await repo.searchUsers('Alex');
      setState(() => _searchResults = results);
      _addLog('🔍 Encontrados ${results.length} usuarios.');
    } catch (e) {
      _addLog('❌ Error buscando usuarios: $e');
    }
  }

  Future<void> _testDeleteUser() async {
    final ownerId = context.read<AuthProvider>().userId;
    if (ownerId == null) {
      _addLog('⚠️ Usuario no autenticado. Cancelando prueba de eliminar usuario.');
      return;
    }

    _addLog('▶️ Eliminando usuario autenticado $ownerId...');
    final repo = context.read<UserModelRepository>();

    try {
      await repo.deleteUser(ownerId);
      _addLog('🗑️ Usuario eliminado correctamente.');
      setState(() {
        _createdUser = null;
        _searchResults.clear();
      });
    } catch (e) {
      _addLog('❌ Error eliminando usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas de UserModelRepository')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (_isTesting)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            const Divider(height: 30),
            Text('Usuarios encontrados en búsqueda:', style: Theme.of(context).textTheme.titleMedium),
            if (_searchResults.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Ninguno'),
              ),
            ..._searchResults.map((u) => Card(
              child: ListTile(
                title: Text('Usuario: ${u.username} (${u.userType})'),
                subtitle: Text('Email: ${u.email}\nTel: ${u.phoneNumber ?? 'n/a'}\nIdioma: ${u.preferredLanguage ?? 'n/a'}'),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTesting ? null : _runAllTests,
        child: const Icon(Icons.person_search),
      ),
    );
  }
}
