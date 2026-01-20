import 'package:flutter/material.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/presentation/match/widgets/event_row.dart';

class EventColumn extends StatelessWidget {
  final String title;
  final List<EventEntity> events;
  final bool alignRight;
  final void Function(EventEntity) onEdit;

  const EventColumn({
    super.key,
    required this.title,
    required this.events,
    required this.alignRight,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...events.map(
          (ev) => EventRow(event: ev, alignRight: alignRight, onEdit: onEdit),
        ),
      ],
    );
  }
}
