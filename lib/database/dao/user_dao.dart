import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/user_dto.dart';

class UserDao {
  static const String _usersKey = 'users_list';
  static const String _nextIdKey = 'next_user_id';

  // Buscar todos os usuários
  Future<List<UserDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      return usersJson.map((json) => UserDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  // Inserir usuário
  Future<int> insert(UserDto user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newUser = user.copyWith(id: nextId);
      
      users.add(newUser);
      await _saveUsers(users);
      await prefs.setInt(_nextIdKey, nextId + 1);
      
      return nextId;
    } catch (e) {
      print('Erro ao inserir usuário: $e');
      throw Exception('Erro ao salvar usuário');
    }
  }

  // Atualizar usuário
  Future<int> update(UserDto user) async {
    try {
      final users = await findAll();
      final index = users.indexWhere((u) => u.id == user.id);
      
      if (index != -1) {
        users[index] = user;
        await _saveUsers(users);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      throw Exception('Erro ao atualizar usuário');
    }
  }

  // Deletar usuário
  Future<int> delete(int id) async {
    try {
      final users = await findAll();
      final initialLength = users.length;
      users.removeWhere((user) => user.id == id);
      await _saveUsers(users);
      return initialLength - users.length;
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      throw Exception('Erro ao deletar usuário');
    }
  }

  // Buscar por email
  Future<UserDto?> findByEmail(String email) async {
    try {
      final users = await findAll();
      return users.cast<UserDto?>().firstWhere(
        (user) => user?.email == email,
        orElse: () => null,
      );
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
      return null;
    }
  }

  // Buscar por profissão
  Future<List<UserDto>> findByProfession(String profession) async {
    try {
      final users = await findAll();
      return users.where((user) => 
        user.profession.toLowerCase().contains(profession.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erro ao buscar usuários por profissão: $e');
      return [];
    }
  }

  // Verificar se email existe
  Future<bool> emailExists(String email) async {
    final user = await findByEmail(email);
    return user != null;
  }

  // Método privado para salvar usuários
  Future<void> _saveUsers(List<UserDto> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  // Limpar todos os dados (útil para testes)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_nextIdKey);
  }

  // Método para adicionar dados de exemplo (para testes)
  Future<void> addSampleData() async {
    final users = await findAll();
    if (users.isEmpty) {
      await insert(UserDto(name: 'João Silva', email: 'joao@email.com', profession: 'Professor'));
      await insert(UserDto(name: 'Maria Santos', email: 'maria@email.com', profession: 'Aluna'));
      await insert(UserDto(name: 'Carlos Oliveira', email: 'carlos@email.com', profession: 'Administrador'));
    }
  }
}
