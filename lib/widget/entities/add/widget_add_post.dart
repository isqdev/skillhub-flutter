import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../database/dao/post_dao.dart';
import '../../../database/dao/user_dao.dart';
import '../../../dto/post_dto.dart';
import '../../../dto/user_dto.dart';

class WidgetAddPost extends StatefulWidget {
  const WidgetAddPost({super.key});

  @override
  State<WidgetAddPost> createState() => _WidgetAddPostState();
}

class _WidgetAddPostState extends State<WidgetAddPost> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final PostDao _postDao = PostDao();
  final UserDao _userDao = UserDao();
  
  List<UserDto> _users = [];
  List<int> _selectedUserIds = [];
  bool _isLoading = false;
  bool _isLoadingUsers = true;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userDao.findAll();
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuários: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://file.io'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        setState(() {
          _uploadedImageUrl = jsonResponse['link'];
        });
      } else {
        throw Exception('Falha ao fazer upload da imagem');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer upload da imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selecione pelo menos um usuário'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final post = PostDto(
          userIds: _selectedUserIds,
          description: _descricaoController.text.trim(),
          imageUrl: _uploadedImageUrl,
          createdAt: DateTime.now(),
        );

        await _postDao.insert(post);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Post criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar post: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo Post", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
      ),
      body: _isLoadingUsers
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleção de usuários
                    Text(
                      'Selecionar usuários:',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.gray400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: _users.map((user) {
                          final isSelected = _selectedUserIds.contains(user.id);
                          return CheckboxListTile(
                            title: Text(
                              user.name,
                              style: TextStyle(color: AppColors.white),
                            ),
                            subtitle: Text(
                              user.profession,
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.7),
                              ),
                            ),
                            secondary: CircleAvatar(
                              backgroundImage: user.imageUrl != null 
                                ? NetworkImage(user.imageUrl!) 
                                : null,
                              backgroundColor: AppColors.teal,
                              child: user.imageUrl == null 
                                ? Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                    style: TextStyle(color: AppColors.white),
                                  )
                                : null,
                            ),
                            value: isSelected,
                            activeColor: AppColors.teal,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedUserIds.add(user.id!);
                                } else {
                                  _selectedUserIds.remove(user.id!);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Descrição
                    TextFormField(
                      style: TextStyle(color: AppColors.white),
                      controller: _descricaoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        labelText: 'O que você está pensando?',
                        labelStyle: TextStyle(color: AppColors.white),
                        hintText: 'Compartilhe suas ideias...',
                        hintStyle: TextStyle(
                          color: AppColors.white.withOpacity(0.5),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Botão para adicionar imagem
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isUploadingImage ? null : _pickImage,
                          icon: _isUploadingImage 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : Icon(Icons.image, color: AppColors.white),
                          label: Text(
                            _isUploadingImage ? 'Fazendo upload...' : 'Adicionar imagem',
                            style: TextStyle(color: AppColors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gray400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        if (_uploadedImageUrl != null)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                    
                    // Preview da imagem
                    if (_selectedImage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 30),
                    
                    // Botão de salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              )
                            : Text(
                                "Publicar",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }
}