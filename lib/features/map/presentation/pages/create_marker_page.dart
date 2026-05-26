import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/util/id_generator.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../domain/entities/marker_submission_entity.dart';
import '../stores/map_store.dart';
import 'location_picker_page.dart';

class CreateMarkerPage extends StatefulWidget {
  final double initialLat;
  final double initialLon;

  const CreateMarkerPage({
    super.key,
    required this.initialLat,
    required this.initialLon,
  });

  @override
  State<CreateMarkerPage> createState() => _CreateMarkerPageState();
}

class _CreateMarkerPageState extends State<CreateMarkerPage> {
  final _formKey = GlobalKey<FormState>();
  final MapStore _store = getIt<MapStore>();

  // ─── Marker ────────────────────────────────────────────────────────────────
  late final TextEditingController _markerTitle;
  late LatLng _point;
  late final TextEditingController _markerCompressed;

  // ─── Building ──────────────────────────────────────────────────────────────
  late final TextEditingController _buildingTitle;
  late final TextEditingController _buildingCompressed;
  late final TextEditingController _descTop;
  late final TextEditingController _descMain;
  late final TextEditingController _descBottom;
  late final TextEditingController _person;
  late final TextEditingController _dateStart;
  late final TextEditingController _dateEnd;
  late final TextEditingController _image;
  final List<TextEditingController> _resources = [TextEditingController()];

  // ─── Type (shared marker.type / building.type) ─────────────────────────────
  static const _types = ['history', 'culture', 'architecture', 'art', 'person'];
  String _type = 'history';

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _markerTitle = TextEditingController();
    _point = LatLng(widget.initialLat, widget.initialLon);
    _markerCompressed = TextEditingController();
    _buildingTitle = TextEditingController();
    _buildingCompressed = TextEditingController();
    _descTop = TextEditingController();
    _descMain = TextEditingController();
    _descBottom = TextEditingController();
    _person = TextEditingController();
    _dateStart = TextEditingController();
    _dateEnd = TextEditingController();
    _image = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      _markerTitle,
      _markerCompressed,
      _buildingTitle,
      _buildingCompressed,
      _descTop,
      _descMain,
      _descBottom,
      _person,
      _dateStart,
      _dateEnd,
      _image,
      ..._resources,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _genMarkerId() => IdGenerator.generate(
        prefix: 'm',
        parts: [
          _markerTitle.text.trim(),
          _markerCompressed.text.trim(),
          _point.latitude.toStringAsFixed(6),
          _point.longitude.toStringAsFixed(6),
          _type,
        ],
      );

  String _genBuildingId() => IdGenerator.generate(
        prefix: 'b',
        parts: [
          _buildingTitle.text.trim(),
          _buildingCompressed.text.trim(),
          _descMain.text.trim(),
          _person.text.trim(),
          _dateStart.text.trim(),
          _dateEnd.text.trim(),
        ],
      );

  Future<void> _pickDate(TextEditingController target) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(target.text) ?? DateTime(now.year - 50);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(800),
      lastDate: DateTime(now.year + 5),
      helpText: AppLocalizations.of(context)!.selectDate,
    );
    if (picked != null) {
      target.text = _dateFmt.format(picked);
    }
  }

  void _addResourceField() {
    setState(() => _resources.add(TextEditingController()));
  }

  void _removeResourceField(int index) {
    if (_resources.length <= 1) return;
    setState(() {
      _resources[index].dispose();
      _resources.removeAt(index);
    });
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    return null;
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initial: _point),
      ),
    );
    if (result != null) {
      setState(() => _point = result);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final resources = _resources
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (resources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.atLeastOneResource)),
      );
      return;
    }

    final payload = MarkerSubmissionEntity(
      marker: MarkerPayload(
        id: _genMarkerId(),
        lat: _point.latitude,
        lon: _point.longitude,
        title: _markerTitle.text.trim(),
        type: _type,
        compressedDescription: _markerCompressed.text.trim(),
      ),
      building: BuildingPayload(
        id: _genBuildingId(),
        title: _buildingTitle.text.trim(),
        compressedDescription: _buildingCompressed.text.trim(),
        descriptionTop: _descTop.text.trim(),
        descriptionMain: _descMain.text.trim(),
        descriptionBottom: _descBottom.text.trim(),
        image: _image.text.trim(),
        dateStart: _dateStart.text.trim(),
        dateEnd: _dateEnd.text.trim(),
        type: _type,
        person: _person.text.trim(),
        resources: resources,
      ),
    );

    final ok = await _store.submitMarker(payload);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.markerPublished)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_store.submitError ?? l10n.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createMarkerTitle)),
      body: Observer(
        builder: (_) {
          return AbsorbPointer(
            absorbing: _store.isSubmitting,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _sectionHeader(context, l10n.markerSection),
                  const SizedBox(height: 8),
                  GothicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          label: l10n.titleField,
                          controller: _markerTitle,
                          validator: _required,
                        ),
                        const SizedBox(height: 6),
                        _locationPicker(),
                        _typeDropdown(),
                        _field(
                          label: l10n.markerCompressedField,
                          controller: _markerCompressed,
                          validator: _required,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(context, l10n.buildingSection),
                  const SizedBox(height: 8),
                  GothicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          label: l10n.buildingNameField,
                          controller: _buildingTitle,
                          validator: _required,
                        ),
                        _field(
                          label: l10n.buildingCompressedField,
                          controller: _buildingCompressed,
                          validator: _required,
                          maxLines: 2,
                        ),
                        _field(
                          label: l10n.descTopField,
                          controller: _descTop,
                          validator: _required,
                          maxLines: 2,
                        ),
                        _field(
                          label: l10n.descMainField,
                          controller: _descMain,
                          validator: _required,
                          maxLines: 4,
                        ),
                        _field(
                          label: l10n.descBottomField,
                          controller: _descBottom,
                          validator: _required,
                          maxLines: 2,
                        ),
                        _field(
                          label: l10n.personField,
                          controller: _person,
                          validator: _required,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _dateField(
                                label: l10n.dateStartField,
                                controller: _dateStart,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _dateField(
                                label: l10n.dateEndField,
                                controller: _dateEnd,
                              ),
                            ),
                          ],
                        ),
                        _field(
                          label: l10n.imageUrlField,
                          controller: _image,
                          validator: _required,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 6),
                        _resourcesEditor(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _store.isSubmitting ? null : _submit,
                      icon: _store.isSubmitting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: context.bgClr),
                            )
                          : const Icon(Icons.send, size: 16),
                      label: Text(_store.isSubmitting
                          ? l10n.submittingLabel
                          : l10n.publishButton),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GothicDivider(),
        const SizedBox(height: 6),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: context.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _locationPicker() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: _pickLocation,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.surfaceVar,
            border: Border.all(color: context.outlineClr, width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, color: context.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.coordinatesLabel,
                      style: GoogleFonts.cinzel(
                        color: context.gold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_point.latitude.toStringAsFixed(6)}, ${_point.longitude.toStringAsFixed(6)}',
                      style: GoogleFonts.crimsonText(
                        color: context.onBg,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.map_outlined, color: context.gold, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        validator: _required,
        onTap: () => _pickDate(controller),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
      ),
    );
  }

  Widget _typeDropdown() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        initialValue: _type,
        decoration: InputDecoration(labelText: l10n.typeField),
        items: _types
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (v) {
          if (v != null) setState(() => _type = v);
        },
      ),
    );
  }

  Widget _resourcesEditor() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            l10n.resourcesLabel,
            style: GoogleFonts.cinzel(
              color: context.gold,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ),
        for (int i = 0; i < _resources.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _resources[i],
                    decoration: InputDecoration(
                      labelText: l10n.resourceItem(i + 1),
                      hintText: 'wikipedia.org',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: _resources.length > 1
                          ? context.errorClr
                          : context.outlineClr),
                  onPressed: _resources.length > 1
                      ? () => _removeResourceField(i)
                      : null,
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addResourceField,
            icon: const Icon(Icons.add, size: 16),
            label: Text(l10n.addResource),
          ),
        ),
      ],
    );
  }
}
