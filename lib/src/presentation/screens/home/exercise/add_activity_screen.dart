import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/domain/entities/activity.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  List<Activity> activities = [];
  List<Activity> filteredActivities = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final int pageSize = 20;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _searchController.addListener(_filterActivities);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore &&
        hasMore &&
        _searchController.text.isEmpty) {
      _loadMoreActivities();
    }
  }

  Future<void> _loadActivities() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      currentPage = 1;
      activities = [];
      hasMore = true;
    });

    final repository = AppRoutes.getActivityRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final result = await repository.getActivities(
        page: currentPage,
        limit: pageSize,
      );
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        },
        (activityList) {
          if (mounted) {
            setState(() {
              activities = activityList;
              filteredActivities = activityList;
              isLoading = false;
              hasMore = activityList.length >= pageSize;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreActivities() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    final repository = AppRoutes.getActivityRepository();
    if (repository == null) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
      return;
    }

    try {
      final result = await repository.getActivities(
        page: currentPage + 1,
        limit: pageSize,
      );
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              isLoadingMore = false;
            });
          }
        },
        (activityList) {
          if (mounted) {
            setState(() {
              currentPage++;
              activities.addAll(activityList);
              filteredActivities = activities;
              isLoadingMore = false;
              hasMore = activityList.length >= pageSize;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  void _filterActivities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredActivities = activities;
      } else {
        filteredActivities =
            activities
                .where(
                  (activity) => activity.name.toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (filteredActivities.isEmpty && _searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search for activities',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    if (filteredActivities.isEmpty) {
      return const Center(
        child: Text(
          'No activities found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: filteredActivities.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredActivities.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final activity = filteredActivities[index];

        return ListTile(
          title: Text(activity.name),
          subtitle: Text('MET: ${activity.metValue.toStringAsFixed(1)}'),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            ],
          ),
          onTap: () {
            // TODO: Navigate to activity detail or log activity
          },
        );
      },
      separatorBuilder:
          (context, index) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
    );
  }
}
