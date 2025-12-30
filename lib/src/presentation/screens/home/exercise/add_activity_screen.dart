import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/domain/entities/activity.dart';
import 'package:flutter/material.dart';

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
        filteredActivities = activities
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.add, color: Colors.black, size: 26),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search activities',
                hintStyle: TextStyle(color: AppColors.textPrimary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textPrimary,
                ),
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : filteredActivities.isEmpty
                    ? const Center(
                        child: Text(
                          'No activities found',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:
                            filteredActivities.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredActivities.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }

                          final activity = filteredActivities[index];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  activity.name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  'MET: ${activity.metValue.toStringAsFixed(1)} • ${activity.categories.join(", ")}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  // TODO: Navigate to activity detail or log activity
                                },
                              ),
                              const Divider(
                                color: Colors.black,
                                thickness: 0.5,
                                height: 4,
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
