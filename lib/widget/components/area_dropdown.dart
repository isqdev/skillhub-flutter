import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../database/dao/area_dao.dart';
import '../../dto/area_dto.dart';

class AreaDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const AreaDropdown({
    Key? key,
    this.value,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<AreaDropdown> createState() => _AreaDropdownState();
}

class _AreaDropdownState extends State<AreaDropdown> {
  final AreaDao _areaDao = AreaDao();
  List<AreaDto> _areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await _areaDao.findAll();
      setState(() {
        _areas = areas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray500),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            ),
          )
        : DropdownButtonFormField<String>(
            value: widget.value,
            decoration: InputDecoration(
              labelText: 'Área',
              labelStyle: TextStyle(color: AppColors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: AppColors.gray500),
              ),
            ),
            dropdownColor: AppColors.gray500,
            style: TextStyle(color: AppColors.white),
            items: _areas.map((AreaDto area) {
              return DropdownMenuItem<String>(
                value: area.id.toString(),
                child: Text(area.name),
              );
            }).toList(),
            onChanged: widget.onChanged,
            validator: widget.validator,
          );
  }
}