import 'package:flutter/material.dart';
import 'package:meu_app/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import './../settings/routes.dart';
import '../database/dao/certificate_dao.dart';
import '../database/dao/tag_dao.dart';
import '../database/dao/user_dao.dart';
import '../database/dao/event_dao.dart'; // ADICIONE ESTA LINHA
import '../database/dao/institution_dao.dart'; // ADICIONE ESTA LINHA
import '../database/dao/area_dao.dart'; // ADICIONE ESTA LINHA
import '../dto/certificate_dto.dart';
import '../dto/tag_dto.dart';
import '../dto/user_dto.dart';
import '../dto/event_dto.dart'; // ADICIONE ESTA LINHA
import '../dto/institution_dto.dart'; // ADICIONE ESTA LINHA
import '../dto/area_dto.dart'; // ADICIONE ESTA LINHA

class WidgetDashboard extends StatefulWidget {
  const WidgetDashboard({super.key});

  @override
  State<WidgetDashboard> createState() => _WidgetDashboardState();
}

class _WidgetDashboardState extends State<WidgetDashboard> with WidgetsBindingObserver {
  final CertificateDao _certificateDao = CertificateDao();
  final TagDao _tagDao = TagDao();
  final UserDao _userDao = UserDao();
  final EventDao _eventDao = EventDao();
  final InstitutionDao _institutionDao = InstitutionDao(); // ADICIONE
  final AreaDao _areaDao = AreaDao(); // ADICIONE
  
  Map<String, int> _tagCounts = {};
  List<EventDto> _events = [];
  List<CertificateDto> _certificates = [];
  List<UserDto> _users = [];
  
  // NOVAS VARIÁVEIS para contagem das entidades
  int _userCount = 0;
  int _certificateCount = 0;
  int _eventCount = 0;
  int _institutionCount = 0;
  int _areaCount = 0;
  int _tagCount = 0;
  
  bool _isLoading = true;
  int _totalCertificates = 0;
  int _currentPageIndex = 1; // Começar na página do meio (índice 1)
  
  // NOVA VARIÁVEL: Controller para o scroll dos eventos
  final ScrollController _eventsScrollController = ScrollController();
  // NOVA VARIÁVEL: Controller para o scroll dos certificados
  final ScrollController _certificatesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadChartData();
  }

  @override
  void dispose() {
    _eventsScrollController.dispose(); // ADICIONE ESTA LINHA
    _certificatesScrollController.dispose(); // NOVA LINHA
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Atualizar quando o app voltar ao foco
    if (state == AppLifecycleState.resumed) {
      _loadChartData();
    }
  }

  // Método para detectar quando a tela volta ao foco (quando navega de volta)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar dados sempre que a tela for exibida
    Future.delayed(Duration.zero, () {
      _loadChartData();
    });
  }

  // Método para carregar dados incluindo contagens
  Future<void> _loadChartData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Garantir que dados de exemplo existam
      await _certificateDao.addSampleData();
      await _tagDao.addSampleData();
      await _userDao.addSampleData();
      await _eventDao.addSampleData();
      // Adicione outros se necessário

      // Carregar todos os dados
      final certificates = await _certificateDao.findAll();
      final events = await _eventDao.findAll();
      final users = await _userDao.findAll();
      final tags = await _tagDao.findAll();
      // Carregue outras entidades se tiver DAOs
    
      final Map<String, int> tagCounts = {};

      // Contar certificados por tag
      for (var certificate in certificates) {
        for (var tag in certificate.tags) {
          tagCounts[tag.name] = (tagCounts[tag.name] ?? 0) + 1;
        }
      }

      // Pegar apenas as top 5 tags mais usadas
      var sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      var topTags = Map.fromEntries(sortedTags.take(5));

      setState(() {
        _tagCounts = topTags;
        _events = events;
        _certificates = certificates;
        _users = users;
        _totalCertificates = certificates.length;
        
        // NOVO: Definir contagens das entidades
        _userCount = users.length;
        _certificateCount = certificates.length;
        _eventCount = events.length;
        _institutionCount = 0; // Atualize quando tiver InstitutionDao
        _areaCount = 0; // Atualize quando tiver AreaDao
        _tagCount = tags.length;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard", style: TextStyle(color: AppColors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.gray500,
        actions: [
          // Botão de refresh manual
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadChartData,
            tooltip: 'Atualizar dados',
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
            tooltip: 'Meu perfil',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadChartData,
            color: AppColors.teal,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    // Conteúdo da página atual
                    _buildCurrentPage(),
                    SizedBox(height: 100), // Espaço para os botões inferiores
                  ],
                ),
              ),
            ),
          ),
          
          // Botões inferiores fixos
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.gray500,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Botão Página Esquerda (0)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentPageIndex = 0;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 0 ? AppColors.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty, // ampulheta para representar "Legacy"
                                color: AppColors.white,
                                size: 20,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Legacy',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Botão Página Meio (1) - Página Principal
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentPageIndex = 1;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 1 ? AppColors.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home,
                                color: AppColors.white,
                                size: 20,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Principal',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Botão Página Direita (2)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentPageIndex = 2;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _currentPageIndex == 2 ? AppColors.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings,
                                color: AppColors.white,
                                size: 20,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Config',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir a página atual
  Widget _buildCurrentPage() {
    switch (_currentPageIndex) {
      case 0:
        return _buildLeftPage(); // Página Esquerda - Cópia da Principal
      case 1:
        return _buildMainPage(); // Página Principal (com gráfico)
      case 2:
        return _buildRightPage(); // Página de Configurações
      default:
        return _buildMainPage();
    }
  }

  // Página Esquerda - Cópia da Principal
  Widget _buildLeftPage() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        DashboardButton(
          icon: Icons.person_add,
          title: "Cadastro de\nUsuário",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.user);
            _loadChartData();
          },
        ),
        DashboardButton(
          icon: Icons.card_membership,
          title: "Certificados",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.certificates);
            _loadChartData();
          },
        ),
        DashboardButton(
          icon: Icons.event,
          title: "Eventos",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.events);
            _loadChartData();
          },
        ),
        DashboardButton(
          icon: Icons.business,
          title: "Instituições",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.instituition);
            _loadChartData();
          },
        ),
        DashboardButton(
          icon: Icons.category,
          title: "Áreas",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.areas);
            _loadChartData();
          },
        ),
        DashboardButton(
          icon: Icons.label,
          title: "Tags",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.tags);
            _loadChartData();
          },
        ),
        DashboardButton(
          icon: Icons.assignment,
          title: "Tipo de\nCertificado",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.certificateTypes);
            _loadChartData();
          },
        ),
        DashboardButton(
          icon: Icons.favorite,
          title: "Cursos\nFavoritos",
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.favoriteCourses);
            _loadChartData();
          },
        ),
      ],
    );
  }

  // Página Principal com Gráfico Real dos Certificados
  Widget _buildMainPage() {
    return Column(
      children: [
        // Card com PieChart dos dados reais
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.gray400,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Temas mais populares',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Indicador de loading pequeno
                  if (_isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.teal,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.teal,
                        ),
                      ),
                    )
                  : _tagCounts.isEmpty
                      ? Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pie_chart_outline,
                                  size: 48,
                                  color: AppColors.white.withOpacity(0.6),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhum dado disponível',
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _generatePieChartSections(),
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  // Opcional: adicionar interatividade
                                },
                              ),
                            ),
                          ),
                        ),
              SizedBox(height: 16),
              // Legenda
              _buildLegend(),
            ],
          ),
        ),
        
        SizedBox(height: 30),
        
        // Grid circular - 3 por linha
        _buildCircularGrid(),
        
        SizedBox(height: 30),
        
        // NOVO: Seção de certificados horizontais
        _buildCertificatesHorizontalSection(),
        
        SizedBox(height: 30),
        
        // NOVO: Seção de eventos horizontais
        _buildEventsHorizontalSection(),
      ],
    );
  }

  // NOVO: Método para encontrar usuário por ID
  UserDto? _findUserById(int? userId) {
    if (userId == null) return null;
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // NOVO: Método para seção horizontal de certificados
  Widget _buildCertificatesHorizontalSection() {
    // Pegar apenas os últimos 5 certificados (assumindo que os mais recentes têm ID maior)
    List<CertificateDto> recentCertificates = [];
    if (_certificates.isNotEmpty) {
      // Ordenar por ID decrescente para pegar os mais recentes
      List<CertificateDto> sortedCertificates = List.from(_certificates);
      sortedCertificates.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      recentCertificates = sortedCertificates.take(5).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da seção
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Certificados',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Container com os certificados horizontais
        Container(
          height: 180,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                  ),
                )
              : SingleChildScrollView(
                  controller: _certificatesScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Cards dos certificados reais
                      ...recentCertificates.map((certificate) {
                        final user = _findUserById(certificate.userId);
                        return Container(
                          width: 287,
                          margin: EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.gray400,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Conteúdo principal do card
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Cabeçalho com ícone e nome
                                    Row(
                                      children: [
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: AppColors.teal,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.card_membership,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                certificate.name,
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                certificate.institution.name,
                                                style: TextStyle(
                                                  color: AppColors.teal,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    
                                    // Descrição/tags do certificado
                                    Expanded(
                                      child: certificate.tags.isNotEmpty
                                          ? SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: certificate.tags.take(3).map((tag) => Padding(
                                                  padding: EdgeInsets.only(right: 4),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.gray500,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      tag.name,
                                                      style: TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                )).toList(),
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                'Sem tags disponíveis',
                                                style: TextStyle(
                                                  color: AppColors.white.withOpacity(0.6),
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                    ),
                                                                        
                                    // Informações do certificado
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: AppColors.white.withOpacity(0.7),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${certificate.hours}h • ${certificate.type}',
                                          style: TextStyle(
                                            color: AppColors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // NOVO: Foto de perfil do usuário no canto inferior direito
                              if (user != null)
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.teal,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: user.imageUrl.isNotEmpty
                                          ? Image.network(
                                              user.imageUrl,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: AppColors.gray500,
                                                  child: Icon(
                                                    Icons.person,
                                                    color: AppColors.white,
                                                    size: 18,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: AppColors.gray500,
                                              child: Icon(
                                                Icons.person,
                                                color: AppColors.white,
                                                size: 18,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      // Card "Ver todos os certificados"
                      Container(
                        width: 287,
                        margin: EdgeInsets.only(right: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.gray500,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.teal.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: () async {
                              await Navigator.pushNamed(context, Routes.certificates);
                              _loadChartData();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.teal.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.teal,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Ver todos os certificados',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${_certificates.length} certificados cadastrados',
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      
        // NOVO: Setas posicionadas no canto inferior direito
        if (!_isLoading && recentCertificates.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12, right: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Seta esquerda
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gray500.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          final scrollAmount = 303.0; // 287 + 16 de margin
                          final currentOffset = _certificatesScrollController.offset;
                          final newOffset = (currentOffset - scrollAmount).clamp(0.0, double.infinity);
                          
                          _certificatesScrollController.animateTo(
                            newOffset,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Icon(
                          Icons.chevron_left,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  
                  // Seta direita
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gray500.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          final scrollAmount = 303.0; // 287 + 16 de margin
                          final maxScroll = _certificatesScrollController.position.maxScrollExtent;
                          final currentOffset = _certificatesScrollController.offset;
                          final newOffset = (currentOffset + scrollAmount).clamp(0.0, maxScroll);
                          
                          _certificatesScrollController.animateTo(
                            newOffset,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Adicionado: Método para seção horizontal de eventos
  Widget _buildEventsHorizontalSection() {
    // Pegar apenas os últimos 3 eventos (assumindo que os mais recentes têm ID maior)
    List<EventDto> recentEvents = [];
    if (_events.isNotEmpty) {
      // Ordenar por ID decrescente para pegar os mais recentes
      List<EventDto> sortedEvents = List.from(_events);
      sortedEvents.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      recentEvents = sortedEvents.take(3).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da seção
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Eventos',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Container com os eventos horizontais
        Container(
          height: 180,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                  ),
                )
              : SingleChildScrollView(
                  controller: _eventsScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Cards dos eventos reais
                      ...recentEvents.map((event) => Container(
                        width: 287,
                        margin: EdgeInsets.only(right: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.gray400,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho com ícone e nome
                            Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: AppColors.teal,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        event.institution,
                                        style: TextStyle(
                                          color: AppColors.teal,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Descrição do evento
                            if (event.description.isNotEmpty)
                              Expanded(
                                child: Text(
                                  event.description,
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Sem descrição disponível',
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            
                            SizedBox(height: 16),
                            
                          ],
                        ),
                      )).toList(),
                      
                      // Card "Ver todos os eventos"
                      Container(
                        width: 287,
                        margin: EdgeInsets.only(right: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.gray500,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.teal.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: () async {
                              await Navigator.pushNamed(context, Routes.events);
                              _loadChartData();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.teal.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.teal,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Ver todos os eventos',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${_events.length} eventos cadastrados',
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      
      // NOVO: Setas posicionadas no canto inferior direito
      if (!_isLoading && recentEvents.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(top: 12, right: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seta esquerda
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gray500.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        final scrollAmount = 303.0; // 287 + 16 de margin
                        final currentOffset = _eventsScrollController.offset;
                        final newOffset = (currentOffset - scrollAmount).clamp(0.0, double.infinity);
                        
                        _eventsScrollController.animateTo(
                          newOffset,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(
                        Icons.chevron_left,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Seta direita
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gray500.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        final scrollAmount = 303.0; // 287 + 16 de margin
                        final maxScroll = _eventsScrollController.position.maxScrollExtent;
                        final currentOffset = _eventsScrollController.offset;
                        final newOffset = (currentOffset + scrollAmount).clamp(0.0, maxScroll);
                        
                        _eventsScrollController.animateTo(
                          newOffset,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
  }

  // NOVO: Método para criar grid circular com 3 por linha
  Widget _buildCircularGrid() {
    final items = [
      {'icon': Icons.person_add, 'title': 'Usuários', 'route': Routes.user, 'count': _userCount},
      {'icon': Icons.card_membership, 'title': 'Certificados', 'route': Routes.certificates, 'count': _certificateCount},
      {'icon': Icons.event, 'title': 'Eventos', 'route': Routes.events, 'count': _eventCount},
      {'icon': Icons.business, 'title': 'Instituições', 'route': Routes.instituition, 'count': _institutionCount},
      {'icon': Icons.category, 'title': 'Áreas', 'route': Routes.areas, 'count': _areaCount},
      {'icon': Icons.label, 'title': 'Tags', 'route': Routes.tags, 'count': _tagCount},
    ];

    return Column(
      children: [
        // Primeira linha (3 itens)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularButton(
              icon: items[0]['icon'] as IconData,
              title: items[0]['title'] as String,
              route: items[0]['route'] as String,
              count: items[0]['count'] as int,
            ),
            _buildCircularButton(
              icon: items[1]['icon'] as IconData,
              title: items[1]['title'] as String,
              route: items[1]['route'] as String,
              count: items[1]['count'] as int,
            ),
            _buildCircularButton(
              icon: items[2]['icon'] as IconData,
              title: items[2]['title'] as String,
              route: items[2]['route'] as String,
              count: items[2]['count'] as int,
            ),
          ],
        ),
        SizedBox(height: 20),
        
        // Segunda linha (3 itens)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularButton(
              icon: items[3]['icon'] as IconData,
              title: items[3]['title'] as String,
              route: items[3]['route'] as String,
              count: items[3]['count'] as int,
            ),
            _buildCircularButton(
              icon: items[4]['icon'] as IconData,
              title: items[4]['title'] as String,
              route: items[4]['route'] as String,
              count: items[4]['count'] as int,
            ),
            _buildCircularButton(
              icon: items[5]['icon'] as IconData,
              title: items[5]['title'] as String,
              route: items[5]['route'] as String,
              count: items[5]['count'] as int,
            ),
          ],
        ),
      ],
    );
  }

  // ATUALIZADO: Método para criar botão circular com contador
  Widget _buildCircularButton({
    required IconData icon,
    required String title,
    required String route,
    required int count,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            // Círculo principal
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () async {
                    await Navigator.pushNamed(context, route);
                    _loadChartData();
                  },
                  child: Center(
                    child: Icon(
                      icon,
                      size: 35,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
            ),
            
            // NOVO: Badge com contador na diagonal superior direita
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gray500,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gray500,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final colors = [
      AppColors.teal,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];

    // Calcular o total de tags (não certificados)
    final totalTagCount = _tagCounts.values.fold(0, (sum, count) => sum + count);

    return _tagCounts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final tagEntry = entry.value;
      // Percentual baseado no total de tags, não certificados
      final percentage = totalTagCount > 0 ? (tagEntry.value / totalTagCount * 100) : 0.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: tagEntry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [
      AppColors.teal,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: _tagCounts.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final tagEntry = entry.value;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Text(
              '${tagEntry.key} (${tagEntry.value})',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Página Direita - Configurações (permanece igual)
  Widget _buildRightPage() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        DashboardButton(
          icon: Icons.person,
          title: "Meu\nPerfil",
          onPressed: () => Navigator.pushNamed(context, Routes.profile),
        ),
        DashboardButton(
          icon: Icons.palette,
          title: "Tema\nPersonalizado",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Configuração de Tema')),
            );
          },
        ),
        DashboardButton(
          icon: Icons.notifications,
          title: "Notificações",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Configurações de Notificação')),
            );
          },
        ),
        DashboardButton(
          icon: Icons.backup,
          title: "Backup\nDados",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Backup de Dados')),
            );
          },
        ),
        DashboardButton(
          icon: Icons.import_export,
          title: "Importar/\nExportar",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Importar/Exportar Dados')),
            );
          },
        ),
        DashboardButton(
          icon: Icons.help,
          title: "Ajuda e\nSuporte",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ajuda e Suporte')),
            );
          },
        ),
        DashboardButton(
          icon: Icons.info,
          title: "Sobre o\nApp",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sobre o App')),
            );
          },
        ),
        DashboardButton(
          icon: Icons.logout,
          title: "Sair",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirmar'),
                content: Text('Deseja realmente sair?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Implementar logout
                    },
                    child: Text('Sair'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// DashboardButton permanece igual
class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: AppColors.teal,
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}