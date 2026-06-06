import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/road_damage.dart';
import '../../../core/theme.dart';

class SeverityBadge extends StatelessWidget {
  final DamageSeverity severity;
  final bool large;

  const SeverityBadge({super.key, required this.severity, this.large = false});

  Color get _color {
    switch (severity) {
      case DamageSeverity.critical: return AppTheme.severityCritical;
      case DamageSeverity.high:     return AppTheme.severityHigh;
      case DamageSeverity.medium:   return AppTheme.severityMedium;
      case DamageSeverity.low:      return AppTheme.severityLow;
    }
  }

  String get _label => severity.name.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical:   large ? 6  : 3,
      ),
      decoration: BoxDecoration(
        color:        _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border:       Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(_label,
        style: GoogleFonts.spaceGrotesk(
          color:       _color,
          fontSize:    large ? 10 : 8,
          fontWeight:  FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final DamageStatus status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case DamageStatus.reported:     return Colors.white38;
      case DamageStatus.acknowledged: return AppTheme.accentBlue;
      case DamageStatus.inProgress:   return AppTheme.severityMedium;
      case DamageStatus.resolved:     return AppTheme.severityLow;
    }
  }

  String get _label {
    switch (status) {
      case DamageStatus.reported:     return 'REPORTED';
      case DamageStatus.acknowledged: return 'ACKNOWLEDGED';
      case DamageStatus.inProgress:   return 'IN PROGRESS';
      case DamageStatus.resolved:     return 'RESOLVED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border:       Border.all(color: _color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(_label,
        style: GoogleFonts.spaceGrotesk(
          color: _color, fontSize: 8,
          fontWeight: FontWeight.w700, letterSpacing: 1.5,
        ),
      ),
    );
  }
}