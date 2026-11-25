// lib/screens/add_place_screen.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../config.dart';
import '../data/places.dart';
import '../models/picked_location.dart';
import '../models/place.dart';
import '../utils/geo.dart';
import 'map_picker_screen.dart';

/// Шинэ газрын форм: нэр, бүс нутаг/байршил, зай, тайлбар, улирал, зураг.
class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _region = TextEditingController();
  final _description = TextEditingController();
  final _distance = TextEditingController();
  final _picker = ImagePicker();

  String _season = 'Зун';
  PickedLocation? _location;
  Uint8List? _imageBytes;
  bool _distanceAuto = false;
  bool _pickingImage = false;

  @override
  void dispose() {
    _name.dispose();
    _region.dispose();
    _description.dispose();
    _distance.dispose();
    super.dispose();
  }

  String? _required(String? v, String field, {int min = 2}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$field оруулна уу';
    if (t.length < min) return 'Хамгийн багадаа $min тэмдэгт';
    return null;
  }

  String? _validateDistance(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n <= 0) return 'Эерэг бүхэл тоо оруулна уу';
    if (n > 5000) return 'Монгол дотор 5000 км-ээс бага байна';
    return null;
  }

  Future<void> _pickOnMap() async {
    final picked = await context.push<PickedLocation>(
      '/map',
      extra: MapPickerArgs(initial: _location),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _location = picked;
      final region = picked.region ?? picked.address;
      if (region != null && region.isNotEmpty) _region.text = region;
      if (_name.text.trim().isEmpty && picked.name != null) {
        _name.text = picked.name!;
      }
      if (_distance.text.trim().isEmpty || _distanceAuto) {
        _distance.text =
            '${distanceFromUbKm(picked.latitude, picked.longitude)}';
        _distanceAuto = true;
      }
    });
  }

  void _clearLocation() => setState(() {
        _location = null;
        if (_distanceAuto) _distance.clear();
        _distanceAuto = false;
      });

  Future<void> _pickImage(ImageSource source) async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        imageQuality: 65,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Зураг сонгоход алдаа гарлаа: $e')),
      );
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final place = Place(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      region: _region.text.trim(),
      image: 'assets/images/placeholder.jpg',
      imageBytes: _imageBytes,
      description: _description.text.trim(),
      rating: 0,
      distanceKm: int.tryParse(_distance.text.trim()) ?? 0,
      bestSeason: _season,
      latitude: _location?.latitude,
      longitude: _location?.longitude,
    );
    context.pop(place);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Газар нэмэх'),
        actions: [TextButton(onPressed: _save, child: const Text('Хадгалах'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            _ImagePickerField(
              bytes: _imageBytes,
              busy: _pickingImage,
              onGallery: () => _pickImage(ImageSource.gallery),
              onCamera:
                  cameraSupported ? () => _pickImage(ImageSource.camera) : null,
              onRemove: () => setState(() => _imageBytes = null),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Нэр',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: (v) => _required(v, 'Нэр'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _region,
              decoration: InputDecoration(
                labelText: 'Бүс нутаг / байршил',
                hintText: 'Жишээ нь: Архангай аймаг',
                prefixIcon: const Icon(Icons.map_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.travel_explore),
                  tooltip: 'Газрын зургаас сонгох',
                  onPressed: _pickOnMap,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: (v) => _required(v, 'Бүс нутаг'),
            ),
            const SizedBox(height: 8),
            _LocationSummary(
              location: _location,
              onPick: _pickOnMap,
              onClear: _clearLocation,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _distance,
              decoration: InputDecoration(
                labelText: 'Улаанбаатараас зай (заавал биш)',
                suffixText: 'км',
                prefixIcon: const Icon(Icons.route),
                helperText: _distanceAuto
                    ? 'Газрын зургаас шулуун зайг тооцоолсон — засаж болно'
                    : null,
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_distanceAuto) setState(() => _distanceAuto = false);
              },
              validator: _validateDistance,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Тайлбар',
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => _required(v, 'Тайлбар', min: 10),
            ),
            const SizedBox(height: 12),
            Text('Тохиромжтой улирал', style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in seasons)
                  ChoiceChip(
                    label: Text(s),
                    selected: s == _season,
                    onSelected: (_) => setState(() => _season = s),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Хадгалах'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.bytes,
    required this.busy,
    required this.onGallery,
    required this.onCamera,
    required this.onRemove,
  });

  final Uint8List? bytes;
  final bool busy;
  final VoidCallback onGallery;
  final VoidCallback? onCamera;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final image = bytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Зураг', style: text.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image == null
                ? Material(
                    color: scheme.surfaceContainerHighest,
                    child: InkWell(
                      onTap: busy ? null : onGallery,
                      child: Center(
                        child: busy
                            ? const CircularProgressIndicator(
                                semanticsLabel: 'Зураг ачаалж байна',
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 36,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Зураг оруулах (заавал биш)',
                                      style: text.bodyMedium),
                                ],
                              ),
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        image,
                        fit: BoxFit.cover,
                        semanticLabel: 'Сонгосон зураг',
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filledTonal(
                          icon: const Icon(Icons.close),
                          tooltip: 'Зураг хасах',
                          onPressed: onRemove,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: busy ? null : onGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(image == null ? 'Галерейгаас' : 'Зураг солих'),
            ),
            if (onCamera != null)
              OutlinedButton.icon(
                onPressed: busy ? null : onCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Камераар'),
              ),
          ],
        ),
      ],
    );
  }
}

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({
    required this.location,
    required this.onPick,
    required this.onClear,
  });

  final PickedLocation? location;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final loc = location;
    if (loc == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Газрын зураг дээр байршил тэмдэглэх'),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          Icons.push_pin,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(loc.address ?? loc.name ?? 'Тэмдэглэсэн цэг'),
        subtitle: Text(loc.coordinates),
        onTap: onPick,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Байршил арилгах',
          onPressed: onClear,
        ),
      ),
    );
  }
}
