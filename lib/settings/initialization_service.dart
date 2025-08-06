import '../database/dao/certificate_dao.dart';
import '../database/dao/user_dao.dart';
import '../database/dao/institution_dao.dart';
import '../database/dao/tag_dao.dart';
import '../database/dao/area_dao.dart';
import '../database/dao/event_dao.dart';
import '../database/dao/certificate_type_dao.dart';

class InitializationService {
  static Future<void> initialize() async {
    final certificateDao = CertificateDao();
    final userDao = UserDao();
    final institutionDao = InstitutionDao();
    final tagDao = TagDao();
    final areaDao = AreaDao();
    final eventDao = EventDao();
    final certificateTypeDao = CertificateTypeDao();
    
    // Adicionar dados de exemplo se necessário
    // A ordem é importante: primeiro entidades independentes, depois as dependentes
    await userDao.addSampleData();
    await areaDao.addSampleData();
    await tagDao.addSampleData();
    await certificateTypeDao.addSampleData();
    await institutionDao.addSampleData();
    await eventDao.addSampleData();
    await certificateDao.addSampleData(); // Por último, pois depende de todas as outras
  }
}