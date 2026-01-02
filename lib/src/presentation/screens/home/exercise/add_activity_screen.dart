import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/routes.dart';
import 'package:da1/src/domain/entities/activity.dart';
import 'package:da1/src/presentation/screens/home/exercise/log_activity_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore &&
        hasMore) {
      if (_searchController.text.isEmpty) {
        _loadMoreActivities();
      } else {
        _searchMoreActivities();
      }
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isEmpty) {
        _loadActivities();
      } else {
        _searchActivities(_searchController.text);
      }
    });
  }

  Future<void> _searchActivities(String query) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      currentPage = 1;
      filteredActivities = [];
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
      final result = await repository.searchActivities(
        name: query,
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

  Future<void> _searchMoreActivities() async {
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
      final result = await repository.searchActivities(
        name: _searchController.text,
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
              filteredActivities.addAll(activityList);
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
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LogActivityScreen(activity: activity),
              ),
            );

            if (result == true && context.mounted) {
              Navigator.pop(context, true);
            }
          },
        );
      },
      separatorBuilder:
          (context, index) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
    );
  }
}
