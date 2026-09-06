import 'package:flutter/material.dart';

class DevelopmentalGoal {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const DevelopmentalGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });

  static const List<DevelopmentalGoal> allGoals = [
    DevelopmentalGoal(
      id: 'pencil_control',
      title: 'Pencil Control & Pre-Writing',
      description:
          'Strokes, lines, curves, waves, zigzags, corridors, and tracing paths.',
      icon: Icons.gesture,
      gradientColors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
    ),
    DevelopmentalGoal(
      id: 'focus_attention',
      title: 'Focus & Attention',
      description:
          'Find and circle, target scanning, odd one out, and visual search grids.',
      icon: Icons.center_focus_strong_outlined,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    ),
    DevelopmentalGoal(
      id: 'thinking_logic',
      title: 'Thinking & Logic',
      description:
          'Patterns, sequences, column matching, sorting, and same vs. different.',
      icon: Icons.psychology_outlined,
      gradientColors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    ),
    DevelopmentalGoal(
      id: 'early_math',
      title: 'Early Math',
      description:
          'Counting, quantity matching, number sequences, and simple arithmetic.',
      icon: Icons.calculate_outlined,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
    DevelopmentalGoal(
      id: 'early_literacy',
      title: 'Early Literacy',
      description:
          'Letter tracing, upper/lower matching, beginning sounds, and phonics.',
      icon: Icons.edit_note,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    ),
    DevelopmentalGoal(
      id: 'fine_motor',
      title: 'Fine Motor & Scissor Skills',
      description:
          'Dot trails, connect-the-dots, and progressive cutting practice.',
      icon: Icons.content_cut,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    DevelopmentalGoal(
      id: 'shapes_spatial',
      title: 'Shapes & Spatial Skills',
      description:
          'Shape tracing, shape recognition, matching, and spatial awareness.',
      icon: Icons.star_border,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    ),
    DevelopmentalGoal(
      id: 'drawing_creativity',
      title: 'Drawing & Creativity',
      description:
          'Trace and draw, copy drawing grids, and symmetry completion.',
      icon: Icons.palette_outlined,
      gradientColors: [Color(0xFFF43F5E), Color(0xFFD97706)],
    ),
    DevelopmentalGoal(
      id: 'coloring',
      title: 'Coloring Pages',
      description:
          'Standalone and educational coloring sheets across child-friendly themes.',
      icon: Icons.color_lens_outlined,
      gradientColors: [Color(0xFFA855F7), Color(0xFFEC4899)],
    ),
  ];

  static DevelopmentalGoal? getById(String id) {
    try {
      return allGoals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}

class WorksheetActivity {
  final String id;
  final String title;
  final String description;
  final List<String> categoryIds;
  final List<String> tags;
  final List<String> targetSkills;
  final int minAge;
  final int maxAge;
  final IconData icon;
  final WidgetBuilder routeBuilder;

  const WorksheetActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryIds,
    required this.tags,
    required this.targetSkills,
    required this.minAge,
    required this.maxAge,
    required this.icon,
    required this.routeBuilder,
  });
}
