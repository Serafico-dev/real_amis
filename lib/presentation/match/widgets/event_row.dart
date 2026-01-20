import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/core/utils/admin_only.dart';
import 'package:real_amis/domain/entities/event/event_entity.dart';
import 'package:real_amis/domain/entities/event/event_type.dart';

class EventRow extends StatelessWidget {
  final EventEntity event;
  final bool alignRight;
  final void Function(EventEntity) onEdit;

  const EventRow({
    super.key,
    required this.event,
    required this.alignRight,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final type = event.eventType is String
        ? EventTypeX.fromString(event.eventType as String)
        : event.eventType;

    Color color;
    switch (type) {
      case EventType.rosso:
        color = Colors.red;
        break;
      case EventType.giallo:
        color = Colors.yellow;
        break;
      case EventType.goal:
        color = AppColors.tertiary;
        break;
    }

    final icon = type == EventType.goal ? Icons.sports_soccer : Icons.circle;

    final minutesText = Text(
      '${event.minutes}\'',
      style: TextStyle(fontWeight: FontWeight.bold, color: color),
    );

    final playerText = Expanded(
      child: Text(
        event.player,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color),
      ),
    );

    final iconWidget = Icon(icon, size: 18, color: color);

    final editButton = AdminOnly(
      child: IconButton(
        icon: Icon(Icons.edit, size: 18, color: color),
        onPressed: () => onEdit(event),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );

    final children = alignRight
        ? <Widget>[
            editButton,
            const SizedBox(width: 6),
            playerText,
            const SizedBox(width: 6),
            iconWidget,
            const SizedBox(width: 6),
            minutesText,
          ]
        : <Widget>[
            minutesText,
            const SizedBox(width: 6),
            iconWidget,
            const SizedBox(width: 6),
            playerText,
            const SizedBox(width: 6),
            editButton,
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: alignRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: children,
      ),
    );
  }
}
