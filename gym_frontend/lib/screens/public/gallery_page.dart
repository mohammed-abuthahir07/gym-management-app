import 'package:flutter/material.dart';

import '../../utils/responsive.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  // Hardcoded local asset images list
  final List<Map<String, String>> _localGalleryItems = [
    {
      'title': 'Cardio Arena',
      'description': 'State-of-the-art treadmills, ellipticals, and rowers equipped with performance tracking.',
      'image': 'assets/cardio.png',
    },
    {
      'title': 'Free Weight Floor',
      'description': 'Heavy-duty Olympic bars, bumper plates, power racks, and dumbbells for serious strength training.',
      'image': 'assets/Free Weight Floor.png',
    },
    {
      'title': 'Group Training Sessions',
      'description': 'High-energy instructor-led classes designed to push your limits and build community strength.',
      'image': 'assets/group.png',
    },
    {
      'title': 'Professional Trainers',
      'description': 'Expert coaching and personalized fitness guidance tailored to your specific goals.',
      'image': 'assets/trainer.png',
    },
    {
      'title': 'Back & Core Zone',
      'description': 'Dedicated spaces for core stabilization, mobility work, and auxiliary accessory movements.',
      'image': 'assets/back.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = Responsive.pagePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'Exercise Library & Gallery',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'A glimpse inside our training arenas, Olympic gear, and athlete community.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 32),

              // Grid of Local Assets Images
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 3);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: Responsive.isMobile(context) ? 1.3 : 0.85,
                    ),
                    itemCount: _localGalleryItems.length,
                    itemBuilder: (context, index) {
                      final item = _localGalleryItems[index];
                      final title = item['title']!;
                      final desc = item['description']!;
                      final assetPath = item['image']!;

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Local Asset Image Container
                            SizedBox(
                              height: Responsive.isMobile(context) ? 180 : 200,
                              width: double.infinity,
                              child: Image.asset(
                                assetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, color: Colors.white54),
                                  ),
                                ),
                              ),
                            ),
                            // Text Section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    desc,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}