import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
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

    Color color = context.isDarkMode
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;

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
        style: TextStyle(
          color: color,
          fontStyle: event.isOwnGoal ? FontStyle.italic : null,
        ),
      ),
    );

    // Il tipo di evento era riconoscibile solo dall'icona/colore: ora ha anche
    // un'etichetta per gli screen reader.
    final typeLabel = switch (type) {
      EventType.goal => event.isOwnGoal ? 'Autogoal' : 'Gol',
      EventType.giallo => 'Cartellino giallo',
      EventType.rosso => 'Cartellino rosso',
    };

    // Il giallo su fondo chiaro ha solo 1,2:1 di contrasto: il cartellino ha un
    // bordo del colore del testo, così si vede su qualsiasi sfondo.
    final Widget iconWidget = type == EventType.goal
        ? Icon(icon, size: 18, color: color, semanticLabel: typeLabel)
        : Semantics(
            label: typeLabel,
            child: Container(
              width: 15,
              height: 15,
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: type == EventType.giallo ? Colors.yellow : Colors.red,
                border: Border.all(color: color, width: 1.5),
              ),
            ),
          );

    final editButton = AdminOnly(
      child: IconButton(
        icon: Icon(Icons.edit, size: 18, color: color),
        tooltip: 'Modifica evento',
        onPressed: () => onEdit(event),
        // L'icona resta piccola, ma l'area toccabile è 48x48 (prima ~18x18).
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
