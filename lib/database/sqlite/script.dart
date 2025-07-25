class ScriptSQLite {
  // ===== COMANDOS DE CRIAÇÃO DE TABELAS =====
  
  // 1. Tabela de Usuários
  static const String _criarTabelaUsuarios = '''
    CREATE TABLE usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      profession TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 2. Tabela de Áreas
  static const String _criarTabelaAreas = '''
    CREATE TABLE areas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 3. Tabela de Tags
  static const String _criarTabelaTags = '''
    CREATE TABLE tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 4. Tabela de Tipos de Certificado
  static const String _criarTabelaTiposCertificado = '''
    CREATE TABLE certificate_types (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 5. Tabela de Instituições
  static const String _criarTabelaInstituicoes = '''
    CREATE TABLE institutions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      state TEXT NOT NULL,
      city TEXT NOT NULL,
      area TEXT NOT NULL,
      type TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 6. Tabela de Eventos
  static const String _criarTabelaEventos = '''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      institution TEXT NOT NULL,
      description TEXT NOT NULL,
      tags TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 7. Tabela de Certificados
  static const String _criarTabelaCertificados = '''
    CREATE TABLE certificates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      institution TEXT NOT NULL,
      type TEXT NOT NULL,
      hours INTEGER NOT NULL,
      tags TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // 8. Tabela de Cursos Favoritos
  static const String _criarTabelaCursosFavoritos = '''
    CREATE TABLE favorite_courses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      instructor TEXT NOT NULL,
      duration INTEGER NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // Variável pública com todos os comandos de criação
  static const List<String> comandosCriarTabelas = [
    _criarTabelaUsuarios,
    _criarTabelaAreas,
    _criarTabelaTags,
    _criarTabelaTiposCertificado,
    _criarTabelaInstituicoes,
    _criarTabelaEventos,
    _criarTabelaCertificados,
    _criarTabelaCursosFavoritos,
  ];

  // ===== COMANDOS DE INSERÇÃO =====
  
  // Inserções para Usuários (exemplos)
  static const List<String> _insercoesUsuarios = [
    "INSERT INTO usuarios (name, email, profession) VALUES ('João Silva', 'joao@email.com', 'Desenvolvedor')",
    "INSERT INTO usuarios (name, email, profession) VALUES ('Maria Santos', 'maria@email.com', 'Designer')",
    "INSERT INTO usuarios (name, email, profession) VALUES ('Pedro Costa', 'pedro@email.com', 'Analista')",
  ];

  // Inserções para Áreas
  static const List<String> _insercoesAreas = [
    "INSERT INTO areas (name, description) VALUES ('Tecnologia', 'Área focada em desenvolvimento de software e inovação')",
    "INSERT INTO areas (name, description) VALUES ('Design', 'Área focada em design gráfico e experiência do usuário')",
    "INSERT INTO areas (name, description) VALUES ('Marketing', 'Área focada em estratégias de marketing digital')",
    "INSERT INTO areas (name, description) VALUES ('Gestão', 'Área focada em administração e liderança')",
    "INSERT INTO areas (name, description) VALUES ('Educação', 'Área focada em ensino e desenvolvimento pedagógico')",
  ];

  // Inserções para Tags
  static const List<String> _insercoesTags = [
    "INSERT INTO tags (name) VALUES ('Flutter')",
    "INSERT INTO tags (name) VALUES ('Dart')",
    "INSERT INTO tags (name) VALUES ('Mobile')",
    "INSERT INTO tags (name) VALUES ('Web')",
    "INSERT INTO tags (name) VALUES ('Frontend')",
    "INSERT INTO tags (name) VALUES ('Backend')",
    "INSERT INTO tags (name) VALUES ('Design')",
    "INSERT INTO tags (name) VALUES ('UX/UI')",
    "INSERT INTO tags (name) VALUES ('JavaScript')",
    "INSERT INTO tags (name) VALUES ('Python')",
  ];

  // Inserções para Tipos de Certificado
  static const List<String> _insercoesTiposCertificado = [
    "INSERT INTO certificate_types (name, description) VALUES ('Curso Online', 'Certificado de conclusão de curso online')",
    "INSERT INTO certificate_types (name, description) VALUES ('Workshop', 'Certificado de participação em workshop')",
    "INSERT INTO certificate_types (name, description) VALUES ('Bootcamp', 'Certificado de conclusão de bootcamp intensivo')",
    "INSERT INTO certificate_types (name, description) VALUES ('Especialização', 'Certificado de especialização técnica')",
    "INSERT INTO certificate_types (name, description) VALUES ('Certificação Profissional', 'Certificado profissional reconhecido')",
  ];

  // Inserções para Instituições
  static const List<String> _insercoesInstituicoes = [
    "INSERT INTO institutions (name, state, city, area, type) VALUES ('Universidade Federal de Minas Gerais', 'Minas Gerais', 'Belo Horizonte', 'Educação Superior', 'Pública')",
    "INSERT INTO institutions (name, state, city, area, type) VALUES ('Instituto Tecnológico de Aeronáutica', 'São Paulo', 'São José dos Campos', 'Tecnologia', 'Pública')",
    "INSERT INTO institutions (name, state, city, area, type) VALUES ('SENAI', 'Rio de Janeiro', 'Rio de Janeiro', 'Educação Profissional', 'Sistema S')",
    "INSERT INTO institutions (name, state, city, area, type) VALUES ('Faculdade Central', 'Distrito Federal', 'Brasília', 'Educação', 'Privada')",
  ];

  // Inserções para Eventos
  static const List<String> _insercoesEventos = [
    "INSERT INTO events (name, institution, description, tags) VALUES ('Workshop Flutter', 'Instituto Federal', 'Workshop prático de desenvolvimento Flutter', 'tecnologia,programação,flutter')",
    "INSERT INTO events (name, institution, description, tags) VALUES ('Seminário de IA', 'Universidade Tecnológica', 'Seminário sobre inteligência artificial e machine learning', 'inteligência artificial,machine learning')",
    "INSERT INTO events (name, institution, description, tags) VALUES ('Hackathon 2025', 'Campus Universitário', 'Competição de desenvolvimento de soluções inovadoras', 'competição,desenvolvimento,inovação')",
    "INSERT INTO events (name, institution, description, tags) VALUES ('Palestra Tech', 'Centro de Convenções', 'Palestra sobre tendências tecnológicas do futuro', 'tecnologia,tendências,futuro')",
  ];

  // Inserções para Certificados
  static const List<String> _insercoesCertificados = [
    "INSERT INTO certificates (name, institution, type, hours, tags) VALUES ('Flutter Development', 'Google', 'Curso Online', 40, 'flutter,mobile,desenvolvimento')",
    "INSERT INTO certificates (name, institution, type, hours, tags) VALUES ('UX/UI Design', 'Adobe', 'Especialização', 60, 'design,ux,ui,criatividade')",
    "INSERT INTO certificates (name, institution, type, hours, tags) VALUES ('Python para Data Science', 'IBM', 'Bootcamp', 80, 'python,data science,análise')",
  ];

  // Inserções para Cursos Favoritos
  static const List<String> _insercoesCursosFavoritos = [
    "INSERT INTO favorite_courses (name, instructor, duration) VALUES ('Flutter Completo', 'Prof. João Silva', 120)",
    "INSERT INTO favorite_courses (name, instructor, duration) VALUES ('Design Thinking', 'Prof. Maria Santos', 40)",
    "INSERT INTO favorite_courses (name, instructor, duration) VALUES ('Desenvolvimento Web', 'Prof. Pedro Costa', 80)",
  ];

  // Lista com todos os comandos de inserção
  static const List<List<String>> comandosInsercoes = [
    _insercoesUsuarios,
    _insercoesAreas,
    _insercoesTags,
    _insercoesTiposCertificado,
    _insercoesInstituicoes,
    _insercoesEventos,
    _insercoesCertificados,
    _insercoesCursosFavoritos,
  ];
}