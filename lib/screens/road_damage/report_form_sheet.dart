import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/road_damage_provider.dart';
import '../../models/road_damage.dart';
import '../../core/theme.dart';
import 'widgets/severity_badge.dart';

class ReportFormSheet extends StatefulWidget {
  const ReportFormSheet({super.key});

  @override
  State<ReportFormSheet> createState() => _ReportFormSheetState();
}

class _ReportFormSheetState extends State<ReportFormSheet> {
  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _latCtrl         = TextEditingController();
  final _lngCtrl         = TextEditingController();

  DamageType     _selectedType     = DamageType.pothole;
  DamageSeverity _selectedSeverity = DamageSeverity.medium;

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _locationCtrl.text.trim().isNotEmpty &&
          _descriptionCtrl.text.trim().isNotEmpty &&
          _latCtrl.text.trim().isNotEmpty &&
          _lngCtrl.text.trim().isNotEmpty;

  Future<void> _submit(RoadDamageProvider provider) async {
    if (!_canSubmit) return;

    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.accentRed.withOpacity(0.9),
          content: Text('Invalid coordinates',
            style: GoogleFonts.spaceGrotesk(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final report = RoadDamageReport(
      id:          '',
      location:    _locationCtrl.text.trim(),
      latitude:    lat,
      longitude:   lng,
      type:        _selectedType,
      severity:    _selectedSeverity,
      status:      DamageStatus.reported,
      description: _descriptionCtrl.text.trim(),
      reportedBy:  'citizen',
      reportedAt:  DateTime.now().toIso8601String(),
    );

    final ok = await provider.submitReport(report);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoadDamageProvider>(
      builder: (_, provider, __) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
          padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color:        Color(0xFF0d0d0d),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border:       Border(top: BorderSide(color: Colors.white12)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:       MainAxisSize.min,
                  children: [
                    // ── Handle + title ────────────────────────
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color:        Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('REPORT DAMAGE',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white, fontSize: 18,
                                fontWeight: FontWeight.w900, letterSpacing: 3,
                              ),
                            ),
                            Text('SUBMIT A NEW ROAD ISSUE',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white38, fontSize: 9, letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white38, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Location ──────────────────────────────
                    _FieldLabel('LOCATION'),
                    const SizedBox(height: 6),
                    _TextField(
                      controller: _locationCtrl,
                      hint:       'e.g. MG Road, Sector 4',
                      onChanged:  (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),

                    // ── Coordinates ───────────────────────────
                    _FieldLabel('COORDINATES'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _TextField(
                            controller:  _latCtrl,
                            hint:        'Latitude',
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                            onChanged:   (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TextField(
                            controller:  _lngCtrl,
                            hint:        'Longitude',
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                            onChanged:   (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Type selector ─────────────────────────
                    _FieldLabel('DAMAGE TYPE'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: DamageType.values.map((t) {
                          final sel = t == _selectedType;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin:   const EdgeInsets.only(right: 8),
                              padding:  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color:        sel ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border:       Border.all(color: sel ? Colors.white : Colors.white24),
                              ),
                              child: Center(
                                child: Text(t.name.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    color:      sel ? Colors.black : Colors.white54,
                                    fontSize:   10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Severity selector ─────────────────────
                    _FieldLabel('SEVERITY'),
                    const SizedBox(height: 8),
                    Row(
                      children: DamageSeverity.values.map((s) {
                        final sel = s == _selectedSeverity;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSeverity = s),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity:  sel ? 1.0 : 0.4,
                              child: SeverityBadge(severity: s, large: true),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // ── Description ───────────────────────────
                    _FieldLabel('DESCRIPTION'),
                    const SizedBox(height: 6),
                    _TextField(
                      controller: _descriptionCtrl,
                      hint:       'Describe the damage in detail...',
                      maxLines:   3,
                      onChanged:  (_) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    // ── Submit button ─────────────────────────
                    GestureDetector(
                      onTap: _canSubmit && !provider.isLoading
                          ? () => _submit(provider)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width:    double.infinity,
                        height:   52,
                        decoration: BoxDecoration(
                          color:        _canSubmit ? AppTheme.accent : Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: provider.isLoading
                            ? const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2,
                            ),
                          ),
                        )
                            : Center(
                          child: Text(
                            _canSubmit
                                ? 'SUBMIT REPORT →'
                                : 'FILL ALL FIELDS TO CONTINUE',
                            style: GoogleFonts.spaceGrotesk(
                              color:      _canSubmit ? Colors.black : Colors.white24,
                              fontSize:   11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Error inline ──────────────────────────
                    if (provider.state == LoadState.error && provider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          provider.error!,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.accentRed, fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Local helpers ─────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: GoogleFonts.spaceGrotesk(
        color: Colors.white38, fontSize: 9,
        fontWeight: FontWeight.w700, letterSpacing: 3,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String                hint;
  final int                   maxLines;
  final TextInputType?        keyboardType;
  final ValueChanged<String>  onChanged;

  const _TextField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines    = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      onChanged:    onChanged,
      maxLines:     maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText:       hint,
        hintStyle:      GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 13),
        filled:         true,
        fillColor:      Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: Colors.white38),
        ),
      ),
    );
  }
}