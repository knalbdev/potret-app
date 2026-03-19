import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../provider/auth_provider.dart';
import '../../provider/story_provider.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key, required this.storyId});

  final String storyId;

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDetail());
  }

  void _fetchDetail() {
    final token = context.read<AuthProvider>().token ?? '';
    context.read<StoryProvider>().fetchStoryDetail(
      token: token,
      id: widget.storyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, _) {
          if (storyProvider.state == StoryState.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.warmGold),
            );
          }

          if (storyProvider.state == StoryState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    storyProvider.errorMessage ?? l10n.errorOccurred,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _fetchDetail,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final story = storyProvider.selectedStory;
          if (story == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.warmGold),
            );
          }

          final hasLocation = story.lat != null && story.lon != null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.charcoal,
                foregroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.creamDark,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.warmGold,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.creamDark,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.warmGoldLight,
                            child: Text(
                              story.name.isNotEmpty
                                  ? story.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.warmGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            story.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),
                      Text(
                        story.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (hasLocation) ...[
                        const SizedBox(height: 24),
                        _MapSection(
                          lat: story.lat!,
                          lon: story.lon!,
                          address: storyProvider.locationAddress,
                          label: l10n.locationOnMap,
                          fetchingAddress: l10n.fetchingAddress,
                          noAddress: l10n.noAddress,
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.lat,
    required this.lon,
    required this.address,
    required this.label,
    required this.fetchingAddress,
    required this.noAddress,
  });

  final double lat;
  final double lon;
  final String? address;
  final String label;
  final String fetchingAddress;
  final String noAddress;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(lat, lon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.warmGold),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: address != null
              ? Row(
                  key: const ValueKey('address'),
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('loading'),
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.warmGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fetchingAddress,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: position,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('story_location'),
                  position: position,
                  infoWindow: InfoWindow(
                    title: address ?? fetchingAddress,
                  ),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
            ),
          ),
        ),
      ],
    );
  }
}
