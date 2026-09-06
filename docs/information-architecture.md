# Information Architecture & Navigation Redesign

> **Date:** 2026-09-04  
> **Status:** Phase 0 Completed

---

## 1. Overview

As Learn Loop expands from 5 basic worksheet screens into a comprehensive **Early Childhood Development Worksheet Platform**, organizing screens in a flat list is no longer viable. 

This document defines the new **Goal-Oriented Information Architecture**. Users will browse activities primarily by **developmental learning goals** (e.g., Pencil Control, Early Math, Focus & Attention), powered by a centralized **Worksheet Activity Registry**.

---

## 2. Top-Level Developmental Goal Taxonomy

Activities are categorized under 9 primary developmental domains:

```
                               ┌───────────────────────────────────┐
                               │           Learn Loop UI           │
                               └─────────────────┬─────────────────┘
                                                 │
   ┌───────────────┬───────────────┬─────────────┼─────────────┬───────────────┬───────────────┐
   ▼               ▼               ▼             ▼             ▼               ▼               ▼
Pencil Control  Focus &        Thinking &     Early Math    Early         Fine Motor      Shapes, Coloring,
& Pre-Writing   Attention      Logic                        Literacy      & Scissor       Drawing & Creativity
```

### Taxonomy Details & Activity Mapping

1. **Pencil Control & Pre-Writing (`pencil_control`)**
   - Straight, Vertical, Horizontal & Diagonal Lines
   - Curves, Waves, Zigzags, Loops & Spirals
   - Tracing Path Corridors (Wide to Narrow)
   - Simple Visual Mazes
   - Shape Tracing & Stroke Guidelines

2. **Focus & Attention (`focus_attention`)**
   - Find and Circle Target Objects
   - Visual Scanning & Letter/Number Search
   - Odd One Out
   - Search Grids & Distractor Challenges
   - Find N Targets

3. **Thinking & Logic (`thinking_logic`)**
   - Pattern Completion (AB, AAB, ABB, ABC)
   - Sequences & What Comes Next
   - Column Matching (Shadows, Categories, Animals to Homes)
   - Same vs. Different Classification
   - Simple Logical Order

4. **Early Math (`early_math`)**
   - Number Tracing & Writing
   - Count & Write / Count & Color
   - Number-to-Quantity & Quantity-to-Number Matching
   - Missing Numbers & Number Sequences (Before/After)
   - More, Less, or Equal Quantity Comparison
   - Visual Addition & Subtraction
   - Scratch Workspace Arithmetic (Vertical/Horizontal)

5. **Early Literacy (`early_literacy`)**
   - Uppercase & Lowercase Letter Tracing (Zaner-Bloser Guidelines)
   - Uppercase-to-Lowercase Matching
   - Target Letter Recognition
   - Missing Letters & Alphabet Sequences
   - Beginning Sounds & Letter-Picture Matching
   - Simple CVC Word Tracing & Practice

6. **Fine Motor & Scissor Skills (`fine_motor`)**
   - Dot Trails & Guided Path Tracing
   - Connect-the-Dots (Numbers 1-10, 1-20, Alphabet)
   - Scissor Cutting Practice (Straight, Curved, Zigzag, Shapes, Object Paths)

7. **Shapes & Spatial Skills (`shapes_spatial`)**
   - Basic Shape Tracing (Circle, Square, Triangle, Rectangle, Star, Heart, Diamond, Oval)
   - Shape Matching & Recognition
   - Complete the Shape
   - Spatial Awareness (Inside/Outside, Above/Below, Left/Right)

8. **Drawing & Creativity (`drawing_creativity`)**
   - Trace and Draw
   - Copy the Drawing Grid
   - Complete the Picture & Symmetry Completion
   - Step-by-Step Guided Drawing

9. **Coloring Pages (`coloring`)**
   - Single Image Coloring Pages
   - Multi-Image Themed Collections (Animals, Vehicles, Space, Nature, Food, Shapes, Alphabet)
   - Mixed Educational Coloring Worksheets

---

## 3. Navigation Hierarchy & User Flow

```
Home Dashboard (Developmental Categories Grid + Profile Header)
├── Search & Filter Bar (Search by keyword, filter by age/skill)
├── Category View (Browse activities within selected Developmental Goal)
│   └── Activity Card
│       └── Worksheet Editor (Split view desktop / Tabbed view mobile)
│           ├── Customize Panel (Sensible defaults + age-appropriate parameters)
│           └── Preview & Print Panel (Instant PDF render + Print/Export)
├── Recent Worksheets (Quick re-generation from seed)
└── Favorites (Saved worksheet configurations)
```

---

## 4. Centralized Worksheet Registry Architecture

To eliminate hardcoded activity lists across screens, Learn Loop will introduce a **Worksheet Registry System** (`lib/registry/worksheet_registry.dart`).

### `WorksheetActivity` Metadata Model Concept

```dart
class WorksheetActivity {
  final String id;
  final String title;
  final String description;
  final List<String> categoryIds; // e.g. ['pencil_control', 'shapes_spatial']
  final List<String> tags;        // e.g. ['tracing', 'lines', 'preschool']
  final List<String> targetSkills; // e.g. ['pencil_control', 'fine_motor']
  final int minAge;
  final int maxAge;
  final IconData icon;
  final Widget Function(BuildContext) editorBuilder;

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
    required this.editorBuilder,
  });
}
```

### Benefits of the Registry Architecture
- **Multi-Category Assignment:** A single worksheet (e.g., "Shape Tracing") can naturally appear under both *Pencil Control* and *Shapes & Spatial* without duplicating routes or logic.
- **Dynamic Search & Filtering:** Local instant search filters activities based on `title`, `description`, `tags`, and `targetSkills`.
- **Extensibility:** Adding a new worksheet type simply requires registering a metadata entry in the registry.

---

## 5. Favorites & Recent Worksheets Persistence

Worksheets will support seedable configurations. Instead of storing heavy compiled PDF files on disk, Learn Loop will store lightweight JSON payloads representing the worksheet configuration and seed:

```json
{
  "activityId": "counting_count_and_write",
  "seed": 42918,
  "timestamp": "2026-09-04T01:15:00Z",
  "config": {
    "minNumber": 1,
    "maxNumber": 10,
    "shapeType": "apple",
    "questionsPerPage": 6
  }
}
```

This guarantees:
- Fast saving and loading via `SharedPreferences`.
- Deterministic, pixel-perfect PDF re-generation.
- Easy sharing and favoriting.
