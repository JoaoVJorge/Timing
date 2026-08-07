import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/category/category_controller.dart";
import "package:help_out/presentation/category/widgets/hobby_subject_card.dart";
import "package:help_out/presentation/category/widgets/notebook_swipe_tile.dart";
import "package:help_out/presentation/category/widgets/reading_subject_tile.dart";
import "package:help_out/presentation/category/widgets/subject_tile.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/illustrated_empty_state.dart";
import "package:help_out/theme/app_spacing.dart";

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: controller.category.localizedLabel(context),
        showBackButton: true,
      ),
      body: Obx(() {
        final List<SubjectEntity> subjects = controller.subjects;

        if (subjects.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.betweenRelated,
                bottom: AppSpacing.betweenSections,
              ),
              child: IllustratedEmptyState(
                title: _emptyTitle(context, controller.category),
                description: _emptyDescription(context, controller.category),
                actionLabel: context.l10n.addItemButton(
                  controller.category.itemNoun(context),
                ),
                onTapAction: controller.onTapAddSubject,
                suggestionsTitle: _suggestionsTitle(context),
                suggestions: _suggestionsFor(context, controller.category),
              ),
            ),
          );
        }

        if (controller.category == TimeCategoryType.hobbies) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: subjects.length + 1,
            itemBuilder: (context, index) {
              if (index == subjects.length) {
                return _AddSubjectCard(
                  category: controller.category,
                  onTap: controller.onTapAddSubject,
                );
              }

              final SubjectEntity subject = subjects[index];
              return HobbySubjectCard(
                subject: subject,
                onTapPlay: () => controller.onTapSubject(subject),
                onTapEdit: () => controller.onTapEditSubject(subject),
                onTapPin: () => controller.onPinSubjectToStart(subject),
                onDelete: () => controller.onDeleteSubject(subject),
                isPinned: index == 0,
              );
            },
          );
        }

        return ListView.separated(
          itemCount: subjects.length + 1,
          separatorBuilder: (context, index) => const Gap(12),
          itemBuilder: (context, index) {
            if (index == subjects.length) {
              return _AddSubjectTile(
                category: controller.category,
                onTap: controller.onTapAddSubject,
              );
            }

            final SubjectEntity subject = subjects[index];
            return NotebookSwipeTile(
              onTapNotes: () => controller.onTapNotes(subject),
              onTapStats: () => controller.onTapSubjectStats(subject),
              onTapEdit: () => controller.onTapEditSubject(subject),
              onDelete: () => controller.onDeleteSubject(subject),
              child: switch (controller.category) {
                TimeCategoryType.reading => ReadingSubjectTile(
                  subject: subject,
                  onTapPlay: () => controller.onTapSubject(subject),
                ),
                _ => SubjectTile(
                  subject: subject,
                  onTapPlay: () => controller.onTapSubject(subject),
                ),
              },
            );
          },
        );
      }),
    );
  }
}

String _emptyTitle(BuildContext context, TimeCategoryType category) =>
    switch (category) {
      TimeCategoryType.studying => switch (context.languageCode) {
        "pt" => "Nenhuma matéria ainda",
        "es" => "Ninguna materia todavía",
        "fr" => "Aucune matière pour l’instant",
        "de" => "Noch kein Fach",
        "ar" => "لا توجد مادة بعد",
        _ => "No subject yet",
      },
      TimeCategoryType.exercises => switch (context.languageCode) {
        "pt" => "Nenhum exercício ainda",
        "es" => "Ningún ejercicio todavía",
        "fr" => "Aucun exercice pour l’instant",
        "de" => "Noch keine Übung",
        "ar" => "لا توجد تمارين بعد",
        _ => "No exercise yet",
      },
      TimeCategoryType.reading => switch (context.languageCode) {
        "pt" => "Nenhuma leitura ainda",
        "es" => "Ninguna lectura todavía",
        "fr" => "Aucune lecture pour l’instant",
        "de" => "Noch keine Lektüre",
        "ar" => "لا توجد قراءة بعد",
        _ => "No reading yet",
      },
      TimeCategoryType.hobbies => switch (context.languageCode) {
        "pt" => "Nenhum hobby ainda",
        "es" => "Ningún hobby todavía",
        "fr" => "Aucun hobby pour l’instant",
        "de" => "Noch kein Hobby",
        "ar" => "لا توجد هواية بعد",
        _ => "No hobby yet",
      },
    };

String _emptyDescription(
  BuildContext context,
  TimeCategoryType category,
) => switch (category) {
  TimeCategoryType.studying => switch (context.languageCode) {
    "pt" =>
      "Adicione sua primeira matéria para começar a organizar seus estudos e registrar seu foco.",
    "es" =>
      "Agrega tu primera materia para organizar tus estudios y registrar tu enfoque.",
    "fr" =>
      "Ajoutez votre première matière pour organiser vos études et suivre votre concentration.",
    "de" =>
      "Füge dein erstes Fach hinzu, um dein Lernen zu organisieren und deinen Fokus zu erfassen.",
    "ar" => "أضف مادتك الأولى لتنظيم دراستك وتسجيل وقت التركيز.",
    _ => "Add your first subject to organize your studies and log focus.",
  },
  TimeCategoryType.exercises => switch (context.languageCode) {
    "pt" =>
      "Adicione seu primeiro exercício para acompanhar treinos, sessões e evolução.",
    "es" =>
      "Agrega tu primer ejercicio para seguir entrenamientos, sesiones y progreso.",
    "fr" =>
      "Ajoutez votre premier exercice pour suivre vos entraînements, séances et progrès.",
    "de" =>
      "Füge deine erste Übung hinzu, um Training, Einheiten und Fortschritt zu verfolgen.",
    "ar" => "أضف تمرينك الأول لمتابعة التمارين والجلسات والتقدم.",
    _ => "Add your first exercise to track workouts, sessions and progress.",
  },
  TimeCategoryType.reading => switch (context.languageCode) {
    "pt" =>
      "Adicione sua primeira leitura para registrar páginas, tempo e progresso.",
    "es" =>
      "Agrega tu primera lectura para registrar páginas, tiempo y progreso.",
    "fr" =>
      "Ajoutez votre première lecture pour suivre les pages, le temps et les progrès.",
    "de" =>
      "Füge deine erste Lektüre hinzu, um Seiten, Zeit und Fortschritt zu erfassen.",
    "ar" => "أضف قراءتك الأولى لتسجيل الصفحات والوقت والتقدم.",
    _ => "Add your first reading item to track pages, time and progress.",
  },
  TimeCategoryType.hobbies => switch (context.languageCode) {
    "pt" =>
      "Adicione seu primeiro hobby para registrar prática e manter constância.",
    "es" =>
      "Agrega tu primer hobby para registrar práctica y mantener constancia.",
    "fr" =>
      "Ajoutez votre premier hobby pour suivre votre pratique et garder le rythme.",
    "de" =>
      "Füge dein erstes Hobby hinzu, um Übung zu erfassen und dranzubleiben.",
    "ar" => "أضف هوايتك الأولى لتسجيل الممارسة والحفاظ على الاستمرارية.",
    _ => "Add your first hobby to log practice and keep momentum.",
  },
};

String _suggestionsTitle(BuildContext context) =>
    switch (context.languageCode) {
      "pt" => "Sugestões para começar",
      "es" => "Sugerencias para empezar",
      "fr" => "Suggestions pour commencer",
      "de" => "Vorschläge für den Anfang",
      "ar" => "اقتراحات للبدء",
      _ => "Suggestions to start",
    };

List<String> _suggestionsFor(BuildContext context, TimeCategoryType category) =>
    switch (category) {
      TimeCategoryType.studying => switch (context.languageCode) {
        "pt" => const ["Matemática", "Inglês", "Redação"],
        "es" => const ["Matemáticas", "Inglés", "Redacción"],
        "fr" => const ["Mathématiques", "Anglais", "Rédaction"],
        "de" => const ["Mathematik", "Englisch", "Schreiben"],
        "ar" => const ["رياضيات", "إنجليزية", "كتابة"],
        _ => const ["Math", "English", "Writing"],
      },
      TimeCategoryType.exercises => switch (context.languageCode) {
        "pt" => const ["Corrida", "Musculação", "Alongamento"],
        "es" => const ["Carrera", "Fuerza", "Estiramiento"],
        "fr" => const ["Course", "Renforcement", "Étirements"],
        "de" => const ["Laufen", "Kraft", "Dehnen"],
        "ar" => const ["جري", "قوة", "تمدد"],
        _ => const ["Running", "Strength", "Stretching"],
      },
      TimeCategoryType.reading => switch (context.languageCode) {
        "pt" => const ["Romance", "Técnico", "Artigos"],
        "es" => const ["Novela", "Técnico", "Artículos"],
        "fr" => const ["Roman", "Technique", "Articles"],
        "de" => const ["Roman", "Fachbuch", "Artikel"],
        "ar" => const ["رواية", "تقني", "مقالات"],
        _ => const ["Novel", "Technical", "Articles"],
      },
      TimeCategoryType.hobbies => switch (context.languageCode) {
        "pt" => const ["Violão", "Desenho", "Culinária"],
        "es" => const ["Guitarra", "Dibujo", "Cocina"],
        "fr" => const ["Guitare", "Dessin", "Cuisine"],
        "de" => const ["Gitarre", "Zeichnen", "Kochen"],
        "ar" => const ["غيتار", "رسم", "طبخ"],
        _ => const ["Guitar", "Drawing", "Cooking"],
      },
    };

class _AddSubjectTile extends StatelessWidget {
  const _AddSubjectTile({required this.category, required this.onTap});

  final TimeCategoryType category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorTokens.borderUnfocused,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon("plus", size: 16, color: context.colorTokens.primary),
          const Gap(8),
          Flexible(
            child: Text(
              context.l10n.addItemButton(category.itemNoun(context)),
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textButtonMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

class _AddSubjectCard extends StatelessWidget {
  const _AddSubjectCard({required this.category, required this.onTap});

  final TimeCategoryType category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorTokens.borderUnfocused,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon("plus", size: 18, color: context.colorTokens.primary),
            const Gap(8),
            Text(
              context.l10n.addItemButton(category.itemNoun(context)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.textButtonMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
