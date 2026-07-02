import "package:get/get.dart";
import "package:help_out/core/data/repositories/app_config_repository.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";

class RepositoriesBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AppConfigRepository>(AppConfigRepository(appConfigDataSource: Get.find()), permanent: true);
    Get.put<SubjectsRepository>(SubjectsRepository(subjectsDataSource: Get.find()), permanent: true);
  }
}
