import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constansts/color_manger.dart';
import '../../../core/resource/app_strings.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Demo favorites list - replace with actual data from provider
    final List<Map<String, dynamic>> favorites = [
      {
        'id': 1,
        'title': 'Favorite Item 1',
        'subtitle': 'Added recently',
        'icon': Icons.star,
      },
      {
        'id': 2,
        'title': 'Favorite Item 2',
        'subtitle': 'Added 2 days ago',
        'icon': Icons.bookmark,
      },
      {
        'id': 3,
        'title': 'Favorite Item 3',
        'subtitle': 'Added last week',
        'icon': Icons.favorite,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.favorites),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // Handle sort action
            },
          ),
        ],
      ),
      body: SafeArea(
        child: favorites.isEmpty
            ? _buildEmptyState(context)
            : _buildFavoritesList(context, favorites),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: ColorManager.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppString.noFavorites,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColorManager.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppString.noFavoritesSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to explore
            },
            icon: const Icon(Icons.explore),
            label: const Text(AppString.startExploring),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    BuildContext context,
    List<Map<String, dynamic>> favorites,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return Dismissible(
          key: Key(item['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: ColorManager.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: ColorManager.whiteColor),
          ),
          onDismissed: (_) {
            // Handle remove from favorites
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: ColorManager.whiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: ColorManager.primary,
                  size: 28,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                item['subtitle'] as String,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: ColorManager.textSecondary,
              ),
              onTap: () {
                // Handle item tap
              },
            ),
          ),
        );
      },
    );
  }
}
