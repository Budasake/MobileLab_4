// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/places.dart';
import '../models/place.dart';
import '../state/ratings.dart';
import '../utils/season.dart';
import '../widgets/app_drawer.dart';
import '../widgets/place_card.dart';
import '../widgets/place_image.dart';
import 'detail_screen.dart';

/// Нүүр: нэрээр хайх, улирлаар шүүх, үнэлгээгээр эрэмбэлэх.
/// Лаб 3: LayoutBuilder — 2/3 багана, ≥ 840 dp үед master–detail.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String _season = 'Бүгд';
  bool _sortByRating = false;
  Place? _selected;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Place> _visible(Map<String, int> ratings) {
    final q = _search.text.trim().toLowerCase();
    final list = places.where((p) {
      final okName = q.isEmpty || p.name.toLowerCase().contains(q);
      final okSeason = _season == 'Бүгд' || p.bestSeason == _season;
      return okName && okSeason;
    }).toList();
    if (_sortByRating) {
      list.sort((a, b) =>
          ratingOf(b, ratings).average.compareTo(ratingOf(a, ratings).average));
    }
    return list;
  }

  Future<void> _addPlace() async {
    final place = await context.push<Place>('/add');
    if (place == null || !mounted) return;
    setState(() {
      places.add(place);
      _selected = place;
    });
  }

  void _pickSeason() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in ['Бүгд', ...seasons])
              ListTile(
                leading: s == 'Бүгд'
                    ? const Icon(Icons.all_inclusive)
                    : Icon(seasonStyle(s).icon, color: seasonStyle(s).color),
                title: Text(s),
                trailing: s == _season ? const Icon(Icons.check) : null,
                selected: s == _season,
                onTap: () {
                  setState(() => _season = s);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= 840;
        final compact = width < 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('TRAVEL APP-д тавтай морил'),
            actions: [
              IconButton(
                icon: Icon(_sortByRating
                    ? Icons.star
                    : Icons.star_outline),
                tooltip: 'Үнэлгээгээр эрэмбэлэх',
                onPressed: () =>
                    setState(() => _sortByRating = !_sortByRating),
              ),
              IconButton(
                icon: Icon(_season == 'Бүгд'
                    ? Icons.filter_list
                    : Icons.filter_alt),
                tooltip: 'Улирлаар шүүх',
                onPressed: _pickSeason,
              ),
            ],
          ),
          drawer: compact ? const AppDrawer() : null,
          floatingActionButton: FloatingActionButton(
            onPressed: _addPlace,
            tooltip: 'Газар нэмэх',
            child: const Icon(Icons.add_location_alt),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _season == 'Бүгд'
                        ? 'Газрын нэрээр хайх'
                        : 'Газрын нэрээр хайх · $_season',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Арилгах',
                            onPressed: () => setState(_search.clear),
                          ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                // Үнэлгээ өөрчлөгдөхөд эрэмбэ шууд шинэчлэгдэнэ
                child: ValueListenableBuilder<Map<String, int>>(
                  valueListenable: userRatings,
                  builder: (context, ratings, _) {
                    final list = _visible(ratings);
                    if (list.isEmpty) {
                      return const Center(child: Text('Газар олдсонгүй'));
                    }
                    return wide
                        ? _buildWide(list)
                        : _buildGrid(list, width >= 600 ? 3 : 2);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<Place> list, int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => PlaceCard(
        place: list[i],
        onTap: () => context.push('/place/${list[i].id}'),
      ),
    );
  }

  Widget _buildWide(List<Place> list) {
    final selected = list.firstWhere(
      (p) => p.id == _selected?.id,
      orElse: () => list.first,
    );
    return Row(
      children: [
        SizedBox(
          width: 340,
          child: ListView(
            children: [
              for (final p in list)
                ListTile(
                  leading: ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: PlaceImage(place: p),
                    ),
                  ),
                  title: Text(p.name),
                  subtitle: Text(p.region),
                  selected: p.id == selected.id,
                  onTap: () => setState(() => _selected = p),
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: PlaceDetailView(place: selected)),
      ],
    );
  }
}
