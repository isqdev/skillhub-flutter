import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/post_dto.dart';
import '../../dto/user_dto.dart';
import 'user_dao.dart';

class PostDao {
  static const String _postsKey = 'posts_list';
  static const String _nextIdKey = 'next_post_id';

  final UserDao _userDao = UserDao();

  // Buscar todos os posts
  Future<List<PostDto>> findAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getStringList(_postsKey) ?? [];
      return postsJson.map((json) => PostDto.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Erro ao buscar posts: $e');
      return [];
    }
  }

  // Inserir post
  Future<int> insert(PostDto post) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final posts = await findAll();
      
      // Gerar ID único
      final nextId = prefs.getInt(_nextIdKey) ?? 1;
      final newPost = post.copyWith(id: nextId);
      
      posts.add(newPost);
      await _savePosts(posts);
      await prefs.setInt(_nextIdKey, nextId + 1);
      
      return nextId;
    } catch (e) {
      print('Erro ao inserir post: $e');
      throw Exception('Erro ao salvar post');
    }
  }

  // Atualizar post
  Future<int> update(PostDto post) async {
    try {
      final posts = await findAll();
      final index = posts.indexWhere((p) => p.id == post.id);
      
      if (index != -1) {
        posts[index] = post;
        await _savePosts(posts);
        return 1;
      }
      return 0;
    } catch (e) {
      print('Erro ao atualizar post: $e');
      throw Exception('Erro ao atualizar post');
    }
  }

  // Deletar post
  Future<int> delete(int id) async {
    try {
      final posts = await findAll();
      final initialLength = posts.length;
      posts.removeWhere((post) => post.id == id);
      await _savePosts(posts);
      return initialLength - posts.length;
    } catch (e) {
      print('Erro ao deletar post: $e');
      throw Exception('Erro ao deletar post');
    }
  }

  // Buscar posts por usuário
  Future<List<PostDto>> findByUserId(int userId) async {
    try {
      final posts = await findAll();
      return posts.where((post) => post.userIds.contains(userId)).toList();
    } catch (e) {
      print('Erro ao buscar posts por usuário: $e');
      return [];
    }
  }

  // Método privado para salvar posts
  Future<void> _savePosts(List<PostDto> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = posts.map((post) => jsonEncode(post.toJson())).toList();
    await prefs.setStringList(_postsKey, postsJson);
  }

  // Limpar todos os dados
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postsKey);
    await prefs.remove(_nextIdKey);
  }

  // Método para adicionar dados de exemplo
  Future<void> addSampleData() async {
    try {
      final posts = await findAll();
      if (posts.isEmpty) {
        // Garantir que usuários existam primeiro
        await _userDao.addSampleData();
        
        // Buscar usuários existentes do banco de dados
        final users = await _userDao.findAll();
        
        if (users.isNotEmpty) {
          final samplePosts = [
            PostDto(
              userIds: [users[0].id!],
              description: 'Acabei de concluir meu curso de Flutter! 🚀 Estou muito animado para aplicar tudo que aprendi em novos projetos.',
              imageUrl: 'https://picsum.photos/400/300?random=1',
              createdAt: DateTime.now().subtract(Duration(hours: 2)),
            ),
            PostDto(
              userIds: [users.length > 1 ? users[1].id! : users[0].id!],
              description: 'Participei de um evento incrível sobre desenvolvimento mobile. As palestras foram muito inspiradoras! 💡',
              imageUrl: 'https://picsum.photos/400/300?random=2',
              createdAt: DateTime.now().subtract(Duration(hours: 6)),
            ),
            PostDto(
              userIds: users.length > 2 ? [users[0].id!, users[2].id!] : [users[0].id!],
              description: 'Trabalhando em equipe no nosso novo projeto! A colaboração está fluindo muito bem. 👥',
              createdAt: DateTime.now().subtract(Duration(days: 1)),
            ),
            PostDto(
              userIds: [users.length > 1 ? users[1].id! : users[0].id!],
              description: 'Dica do dia: sempre comentem bem o código! O "você do futuro" agradece. 😄',
              imageUrl: 'https://picsum.photos/400/300?random=3',
              createdAt: DateTime.now().subtract(Duration(days: 2)),
            ),
            PostDto(
              userIds: [users[0].id!],
              description: 'Explorando novas tecnologias e frameworks. O aprendizado nunca para! 📚',
              createdAt: DateTime.now().subtract(Duration(days: 3)),
            ),
          ];

          for (var post in samplePosts) {
            await insert(post);
          }
        }
      }
    } catch (e) {
      print('Erro ao adicionar dados de exemplo de posts: $e');
    }
  }
}