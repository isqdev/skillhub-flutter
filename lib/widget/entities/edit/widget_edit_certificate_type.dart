// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:meu_app/app_colors.dart';
// import '../../../database/dao/user_dao.dart';
// import '../../../database/dao/tag_dao.dart';
// import '../../../dto/user_dto.dart';
// import '../../../dto/tag_dto.dart';
// import '../../components/institution_dropdown.dart';

// class WidgetEditCertificateType extends StatefulWidget {
//   final CertificateTypeDto certificateType;
  
//   const WidgetEditCertificateType({super.key, required this.certificateType});

//   @override
//   State<WidgetEditCertificateType> createState() => _WidgetEditCertificateTypeState();
// }

// class _WidgetEditCertificateTypeState extends State<WidgetEditCertificateType> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nomeController = TextEditingController();
//   final TextEditingController _horasController = TextEditingController();
//   final TextEditingController _tagsController = TextEditingController();
//   String? _tipoSelecionado;
//   InstitutionDto? _selectedInstitution;
//   bool _isLoading = false;
//   bool _isLoadingTags = true;
//   bool _isLoadingUsers = true;
//   int? _usuarioSelecionado;
  
//   final UserDao _userDao = UserDao();
//   final TagDao _tagDao = TagDao();
//   final List<String> tipos = ['Curso', 'Minicurso', 'Evento'];
//   List<UserDto> _users = [];
//   List<TagDto> _allTags = [];
//   List<TagDto> _selectedTags = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadTags();
//     _loadUsers();
//     _initializeData();
//   }

//   void _initializeData() {
//     _nomeController.text = widget.certificateType.name;
//     _horasController.text = widget.certificateType.hours.toString();
//     _selectedInstitution = widget.certificateType.institution;
//     _tipoSelecionado = widget.certificateType.type;
//     _selectedTags = widget.certificateType.tags;
//     _usuarioSelecionado = widget.certificateType.userId;
//   }

//   Future<void> _loadUsers() async {
//     try {
//       final users = await _userDao.findAll();
//       setState(() {
//         _users = users;
//         _isLoadingUsers = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoadingUsers = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erro ao carregar usuários: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _loadTags() async {
//     try {
//       final tags = await _tagDao.findAll();
//       setState(() {
//         _allTags = tags;
//         _isLoadingTags = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoadingTags = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erro ao carregar tags: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _updateCertificate() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         final updatedCertificate = widget.certificateType.copyWith(
//           name: _nomeController.text.trim(),
//           hours: int.parse(_horasController.text.trim()),
//           institution: _selectedInstitution,
//           type: _tipoSelecionado,
//           tags: _selectedTags,
//           userId: _usuarioSelecionado,
//         );

//         await _certificateTypeDao.update(updatedCertificate);

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Certificado atualizado com sucesso!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context, true);
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Erro ao atualizar certificado: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Editar Certificado", style: TextStyle(color: AppColors.white)),
//         iconTheme: IconThemeData(color: Colors.white),
//         centerTitle: true,
//         backgroundColor: AppColors.gray500,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Nome
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: TextFormField(
//                   style: TextStyle(color: AppColors.white),
//                   controller: _nomeController,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     labelText: 'Nome do certificado',
//                   ),
//                   validator: (value) =>
//                       value == null || value.isEmpty ? 'Campo obrigatório' : null,
//                 ),
//               ),

//               // Usuário
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: DropdownButtonFormField<int>(
//                   value: _usuarioSelecionado,
//                   onChanged: _isLoadingUsers
//                       ? null
//                       : (int? newValue) {
//                           setState(() {
//                             _usuarioSelecionado = newValue;
//                           });
//                         },
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     labelText: 'Usuário',
//                   ),
//                   items: _users.map((user) {
//                     return DropdownMenuItem<int>(
//                       value: user.id,
//                       child: Text(user.name, style: TextStyle(color: AppColors.white)),
//                     );
//                   }).toList(),
//                   validator: (value) =>
//                       value == null ? 'Selecione um usuário' : null,
//                 ),
//               ),

//               // Instituição
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: InstitutionDropdown(
//                   value: _selectedInstitution,
//                   onChanged: (InstitutionDto? newValue) {
//                     setState(() {
//                       _selectedInstitution = newValue;
//                     });
//                   },
//                   validator: (value) =>
//                       value == null ? 'Selecione uma instituição' : null,
//                 ),
//               ),

//               // Tipo
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text('Tipo', style: TextStyle(color: AppColors.white)),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: tipos.map((tipo) {
//                         final isSelected = _tipoSelecionado == tipo;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _tipoSelecionado = tipo;
//                             });
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                             decoration: BoxDecoration(
//                               color: isSelected ? AppColors.teal : AppColors.gray500,
//                               borderRadius: BorderRadius.circular(20.0),
//                             ),
//                             child: Text(
//                               tipo,
//                               style: TextStyle(
//                                 color: isSelected ? AppColors.white : AppColors.white70,
//                                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),

//               // Horas
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: TextFormField(
//                   style: TextStyle(color: AppColors.white),
//                   controller: _horasController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     labelText: 'Horas',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Campo obrigatório';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Digite um número válido';
//                     }
//                     return null;
//                   },
//                 ),
//               ),

//               // Tags
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text('Tags', style: TextStyle(color: AppColors.white)),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8.0,
//                       children: _allTags.map((tag) {
//                         final isSelected = _selectedTags.contains(tag);
//                         return ChoiceChip(
//                           label: Text(tag.name, style: TextStyle(color: AppColors.white)),
//                           selected: isSelected,
//                           onSelected: _isLoadingTags
//                               ? null
//                               : (selected) {
//                                   setState(() {
//                                     if (selected) {
//                                       _selectedTags.add(tag);
//                                     } else {
//                                       _selectedTags.remove(tag);
//                                     }
//                                   });
//                                 },
//                           selectedColor: AppColors.teal,
//                           backgroundColor: AppColors.gray500,
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : () => Navigator.pop(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.gray500,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                         fixedSize: const Size(double.infinity, 53),
//                       ),
//                       child: Text(
//                         "Cancelar",
//                         style: TextStyle(color: AppColors.white, fontSize: 18),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _updateCertificate,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.teal,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                         fixedSize: const Size(double.infinity, 53),
//                       ),
//                       child: _isLoading
//                           ? SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: AppColors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               "Salvar",
//                               style: TextStyle(
//                                 color: AppColors.white,
//                                 fontSize: 18,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nomeController.dispose();
//     _horasController.dispose();
//     _tagsController.dispose();
//     super.dispose();
//   }
// }