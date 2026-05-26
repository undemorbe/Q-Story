import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
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

  String _genId() {
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = Random().nextInt(0x7fffffff).toRadixString(36);
    return '$ts$rand';
  }

  Future<void> _pickDate(TextEditingController target) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(target.text) ?? DateTime(now.year - 50);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(800),
      lastDate: DateTime(now.year + 5),
      helpText: 'Выберите дату',
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
    if (v == null || v.trim().isEmpty) return 'Обязательное поле';
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
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final resources = _resources
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (resources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы один источник')),
      );
      return;
    }

    final payload = MarkerSubmissionEntity(
      marker: MarkerPayload(
        id: _genId(),
        lat: _point.latitude,
        lon: _point.longitude,
        title: _markerTitle.text.trim(),
        type: _type,
        compressedDescription: _markerCompressed.text.trim(),
      ),
      building: BuildingPayload(
        id: _genId(),
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
        const SnackBar(content: Text('Метка опубликована')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_store.submitError ?? 'Ошибка отправки')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать метку')),
      body: Observer(
        builder: (_) {
          return AbsorbPointer(
            absorbing: _store.isSubmitting,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _sectionHeader(context, 'Метка на карте'),
                  const SizedBox(height: 8),
                  GothicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          label: 'Название',
                          controller: _markerTitle,
                          validator: _required,
                        ),
                        const SizedBox(height: 6),
                        _locationPicker(),
                        _typeDropdown(),
                        _field(
                          label: 'Сжатое описание (для маркера)',
                          controller: _markerCompressed,
                          validator: _required,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(context, 'Объект (QR)'),
                  const SizedBox(height: 8),
                  GothicCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          label: 'Название объекта',
                          controller: _buildingTitle,
                          validator: _required,
                        ),
                        _field(
                          label: 'Сжатое описание',
                          controller: _buildingCompressed,
                          validator: _required,
                          maxLines: 2,
                        ),
                        _field(
                          label: 'Верхнее описание',
                          controller: _descTop,
                          validator: _required,
                          maxLines: 2,
                        ),
                        _field(
                          label: 'Главное описание',
                          controller: _descMain,
                          validator: _required,
                          maxLines: 4,
                        ),
                        _field(
                          label: 'Нижнее описание',
                          controller: _descBottom,
                          validator: _required,
                          maxLines: 2,
                        ),
                        _field(
                          label: 'Связанная личность',
                          controller: _person,
                          validator: _required,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _dateField(
                                label: 'Дата начала',
                                controller: _dateStart,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _dateField(
                                label: 'Дата конца',
                                controller: _dateEnd,
                              ),
                            ),
                          ],
                        ),
                        _field(
                          label: 'URL изображения',
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
                      label: Text(
                          _store.isSubmitting ? 'Отправка…' : 'Опубликовать'),
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
                      'Координаты',
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        initialValue: _type,
        decoration: const InputDecoration(labelText: 'Тип'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            'ИСТОЧНИКИ',
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
                      labelText: 'Источник ${i + 1}',
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
            label: const Text('Добавить источник'),
          ),
        ),
      ],
    );
  }
}
