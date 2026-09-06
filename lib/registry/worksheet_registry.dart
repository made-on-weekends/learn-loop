import 'worksheet_activity.dart';
import '../screens/handwriting_screen.dart';
import '../screens/counting_screen.dart';
import '../screens/math_screen.dart';
import '../screens/prewriting_screen.dart';
import '../screens/shapes_screen.dart';
import '../screens/focus_attention_screen.dart';
import '../screens/thinking_logic_screen.dart';
import '../screens/scissor_skills_screen.dart';
import '../screens/coloring_screen.dart';
import '../screens/drawing_screen.dart';
import 'package:flutter/material.dart';

class WorksheetRegistry {
  static final List<WorksheetActivity> _activities = [
    WorksheetActivity(
      id: 'handwriting_practice',
      title: 'Handwriting & Early Literacy',
      description:
          'A-Z uppercase/lowercase, case matching, alphabet sequence missing letters, beginning sounds, CVC words, sight words, and custom text with Zaner-Bloser guidelines.',
      categoryIds: ['early_literacy', 'pencil_control'],
      tags: [
        'handwriting',
        'alphabet',
        'tracing',
        'letters',
        'numbers',
        'zaner-bloser',
        'writing',
        'cvc',
        'sight words',
        'phonics',
        'matching',
      ],
      targetSkills: [
        'letter_recognition',
        'fine_motor',
        'pencil_control',
        'phonemic_awareness',
        'early_reading',
      ],
      minAge: 3,
      maxAge: 8,
      icon: Icons.edit_note,
      routeBuilder: (context) => const HandwritingScreen(),
    ),
    WorksheetActivity(
      id: 'numbers_counting',
      title: 'Numbers & Counting',
      description:
          'Count & write, draw to match, number tracing 1-20, group comparisons (more vs less), and sequence fill-in-the-blank.',
      categoryIds: ['early_math', 'focus_attention'],
      tags: [
        'counting',
        'numbers',
        'tracing',
        'more',
        'less',
        'sequence',
        'shapes',
        'math',
        'quantity',
        'preschool',
      ],
      targetSkills: [
        'number_sense',
        'counting',
        'visual_discrimination',
        'number_recognition',
      ],
      minAge: 2,
      maxAge: 6,
      icon: Icons.pin_outlined,
      routeBuilder: (context) => const CountingScreen(),
    ),
    WorksheetActivity(
      id: 'addition_subtraction',
      title: 'Addition & Subtraction',
      description:
          'Horizontal/vertical equations, number line jump guides, ten-frame visual grids, number bonds, and missing terms.',
      categoryIds: ['early_math', 'thinking_logic'],
      tags: [
        'addition',
        'subtraction',
        'math',
        'arithmetic',
        'number line',
        'ten frame',
        'number bonds',
        'missing term',
        'equations',
      ],
      targetSkills: ['arithmetic', 'reasoning', 'number_sense', 'visual_math'],
      minAge: 4,
      maxAge: 8,
      icon: Icons.calculate_outlined,
      routeBuilder: (context) => const MathScreen(),
    ),
    WorksheetActivity(
      id: 'prewriting_lines',
      title: 'Pre-Writing Lines',
      description:
          'Fine motor practice tracing straight lines, curves, waves, and zigzags.',
      categoryIds: ['pencil_control', 'fine_motor'],
      tags: [
        'prewriting',
        'lines',
        'tracing',
        'fine motor',
        'pencil control',
        'waves',
        'zigzags',
      ],
      targetSkills: ['pencil_control', 'fine_motor', 'visual_motor'],
      minAge: 2,
      maxAge: 5,
      icon: Icons.gesture,
      routeBuilder: (context) => const PrewritingScreen(),
    ),
    WorksheetActivity(
      id: 'shapes_tracing',
      title: 'Shapes Tracing',
      description:
          'Learn shapes (circles, stars, hearts) with dotted lines and stroke guides.',
      categoryIds: ['shapes_spatial', 'pencil_control'],
      tags: [
        'shapes',
        'tracing',
        'geometry',
        'star',
        'heart',
        'circle',
        'square',
        'triangle',
      ],
      targetSkills: ['spatial_awareness', 'pencil_control', 'fine_motor'],
      minAge: 2,
      maxAge: 6,
      icon: Icons.star_border,
      routeBuilder: (context) => const ShapesScreen(),
    ),
    WorksheetActivity(
      id: 'focus_attention',
      title: 'Focus & Visual Attention',
      description:
          'Find & circle targets, scanning grids, odd-one-out, and visual search activities.',
      categoryIds: ['focus_attention', 'thinking_logic'],
      tags: [
        'focus',
        'attention',
        'search',
        'find',
        'circle',
        'odd one out',
        'scanning',
        'grid',
      ],
      targetSkills: ['visual_discrimination', 'focus', 'attention', 'scanning'],
      minAge: 3,
      maxAge: 8,
      icon: Icons.center_focus_strong_outlined,
      routeBuilder: (context) => const FocusAttentionScreen(),
    ),
    WorksheetActivity(
      id: 'thinking_logic',
      title: 'Thinking & Logic',
      description:
          'Pattern completion (AB, AAB, ABC), two-column matching, same vs different, and size ordering.',
      categoryIds: ['thinking_logic', 'early_math'],
      tags: [
        'logic',
        'pattern',
        'matching',
        'same',
        'different',
        'sequence',
        'thinking',
        'ordering',
        'size',
      ],
      targetSkills: [
        'pattern_recognition',
        'logical_reasoning',
        'matching',
        'classification',
      ],
      minAge: 3,
      maxAge: 8,
      icon: Icons.psychology_outlined,
      routeBuilder: (context) => const ThinkingLogicScreen(),
    ),
    WorksheetActivity(
      id: 'scissor_skills',
      title: 'Scissor Skills & Cutting',
      description:
          'Straight, curved, and zigzag cutting lines, shape outlines, and cut-and-paste matching activities.',
      categoryIds: ['fine_motor', 'pencil_control'],
      tags: [
        'scissor',
        'cutting',
        'lines',
        'curves',
        'zigzag',
        'shapes',
        'cut and paste',
        'fine motor',
      ],
      targetSkills: [
        'scissor_control',
        'fine_motor',
        'bilateral_coordination',
        'hand_eye_coordination',
      ],
      minAge: 3,
      maxAge: 6,
      icon: Icons.content_cut,
      routeBuilder: (context) => const ScissorSkillsScreen(),
    ),
    WorksheetActivity(
      id: 'coloring_pages',
      title: 'Coloring Pages & Name Tracing',
      description:
          'Printable thick-contour vector coloring pages for animals, vehicles, food, nature, and space with word tracing.',
      categoryIds: ['coloring', 'drawing_creativity', 'fine_motor'],
      tags: [
        'coloring',
        'color',
        'animal',
        'vehicle',
        'car',
        'bear',
        'rocket',
        'apple',
        'tree',
        'star',
        'tracing',
        'art',
      ],
      targetSkills: [
        'fine_motor',
        'creativity',
        'color_recognition',
        'pencil_control',
      ],
      minAge: 2,
      maxAge: 7,
      icon: Icons.palette_outlined,
      routeBuilder: (context) => const ColoringScreen(),
    ),
    WorksheetActivity(
      id: 'drawing_creativity',
      title: 'Drawing & Creative Prompts',
      description:
          'Finish the Drawing symmetry grids, step-by-step drawing guides, draw & write story prompts, and dot-to-dot number connects.',
      categoryIds: ['drawing_creativity', 'coloring', 'fine_motor'],
      tags: [
        'drawing',
        'symmetry',
        'grid',
        'step by step',
        'story',
        'prompt',
        'dot to dot',
        'connect dots',
        'creativity',
        'art',
      ],
      targetSkills: [
        'creativity',
        'spatial_awareness',
        'fine_motor',
        'hand_eye_coordination',
        'storytelling',
      ],
      minAge: 3,
      maxAge: 8,
      icon: Icons.brush_outlined,
      routeBuilder: (context) => const DrawingScreen(),
    ),
  ];

  static List<WorksheetActivity> getAll() {
    return List.unmodifiable(_activities);
  }

  static WorksheetActivity? getById(String id) {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<WorksheetActivity> getByCategory(String categoryId) {
    return List.unmodifiable(
      _activities.where((a) => a.categoryIds.contains(categoryId)),
    );
  }

  static List<WorksheetActivity> getForAge(int age) {
    return List.unmodifiable(
      _activities.where((a) => age >= a.minAge && age <= a.maxAge),
    );
  }

  static List<WorksheetActivity> search(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return getAll();
    }
    return List.unmodifiable(
      _activities.where((a) {
        final titleMatch = a.title.toLowerCase().contains(cleanQuery);
        final descMatch = a.description.toLowerCase().contains(cleanQuery);
        final tagMatch = a.tags.any(
          (tag) => tag.toLowerCase().contains(cleanQuery),
        );
        final skillMatch = a.targetSkills.any(
          (skill) => skill.toLowerCase().contains(cleanQuery),
        );
        return titleMatch || descMatch || tagMatch || skillMatch;
      }),
    );
  }
}
