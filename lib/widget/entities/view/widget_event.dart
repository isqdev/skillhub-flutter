import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import '../../../database/dao/event_dao.dart';
import '../../../dto/event_dto.dart';
import '../add/widget_add_event.dart';
import '../edit/widget_edit_event.dart';

class WidgetEvent extends StatefulWidget {
  const WidgetEvent({super.key});

  @override
  State<WidgetEvent> createState() => _WidgetEventState();
}

class _WidgetEventState extends State<WidgetEvent> {
  final EventDao _eventDao = EventDao();
  List<EventDto> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Adicionar dados de exemplo se não existir nenhum evento
      await _eventDao.addSampleData();

      final events = await _eventDao.findAll();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar eventos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent(EventDto event) async {
    try {
      if (event.id != null) {
        await _eventDao.delete(event.id!);
        await _loadEvents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${event.name} excluído com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editEvent(EventDto event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetEditEvent(
          event: event,
        ),
      ),
    );
    if (result == true) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eventos", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: 'Recarregar eventos',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetAddEvent(),
                ),
              );
              if (result == true) {
                _loadEvents();
              }
            },
            tooltip: 'Adicionar evento',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            )
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event,
                        size: 64,
                        color: AppColors.gray500,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum evento encontrado',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Adicione o primeiro evento clicando no botão abaixo',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  color: AppColors.teal,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: _events
                                .map((event) => EventCard(
                                      event: event,
                                      onDelete: () => _showDeleteDialog(event),
                                      onEdit: () => _editEvent(event),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WidgetAddEvent(),
            ),
          );
          if (result == true) {
            _loadEvents();
          }
        },
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add),
        label: Text(
          "Cadastrar evento",
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showDeleteDialog(EventDto event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.gray400,
          title: Text(
            'Confirmar exclusão',
            style: TextStyle(color: AppColors.white),
          ),
          content: Text(
            'Deseja realmente excluir "${event.name}"?',
            style: TextStyle(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent(event);
              },
              child: Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final EventDto event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal,
              ),
              child: Icon(
                Icons.event,
                size: 30,
                color: AppColors.white,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do evento
                Text(
                  event.name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                
                // Instituição como texto simples
                Text(
                  event.institution,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                
                // Descrição do evento
                if (event.description.isNotEmpty)
                  Text(
                    event.description,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                // Tags (se existirem - removidas conforme solicitado anteriormente)
                if (event.tags != null && event.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: event.tags.take(3).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gray500.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag.trim(),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.teal),
            color: AppColors.gray400,
            onSelected: (String value) {
              switch (value) {
                case 'editar':
                  if (onEdit != null) {
                    onEdit!();
                  }
                  break;
                case 'excluir':
                  if (onDelete != null) {
                    onDelete!();
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Editar',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
