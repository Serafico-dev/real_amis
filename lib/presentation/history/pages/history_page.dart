import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_amis/common/widgets/appBar/app_bar_no_nav.dart';
import 'package:real_amis/common/widgets/confirmDialog/styled_confirm_dialog.dart';
import 'package:real_amis/core/configs/assets/app_vectors.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/domain/entities/history/club_section_entity.dart';
import 'package:real_amis/domain/entities/history/club_timeline_entity.dart';
import 'package:real_amis/presentation/history/providers/club_history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const HistoryPage());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? AppColors.bgDark : AppColors.bgLight;
    final sectionsAsync = ref.watch(clubSectionsProvider);
    final timelineAsync = ref.watch(clubTimelineProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const AppBarNoNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            sectionsAsync.when(
              data: (sections) {
                final fixedSections = sections.where((s) => s.isFixed).toList();
                final dynamicSections = sections
                    .where((s) => !s.isFixed)
                    .toList();

                return Column(
                  children: [
                    ...fixedSections.map(
                      (s) => _HistorySection(
                        key: ValueKey(s.id),
                        section: s,
                        imageAsset: s.sectionKey == 'logo'
                            ? AppVectors.logo
                            : null,
                        onEdit: (updated) async {
                          await ref
                              .read(clubHistoryRepositoryProvider)
                              .updateSection(updated);
                          ref.invalidate(clubSectionsProvider);
                        },
                      ),
                    ),

                    _ReorderableSections(
                      sections: dynamicSections,
                      onEdit: (updated) async {
                        await ref
                            .read(clubHistoryRepositoryProvider)
                            .updateSection(updated);
                        ref.invalidate(clubSectionsProvider);
                      },
                      onDelete: (id) async {
                        await ref
                            .read(clubHistoryRepositoryProvider)
                            .deleteSection(id);
                        ref.invalidate(clubSectionsProvider);
                      },
                      onReorder: (reordered) async {
                        await ref
                            .read(clubHistoryRepositoryProvider)
                            .reorderSections(reordered);
                        ref.invalidate(clubSectionsProvider);
                      },
                    ),

                    AdminOnly(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Aggiungi sezione'),
                          onPressed: () => _showAddSectionDialog(
                            context,
                            ref,
                            dynamicSections.length,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Errore: $e'),
            ),

            const SizedBox(height: 20),
            Text(
              'Timeline delle stagioni',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 12),
            timelineAsync.when(
              data: (items) => Column(
                children: [
                  _TimelineWidget(items: items),
                  AdminOnly(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Aggiungi stagione'),
                        onPressed: () => _showTimelineEditDialog(
                          context,
                          ref,
                          null,
                          items.length,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Errore: $e'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddSectionDialog(
    BuildContext context,
    WidgetRef ref,
    int nextOrder,
  ) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuova sezione'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Titolo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Testo'),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await ref
                  .read(clubHistoryRepositoryProvider)
                  .addSection(
                    titleCtrl.text.trim(),
                    contentCtrl.text.trim(),
                    nextOrder,
                  );
              ref.invalidate(clubSectionsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _showTimelineEditDialog(
    BuildContext context,
    WidgetRef ref,
    ClubTimelineEntity? existing,
    int nextOrder,
  ) {
    final yearCtrl = TextEditingController(text: existing?.year ?? '');
    final eventCtrl = TextEditingController(
      text: existing?.eventDescription ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Nuova stagione' : 'Modifica stagione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: yearCtrl,
              decoration: const InputDecoration(labelText: 'Anno'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: eventCtrl,
              decoration: const InputDecoration(labelText: 'Evento'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              final item = ClubTimelineEntity(
                id: existing?.id ?? '',
                year: yearCtrl.text.trim(),
                eventDescription: eventCtrl.text.trim(),
                sortOrder: existing?.sortOrder ?? nextOrder,
              );
              await ref
                  .read(clubHistoryRepositoryProvider)
                  .upsertTimelineItem(item);
              ref.invalidate(clubTimelineProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}

class _ReorderableSections extends ConsumerWidget {
  final List<ClubSectionEntity> sections;
  final Future<void> Function(ClubSectionEntity) onEdit;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function(List<ClubSectionEntity>) onReorder;

  const _ReorderableSections({
    required this.sections,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sections.isEmpty) return const SizedBox.shrink();

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final s = sections[index];
        return _HistorySection(
          key: ValueKey(s.id),
          section: s,
          dragIndex: index,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final reordered = List<ClubSectionEntity>.from(sections);
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);
        onReorder(reordered);
      },
      proxyDecorator: (child, index, animation) => Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _HistorySection extends ConsumerWidget {
  final ClubSectionEntity section;
  final String? imageAsset;
  final Future<void> Function(ClubSectionEntity) onEdit;
  final Future<void> Function(String id)? onDelete;
  final int? dragIndex;

  const _HistorySection({
    super.key,
    required this.section,
    required this.onEdit,
    this.onDelete,
    this.imageAsset,
    this.dragIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppColors.cardDark : AppColors.cardLight;
    final titleColor = isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final textColor = isDarkMode
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                if (dragIndex != null)
                  AdminOnly(
                    child: ReorderableDragStartListener(
                      index: dragIndex!,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.drag_handle,
                          size: 20,
                          color: isDarkMode
                              ? AppColors.textDarkSecondary
                              : AppColors.textLightSecondary,
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                AdminOnly(
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _showEditDialog(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              section.content,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (imageAsset != null) ...[
              const SizedBox(height: 16),
              Image.asset(imageAsset!, height: 200),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController(text: section.title);
    final contentCtrl = TextEditingController(text: section.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifica sezione'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Titolo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Testo'),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              if (onDelete != null)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => const StyledConfirmDialog(
                        title: 'Elimina sezione',
                        message:
                            'Sei sicuro di voler eliminare questa sezione?',
                        confirmLabel: 'Elimina',
                      ),
                    );
                    if (confirm == true) await onDelete!(section.id);
                  },
                  child: const Text('Elimina'),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  await onEdit(
                    ClubSectionEntity(
                      id: section.id,
                      sectionKey: section.sectionKey,
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      sortOrder: section.sortOrder,
                      isFixed: section.isFixed,
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Salva'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineWidget extends ConsumerWidget {
  final List<ClubTimelineEntity> items;

  const _TimelineWidget({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDarkMode
        ? AppColors.textDarkSecondary.withValues(alpha: 0.5)
        : AppColors.textLightSecondary.withValues(alpha: 0.5);
    final indicatorColor = isDarkMode ? AppColors.logoGold : AppColors.logoRed;

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLeft = index % 2 == 0;

        return Stack(
          children: [
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 2,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: lineColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: isLeft
                        ? _buildCard(
                            context,
                            ref,
                            item,
                            indicatorColor,
                            isDarkMode,
                          )
                        : const SizedBox(),
                  ),
                  Expanded(
                    child: isLeft
                        ? const SizedBox()
                        : _buildCard(
                            context,
                            ref,
                            item,
                            indicatorColor,
                            isDarkMode,
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 8,
              top: 32,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    ClubTimelineEntity item,
    Color indicatorColor,
    bool isDarkMode,
  ) {
    final cardColor = isDarkMode ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDarkMode
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.year,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: indicatorColor,
                    ),
                  ),
                ),
                AdminOnly(
                  child: InkWell(
                    onTap: () => _showEditTimelineDialog(context, ref, item),
                    child: const Icon(Icons.edit, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.eventDescription,
              style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTimelineDialog(
    BuildContext context,
    WidgetRef ref,
    ClubTimelineEntity item,
  ) {
    final yearCtrl = TextEditingController(text: item.year);
    final eventCtrl = TextEditingController(text: item.eventDescription);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifica stagione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: yearCtrl,
              decoration: const InputDecoration(labelText: 'Anno'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: eventCtrl,
              decoration: const InputDecoration(labelText: 'Evento'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => const StyledConfirmDialog(
                      title: 'Elimina stagione',
                      message: 'Sei sicuro di voler eliminare questa stagione?',
                      confirmLabel: 'Elimina',
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(clubHistoryRepositoryProvider)
                        .deleteTimelineItem(item.id);
                    ref.invalidate(clubTimelineProvider);
                  }
                },
                child: const Text('Elimina'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(clubHistoryRepositoryProvider)
                      .upsertTimelineItem(
                        ClubTimelineEntity(
                          id: item.id,
                          year: yearCtrl.text.trim(),
                          eventDescription: eventCtrl.text.trim(),
                          sortOrder: item.sortOrder,
                        ),
                      );
                  ref.invalidate(clubTimelineProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Salva'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
