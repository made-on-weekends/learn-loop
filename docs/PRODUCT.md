# PRODUCT.md

> What we're building, for whom, and what is explicitly NOT in scope.
> This is the canonical scope document. Agents must check here before adding features.

## Product

A mobile and web application that allows parents, preschool teachers, and home-school educators to dynamically customize, preview, and print A4-sized educational worksheets for toddlers.

## Target user

Parents, home-school educators, and preschool teachers of toddlers and preschoolers (ages 2–6) who need custom handwriting, arithmetic, counting, fine motor, and shape worksheets.

## Anti-persona

- Advanced grade schoolers (ages 7+) requiring complex math (multiplication/division), reading comprehension, or science.
- Users who need offline printing without any customization (we target dynamic customization and instant preview).

## Core value

Dynamic, ink-efficient A4 worksheet generation directly on the client device, allowing complete control over guidelines, tracing lines, numbers, shapes, and arithmetic difficulty, with zero printing waste.

## In scope (current phase)

1. **Global Header Config**: Custom sheet title, student name, and date line.
2. **Handwriting Practice**: Solid/dotted letters, numbers, custom words, and toggleable lines (top, midline, baseline, bottom line). Row and column layouts with automatic scaling.
3. **Numbers & Counting**: Count and Write exercises, Draw to Match exercises, and selectable shapes (circle, square, triangle, star, heart, tree, apple).
4. **Addition & Subtraction**: Basic arithmetic in customizable ranges, vertical or horizontal displays, 1/2 column grids, and built-in scratch workspaces.
5. **Pre-Writing Lines**: Dotted lines tracing straight, wave, zigzag, and castle patterns.
6. **Shapes Tracing**: Learning shapes (circle, square, triangle, rectangle, star, heart) with tracing indicators (stroke direction arrows), names, and copy guidelines.

## Explicitly out of scope

- **Online User Account Synchronization**: Works fully offline. (Reason: keep MVP simple, fast, and secure).
- **Gamification/Interactive Games for Kids**: The app is for generating printed sheets, not a game for kids to play on-screen. (Reason: parents want to limit toddler screen time).
- **Phonics, Reading Comprehension, Advanced Math**: Deferred to future phases to maintain product focus on early pre-writing and numeracy skills.

## Phase plan

- **Phase 2 (Post-MVP)**:
  - Letter & number recognition activities (circle the letter, lowercase/uppercase match grids).
  - Phonics matching exercises.
  - Sorting and classification activities (category groupings).
  - Fine motor cutting practice templates.

## Non-goals

- The app is not a digital notepad/whiteboard for drawing or digital handwriting practice.
- The app is not a replacement for full preschool curriculums; it is a supplemental template builder.

## Success criteria

- Quick load time for the PDF preview panel (under 200ms on configuration changes).
- Clean, pixel-perfect print layout on standard physical A4 printers (margins preserved, no content cutoff).
