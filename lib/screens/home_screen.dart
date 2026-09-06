import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../registry/worksheet_activity.dart';
import '../registry/worksheet_registry.dart';
import '../services/settings_service.dart';
import '../widgets/kid_profile_card.dart';
import '../widgets/worksheet_search_delegate.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchDonation({String campaign = 'home_screen'}) async {
    final Uri url = Uri.parse(
      'https://asifiqbal.rocks/donation?utm_source=learn_loop&utm_medium=flutter_app&utm_campaign=$campaign&ref=learn-loop-app',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goals = DevelopmentalGoal.allGoals;
    final activities = WorksheetRegistry.getAll();

    return Scaffold(
      drawer: _buildHamburgerDrawer(context, goals, activities),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              expandedHeight: 180,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  tooltip: "Open Menu",
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded, size: 24),
                  tooltip: "Search Worksheets",
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: WorksheetSearchDelegate(),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FilledButton.tonalIcon(
                    icon: const Icon(
                      Icons.coffee,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                    label: const Text("Support"),
                    onPressed: () =>
                        _launchDonation(campaign: 'app_bar_button'),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Learn Loop",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Early Childhood Worksheet Platform",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                tabs: const [
                  Tab(
                    text: "Learning Goals",
                    icon: Icon(Icons.grid_view_rounded),
                  ),
                  Tab(text: "All Worksheets", icon: Icon(Icons.apps_rounded)),
                  Tab(
                    text: "Favorites & Recent",
                    icon: Icon(Icons.bookmark_outline_rounded),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLearningGoalsView(context, goals),
            _buildAllWorksheetsView(context, activities),
            _buildFavoritesAndRecentsView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningGoalsView(
    BuildContext context,
    List<DevelopmentalGoal> goals,
  ) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          "DEVELOPMENTAL GOALS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400.0,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 1.4,
          ),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final activityCount = WorksheetRegistry.getByCategory(
              goal.id,
            ).length;
            return _buildGoalCard(context, goal, activityCount);
          },
        ),
        const SizedBox(height: 24),
        _buildEnhancedBottomSupportCard(context, theme),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    DevelopmentalGoal goal,
    int activityCount,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              MaterialPageRoute(
                builder: (context) => CategoryScreen(goal: goal),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: goal.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(goal.icon, size: 28, color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activityCount > 0
                              ? "$activityCount Worksheets"
                              : "Coming Soon",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
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

  Widget _buildAllWorksheetsView(
    BuildContext context,
    List<WorksheetActivity> activities,
  ) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          "ALL WORKSHEET MODULES",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400.0,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 1.8,
          ),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityCard(context, activity);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, WorksheetActivity activity) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => activity.routeBuilder(context),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  activity.icon,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesAndRecentsView(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Favorites Section
        Text(
          "FAVORITES",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<SavedWorksheetSeed>>(
          valueListenable: SettingsService.favoritesNotifier,
          builder: (context, favorites, _) {
            if (favorites.isEmpty) {
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(Icons.star_border_rounded, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        "No favorites saved yet. Save configurations for quick access!",
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: favorites
                  .map((seed) => _buildSeedTile(context, seed, isFav: true))
                  .toList(),
            );
          },
        ),

        const SizedBox(height: 24),

        // Recents Section
        Text(
          "RECENTLY GENERATED",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<SavedWorksheetSeed>>(
          valueListenable: SettingsService.recentsNotifier,
          builder: (context, recents, _) {
            if (recents.isEmpty) {
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, color: Colors.grey),
                      SizedBox(width: 12),
                      Text("No recent worksheets generated yet."),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: recents
                  .map((seed) => _buildSeedTile(context, seed, isFav: false))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSeedTile(
    BuildContext context,
    SavedWorksheetSeed seed, {
    required bool isFav,
  }) {
    final theme = Theme.of(context);
    final activity = WorksheetRegistry.getById(seed.activityId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        leading: Icon(
          activity?.icon ?? Icons.description_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          seed.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Seed: #${seed.seed} • ${seed.timestamp.toString().substring(0, 10)}",
        ),
        trailing: IconButton(
          icon: Icon(
            SettingsService.isFavorite(seed.activityId, seed.seed)
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFF59E0B),
          ),
          onPressed: () async {
            await SettingsService.toggleFavorite(seed);
          },
        ),
        onTap: () {
          if (activity != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => activity.routeBuilder(context),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHamburgerDrawer(
    BuildContext context,
    List<DevelopmentalGoal> goals,
    List<WorksheetActivity> activities,
  ) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Branding Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Learn Loop",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Early Childhood Worksheet Platform",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                children: [
                  // Global Kid Profile Section
                  Text(
                    "LEARNER PROFILE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const KidProfileCard(compact: true),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Developmental Goals Section
                  Text(
                    "DEVELOPMENTAL GOALS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...goals.map((goal) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      leading: Icon(
                        goal.icon,
                        size: 20,
                        color: goal.gradientColors.first,
                      ),
                      title: Text(
                        goal.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryScreen(goal: goal),
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Worksheet Modules
                  Text(
                    "WORKSHEET MODULES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...activities.map((item) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      leading: Icon(
                        item.icon,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => item.routeBuilder(context),
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Support & Donation in Hamburger Menu
                  Material(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        ),
                      ),
                      leading: const Icon(
                        Icons.coffee_rounded,
                        color: Color(0xFFF59E0B),
                      ),
                      title: const Text(
                        "Support LearnLoop",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        "Help fund free educational tools",
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: const Icon(Icons.open_in_new, size: 16),
                      onTap: () => _launchDonation(campaign: 'drawer_menu'),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Learn Loop v1.0.0 • Made with ❤️ for early learners",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedBottomSupportCard(
    BuildContext context,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.08),
            const Color(0xFF8B5CF6).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Support Learn Loop",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "100% Free",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Learn Loop is a free, open-source tool designed for teachers, parents, and homeschoolers. Your support helps fund new printable generators, font improvements, and educational features.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                icon: const Icon(
                  Icons.coffee_rounded,
                  size: 18,
                  color: Color(0xFFFDE68A),
                ),
                label: const Text("Donate"),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _launchDonation(campaign: 'home_bottom_card'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
