import 'package:flutter/material.dart';
import 'handwriting_screen.dart';
import 'counting_screen.dart';
import 'math_screen.dart';
import 'prewriting_screen.dart';
import 'shapes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // List of worksheet generators
    final generators = [
      _GeneratorItem(
        title: "Handwriting Practice",
        subtitle: "Trace names, letters, numbers, and custom words with customized guidelines.",
        icon: Icons.edit_note,
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo to Purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        route: const HandwritingScreen(),
      ),
      _GeneratorItem(
        title: "Numbers & Counting",
        subtitle: "Generate outline shape grids for counting or number mapping workspaces.",
        icon: Icons.pin_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)], // Amber to Red
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        route: const CountingScreen(),
      ),
      _GeneratorItem(
        title: "Addition & Subtraction",
        subtitle: "Simple horizontal/vertical math problems with custom drawing grids.",
        icon: Icons.calculate_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)], // Emerald to Green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        route: const MathScreen(),
      ),
      _GeneratorItem(
        title: "Pre-Writing Lines",
        subtitle: "Fine motor practice tracing straight lines, curves, waves, and zigzags.",
        icon: Icons.gesture,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF43F5E)], // Pink to Rose
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        route: const PrewritingScreen(),
      ),
      _GeneratorItem(
        title: "Shapes Tracing",
        subtitle: "Learn shapes (circles, stars, hearts) with dotted lines and stroke guides.",
        icon: Icons.star_border,
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)], // Blue to Cyan
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        route: const ShapesScreen(),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              expandedHeight: 180,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Learn Loop",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onBackground,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Preschool & Toddler Worksheet Maker",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400.0,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = generators[index];
                    return _buildGeneratorCard(context, item);
                  },
                  childCount: generators.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratorCard(BuildContext context, _GeneratorItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item.route),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: item.gradient,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneratorItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Widget route;

  _GeneratorItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
  });
}
