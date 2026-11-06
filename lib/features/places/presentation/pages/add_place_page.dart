import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../activity/presentation/stores/tracking_store.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_source.dart';
import '../stores/places_store.dart';
import '../widgets/map_widgets.dart';
import '../widgets/place_labels.dart';

/// Creates a personal place stored on this device only.
class AddPlacePage extends StatefulWidget {
  const AddPlacePage({super.key, required this.initial});
  final LatLng initial;

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _year = TextEditingController();
  final _image = TextEditingController();
  final _map = MapController();
  late LatLng _point = widget.initial;
  PlaceCategory _category = PlaceCategory.building;
  bool _saving = false;

  static const _categories = [
    PlaceCategory.building,
    PlaceCategory.monument,
    PlaceCategory.memorial,
    PlaceCategory.religious,
    PlaceCategory.museum,
    PlaceCategory.fortification,
    PlaceCategory.archaeology,
    PlaceCategory.other,
  ];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _year.dispose();
    _image.dispose();
    _map.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    final fix = await getIt<TrackingStore>().locateOnce();
    if (fix == null || !mounted) return;
    setState(() => _point = LatLng(fix.lat, fix.lon));
    _map.move(_point, 17);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final desc = _description.text.trim();
    final place = Place(
      source: PlaceSource.user,
      sourceId: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      title: _title.text.trim(),
      lat: _point.latitude,
      lon: _point.longitude,
      summary: desc.length > 160 ? '${desc.substring(0, 160)}…' : desc,
      description: desc,
      imageUrl: _image.text.trim().isEmpty ? null : _image.text.trim(),
      category: _category,
      yearStart: int.tryParse(_year.text.trim()),
    );
    await getIt<PlacesStore>().addUserPlace(place);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.placeSaved)));
    Navigator.of(context).pop(place);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.addPlaceTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: l.titleField),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlaceCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l.categoryLabel),
              items: [
                for (final c in _categories)
                  DropdownMenuItem(
                      value: c,
                      child: Row(children: [Icon(c.icon, size: 18), const SizedBox(width: 8), Text(c.label(l))])),
              ],
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(labelText: l.descriptionField, alignLabelWithHint: true),
              minLines: 3,
              maxLines: 8,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _year,
                  decoration: InputDecoration(labelText: l.yearField),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final y = int.tryParse(v.trim());
                    return (y == null || y < -3000 || y > DateTime.now().year) ? l.invalidYear : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _image,
                  decoration: InputDecoration(labelText: l.imageUrlField),
                  keyboardType: TextInputType.url,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Text(
                  '${l.coordinatesLabel}: ${_point.latitude.toStringAsFixed(5)}, ${_point.longitude.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton.icon(
                  onPressed: _useMyLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(l.useMyLocation)),
            ]),
            Text(l.tapMapHint, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 240,
                child: FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _point,
                    initialZoom: 16,
                    onTap: (_, p) => setState(() => _point = p),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'io.github.undemorbe.qstory',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: _point,
                        width: PlacePin.width,
                        height: PlacePin.height,
                        alignment: Alignment.topCenter,
                        child: PlacePin(
                          place: Place(
                              source: PlaceSource.user, sourceId: '_', title: '', lat: 0, lon: 0, category: _category),
                          visited: false,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
