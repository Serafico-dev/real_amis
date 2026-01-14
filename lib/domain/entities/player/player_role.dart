enum PlayerRole {
  ala,
  attaccante,
  centravanti,
  centrocampista,
  centrocampistaCentrale,
  difensore,
  difensoreCentrale,
  difensoreTerzino,
  mediano,
  portiere,
  trequartista,
  riserva,
  allenatore,
  dirigente,
  direttoreSportivo,
  presidente,
  vicePresidente,
  leggenda,
  nessuno,
}

extension PlayerRoleX on PlayerRole {
  String get value {
    switch (this) {
      case PlayerRole.presidente:
        return 'Presidente';
      case PlayerRole.vicePresidente:
        return 'Vicepresidente';
      case PlayerRole.dirigente:
        return 'Dirigente';
      case PlayerRole.direttoreSportivo:
        return 'Direttore sportivo';
      case PlayerRole.allenatore:
        return 'Allenatore';
      case PlayerRole.portiere:
        return 'Portiere';
      case PlayerRole.difensore:
        return 'Difensore';
      case PlayerRole.difensoreCentrale:
        return 'Difensore centrale';
      case PlayerRole.difensoreTerzino:
        return 'Difensore terzino';
      case PlayerRole.centrocampista:
        return 'Centrocampista';
      case PlayerRole.mediano:
        return 'Mediano';
      case PlayerRole.centrocampistaCentrale:
        return 'Centrocampista centrale';
      case PlayerRole.trequartista:
        return 'Trequartista';
      case PlayerRole.attaccante:
        return 'Attaccante';
      case PlayerRole.centravanti:
        return 'Centravanti';
      case PlayerRole.ala:
        return 'Ala';
      case PlayerRole.riserva:
        return 'Riserva';
      case PlayerRole.leggenda:
        return 'Leggenda';
      case PlayerRole.nessuno:
        return 'Nessun ruolo';
    }
  }

  static PlayerRole fromString(String? s) {
    if (s == null) return PlayerRole.nessuno;
    switch (s) {
      case 'Presidente':
        return PlayerRole.presidente;
      case 'Vicepresidente':
        return PlayerRole.vicePresidente;
      case 'Dirigente':
        return PlayerRole.dirigente;
      case 'Direttore sportivo':
        return PlayerRole.direttoreSportivo;
      case 'Allenatore':
        return PlayerRole.allenatore;
      case 'Portiere':
        return PlayerRole.portiere;
      case 'Difensore':
        return PlayerRole.difensore;
      case 'Difensore centrale':
        return PlayerRole.difensoreCentrale;
      case 'Difensore terzino':
        return PlayerRole.difensoreTerzino;
      case 'Centrocampista':
        return PlayerRole.centrocampista;
      case 'Mediano':
        return PlayerRole.centrocampista;
      case 'Centrocampista centrale':
        return PlayerRole.centrocampista;
      case 'Trequartista':
        return PlayerRole.centrocampista;
      case 'Attaccante':
        return PlayerRole.attaccante;
      case 'Centravanti':
        return PlayerRole.centravanti;
      case 'Ala':
        return PlayerRole.ala;
      case 'Riserva':
        return PlayerRole.riserva;
      case 'Leggenda':
        return PlayerRole.leggenda;
      default:
        return PlayerRole.nessuno;
    }
  }
}
