import "package:get/get.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/presentation/subject_stats/subject_stats_controller.dart";

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
