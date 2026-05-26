import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';

/// Tap on the map to choose a point. Returns the selected `LatLng` via
/// `Navigator.pop`, or `null` if cancelled.
class LocationPickerPage extends StatefulWidget {
  final LatLng initial;

  const LocationPickerPage({super.key, required this.initial});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng _selected;
  final MapController _controller = MapController();

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  void _onTap(TapPosition _, LatLng point) {
    setState(() => _selected = point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите точку'),
        actions: [
          IconButton(
            tooltip: 'Подтвердить',
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.initial,
              initialZoom: 13.0,
              onTap: _onTap,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.qstory',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selected,
                    width: 52,
                    height: 62,
                    alignment: Alignment.bottomCenter,
                    child: const _PickerPin(),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _CoordsBar(point: _selected),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: GothicCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Text(
                'Нажмите на карту, чтобы выбрать координаты',
                style: GoogleFonts.crimsonText(
                  color: context.onBg,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.gold,
        foregroundColor: context.bgClr,
        onPressed: () => Navigator.of(context).pop(_selected),
        icon: const Icon(Icons.check),
        label: const Text('Готово'),
      ),
    );
  }
}

class _CoordsBar extends StatelessWidget {
  final LatLng point;
  const _CoordsBar({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceClr,
        border: Border.all(color: context.outlineClr),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: context.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
              style: GoogleFonts.cinzel(
                color: context.onBg,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Static gold pin without context dependency — matches the map markers' style.
class _PickerPin extends StatelessWidget {
  const _PickerPin();

  @override
  Widget build(BuildContext context) {
    final color = context.gold;
    final bgColor = context.goldContainer;
    return SizedBox(
      width: 52,
      height: 62,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Text('✦',
                  style: TextStyle(color: color, fontSize: 22, height: 1)),
            ),
          ),
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: const Size(14, 18),
              painter: _PinSpike(color: color, bgColor: bgColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinSpike extends CustomPainter {
  final Color color;
  final Color bgColor;
  const _PinSpike({required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.miter;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_PinSpike old) =>
      old.color != color || old.bgColor != bgColor;
}
