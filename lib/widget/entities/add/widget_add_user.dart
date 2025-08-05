import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:flutter/services.dart';
import '../../../database/dao/user_dao.dart';
import '../../../dto/user_dto.dart';

class WidgetAddUser extends StatefulWidget {
  const WidgetAddUser({super.key});

  @override
  State<WidgetAddUser> createState() => _WidgetAddUserState();
}

class _WidgetAddUserState extends State<WidgetAddUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();
  final UserDao _userDao = UserDao();
  bool _isLoading = false;

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = UserDto(
          name: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          profession: _profissaoController.text.trim(),
          imageUrl: '', // This will be set by the UserDao
        );

        await _userDao.insert(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar sucesso
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar usuário: $e'),
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
        title: Text("Cadastrar usuário", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
      ),
      body: Center(
        child: SizedBox(
          width: 287,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    style: TextStyle(color: AppColors.white),
                    controller: _nomeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: 'Nome',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                // Email
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    style: TextStyle(color: AppColors.white),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (!value.contains('@')) {
                        return 'Digite um email válido';
                      }
                      return null;
                    },
                  ),
                ),
                // Profissão
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    style: TextStyle(color: AppColors.white),
                    controller: _profissaoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      labelText: 'Profissão',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fixedSize: const Size(287, 53),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Cadastrar usuário",
                          style: TextStyle(color: AppColors.white, fontSize: 20),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _profissaoController.dispose();
    super.dispose();
  }
}