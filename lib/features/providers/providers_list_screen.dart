import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/catalog_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../shell/services_tab.dart';
import 'provider_detail_screen.dart';

class ProvidersListScreen extends StatefulWidget {
  const ProvidersListScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen> {
  String _filter = 'All Services';
  String _query = '';

  List<ServicePro> _resultsFrom(List<ServicePro> providers) => providers
      .where((p) => _filter == 'All Services' || p.category == _filter)
      .where((p) =>
          _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.profession.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final results = _resultsFrom(context.watch<CatalogState>().providers);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ModuleHeader(title: 'Service Providers', onBack: widget.onBack),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchField(
              hint: 'Search for services or professionals...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          FilterChipsRow(
            items: kProviderFilters,
            selected: _filter,
            onSelected: (v) => setState(() => _filter = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text('No professionals here yet.',
                        style: TextStyle(color: AppColors.muted)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => ProviderCard(pro: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class ProviderCard extends StatelessWidget {
  const ProviderCard({super.key, required this.pro});
  final ServicePro pro;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => _open(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            height: 136,
            child: AppImage(pro.photo, radius: 12),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pro.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.star),
                        const SizedBox(width: 3),
                        Text(
                          pro.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  pro.profession.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w700,
                    color: pro.professionColor,
                  ),
                ),
                const SizedBox(height: 10),
                IconLabel(Icons.work_outline_rounded,
                    '${pro.years} Years Experience'),
                const SizedBox(height: 5),
                IconLabel(Icons.location_on_outlined,
                    '${pro.distance} miles away'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _open(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => ProviderDetailScreen(pro: pro)),
    );
  }
}
