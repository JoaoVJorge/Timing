import "package:get/get.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";

class SubjectStatsBindings extends Bindings {
  @override
  void dependencies() {
    final SubjectEntity subject = RouteArguments.of<SubjectEntity>(
      AppRoutes.subjectStats,
    );

    Get.put<SubjectStatsController>(
      SubjectStatsController(
        subject: subject,
        subjectDailyHistoryService: Get.find(),
      ),
    );
  }
}
