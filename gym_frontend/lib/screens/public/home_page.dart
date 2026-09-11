import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Section
              Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 48),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withValues(alpha: 0.85),
                        scheme.secondary.withValues(alpha: 0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PREMIUM FITNESS EXPERIENCE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.brandTagline,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AppButton(
                            label: 'Join PeakForge Today',
                            icon: Icons.person_add_outlined,
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.login),
                            label: const Text('Member Login'),
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 2. Stats Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = Responsive.isMobile(context);
                  return Row(
                    children: [
                      Expanded(child: _buildStatItem(context, '5K+', 'Active Members')),
                      SizedBox(width: isMobile ? 8 : 16),
                      Expanded(child: _buildStatItem(context, '15+', 'Expert Trainers')),
                      SizedBox(width: isMobile ? 8 : 16),
                      Expanded(child: _buildStatItem(context, '30+', 'Modern Machines')),
                      SizedBox(width: isMobile ? 8 : 16),
                      Expanded(child: _buildStatItem(context, '100%', 'Result Focused')),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // 3. Introduction Section
              Text(
                'Welcome to PeakForge Gym',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'PeakForge is Madurai\'s premier fitness training facility dedicated to transforming bodies, minds, and lifestyles. We blend state-of-the-art strength machinery, certified elite trainers, customized nutrition planning, and an empowering community culture designed to bring out the absolute best version of you.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 48),

              // 3.1 NEW: Featured Banner Showcase (workout.jpg)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.asset(
                      'assets/workout.jpg',
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 260,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'PUSH YOUR LIMITS EVERY SINGLE DAY',
                            style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'State-of-the-Art Training Floors',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Equipped with top-grade free weights and professional racks for ultimate performance.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // 4. Why Choose PeakForge (Grid)
              Text(
                'Why Choose PeakForge',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 3);
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: Responsive.isMobile(context) ? 2.2 : 1.7,
                    children: const [
                      _FeatureCard(
                        icon: Icons.fitness_center,
                        title: 'Elite Equipment',
                        description: 'Top-tier free weights, Olympic lifting platforms, and ergonomic isolation machines.',
                      ),
                      _FeatureCard(
                        icon: Icons.psychology,
                        title: 'Certified Personal Trainers',
                        description: 'Expert mentorship with tailored workout regimens suited to your fitness goals.',
                      ),
                      _FeatureCard(
                        icon: Icons.restaurant_menu,
                        title: 'Custom Nutrition Plans',
                        description: 'Calorie-targeted diet blueprints and cheat meal monitoring for steady gains.',
                      ),
                      _FeatureCard(
                        icon: Icons.track_changes,
                        title: 'Measurement & Progress Tracking',
                        description: 'Detailed logs for weight, waist, body fat percentage, and strength milestones.',
                      ),
                      _FeatureCard(
                        icon: Icons.timer,
                        title: 'Extended Training Hours',
                        description: 'Early morning to late night access so training seamlessly fits your schedule.',
                      ),
                      _FeatureCard(
                        icon: Icons.workspace_premium,
                        title: 'Rewarding Challenges',
                        description: 'Engaging monthly fitness challenges with gym rewards, merch, and certificates.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // 5. Training Programs / Classes Section
              Text(
                'Our Specialized Programs',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a structured program curated specifically for your fitness objective.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 3);
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.9,
                    children: [
                      _ProgramCard(
                        title: 'Hypertrophy & Mass',
                        subtitle: 'Build serious muscle volume with progressive overload frameworks.',
                        icon: Icons.bolt,
                        color: scheme.primary,
                      ),
                      _ProgramCard(
                        title: 'Fat Loss & Shred',
                        subtitle: 'High-intensity interval routines combined with metabolic conditioning.',
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      _ProgramCard(
                        title: 'Strength & Power',
                        subtitle: 'Master compound movements like Squat, Bench, and Deadlift safely.',
                        icon: Icons.shield,
                        color: Colors.blueAccent,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // 5.1 NEW: Specialized Visual Showcase Grid (sixpacks.jpg & womensixpacks.jpg)
              Text(
                'Transformations & Specialized Focus',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Real transformations engineered through targeted core and physique routines.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 2);
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: const [
                      _ImageShowcaseCard(
                        imagePath: 'assets/sixpacks.jpg',
                        title: 'Advanced Core & Shredding',
                        subtitle: 'Sculpt definition and carve ultimate abdominal strength.',
                      ),
                      _ImageShowcaseCard(
                        imagePath: 'assets/womensixpacks.jpg',
                        title: 'Total Tone & Conditioning',
                        subtitle: 'Empowering women core development and functional core stability.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // 5.2 NEW: Group Workouts & Elite Trainers Section (groupworkout.jpg & ladyTrainer.jpg)
              Text(
                'Community & Expert Coaching',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 2);
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: const [
                      _ImageShowcaseCard(
                        imagePath: 'assets/groupworkout.jpg',
                        title: 'High-Energy Group Sessions',
                        subtitle: 'Feed off the collective drive in our specialized community bootcamps.',
                      ),
                      _ImageShowcaseCard(
                        imagePath: 'assets/ladyTrainer.jpg',
                        title: 'Dedicated Expert Coaching',
                        subtitle: 'Get 1-on-1 personalized mentoring from certified professional trainers.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // 5.3 NEW: Monthly Challenges Banner (challenges.jpg)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/challenges.jpg',
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.military_tech, color: Colors.amber, size: 40),
                          const SizedBox(height: 8),
                          const Text(
                            'JOIN OUR MONTHLY FITNESS CHALLENGES',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Push past your comfort zone, win exciting merchandise, badges, and recognition.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            child: const Text('View Active Challenges'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // 6. Testimonials / Success Stories Section
              Text(
                'Success Stories',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 2);
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.0,
                    children: const [
                      _TestimonialCard(
                        name: 'Karthik Raja',
                        role: 'Member for 8 months',
                        quote: 'PeakForge completely changed my routine. Lost 12 kgs and gained serious confidence thanks to the trainers!',
                      ),
                      _TestimonialCard(
                        name: 'Priya Sundar',
                        role: 'Member for 1 year',
                        quote: 'The best gym environment in Madurai. Clean, state-of-the-art equipment, and extremely motivating atmosphere.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // 7. Call to Action Banner
              Card(
                color: scheme.primaryContainer.withValues(alpha: 0.4),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to transform your lifestyle?',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Explore our flexible membership tiers or contact our friendly team for an in-person gym tour.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      AppButton(
                        label: 'Get Started',
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: scheme.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget to display cards with embedded local assets
class _ImageShowcaseCard extends StatelessWidget {
  const _ImageShowcaseCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  final String imagePath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.2)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.name,
    required this.role,
    required this.quote,
  });

  final String name;
  final String role;
  final String quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '"$quote"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  child: Text(
                    name[0],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(role, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}