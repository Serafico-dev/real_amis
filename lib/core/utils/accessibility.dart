import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Moltiplica un'altezza base per l'ingrandimento del testo scelto dall'utente
/// (limitato tra 1x e 2x), così i contenitori a altezza fissa che ospitano
/// testo (per esempio le righe di chip) non tagliano le scritte.
double scaledByText(BuildContext context, double base) {
  final factor = MediaQuery.textScalerOf(context).scale(14) / 14;
  return base * math.min(math.max(factor, 1.0), 2.0);
}
