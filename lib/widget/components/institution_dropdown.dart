import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../database/dao/institution_dao.dart';
import '../../database/dao/area_dao.dart';
import '../../dto/institution_dto.dart';
import '../../dto/area_dto.dart';

class InstitutionDropdown extends StatefulWidget {
  final InstitutionDto? value;
  final ValueChanged<InstitutionDto?> onChanged;
  final String? Function(InstitutionDto?)? validator;

  const InstitutionDropdown({
    Key? key,
    this.value,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<InstitutionDropdown> createState() => _InstitutionDropdownState();
}

class _InstitutionDropdownState extends State<InstitutionDropdown> {
  final InstitutionDao _institutionDao = InstitutionDao();
  final AreaDao _areaDao = AreaDao();
  List<InstitutionDto> _institutions = [];
  List<AreaDto> _areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final areas = await _areaDao.findAll();
      final institutions = await _institutionDao.findAll();
      setState(() {
        _areas = areas;
        _institutions = institutions;
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
        : Column(
            children: [
              DropdownButtonFormField<InstitutionDto>(
                value: widget.value,
                decoration: InputDecoration(
                  labelText: 'Instituição',
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
                items: _institutions.map((InstitutionDto institution) {
                  return DropdownMenuItem<InstitutionDto>(
                    value: institution,
                    child: Text('${institution.name} - ${_getAreaName(institution.area)}'),
                  );
                }).toList(),
                onChanged: widget.onChanged,
                validator: widget.validator,
              ),
            ],
          );
  }

  String _getAreaName(String areaId) {
    final area = _areas.firstWhere(
      (a) => a.id.toString() == areaId,
      orElse: () => AreaDto(name: 'Área não encontrada', description: ''),
    );
    return area.name;
  }
}