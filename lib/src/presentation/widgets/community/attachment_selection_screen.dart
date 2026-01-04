import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/domain/entities/challenge.dart';
import 'package:da1/src/domain/entities/medal.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AttachmentSelectionScreen extends StatefulWidget {
  final String attachmentType;

  const AttachmentSelectionScreen({super.key, required this.attachmentType});

  @override
  State<AttachmentSelectionScreen> createState() =>
      _AttachmentSelectionScreenState();
}

class _AttachmentSelectionScreenState extends State<AttachmentSelectionScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _items = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      switch (widget.attachmentType) {
        case 'meal':
          await _loadMeals();
          break;
        case 'ingredient':
          await _loadIngredients();
          break;
        case 'challenge':
          await _loadChallenges();
          break;
        case 'medal':
          await _loadMedals();
          break;
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMeals() async {
    // If there's a search query, use search API
    if (_searchQuery.isNotEmpty) {
      final repository = AppRoutes.getMealRepository();
      if (repository == null) throw Exception('Meal repository not available');

      final result = await repository.searchMeals(_searchQuery);
      result.fold(
        (failure) => throw Exception(failure.message),
        (meals) => setState(() => _items = meals),
      );
    } else {
      // Show empty state or popular meals
      setState(() => _items = []);
    }
  }

  Future<void> _loadIngredients() async {
    if (_searchQuery.isNotEmpty) {
      final repository = AppRoutes.getMealRepository();
      if (repository == null) throw Exception('Meal repository not available');

      final result = await repository.searchIngredients(_searchQuery);
      result.fold(
        (failure) => throw Exception(failure.message),
        (ingredients) => setState(() => _items = ingredients),
      );
    } else {
      setState(() => _items = []);
    }
  }

  Future<void> _loadChallenges() async {
    final repository = AppRoutes.getChallengeRepository();
    if (repository == null) {
      throw Exception('Challenge repository not available');
    }
    final result = await repository.getChallenges();
    result.fold(
      (failure) => throw Exception(failure.toString()),
      (challenges) => setState(() => _items = challenges),
    );
  }

  Future<void> _loadMedals() async {
    final repository = AppRoutes.getMedalRepository();
    if (repository == null) throw Exception('Medal repository not available');

    final result = await repository.getMedals();
    result.fold(
      (failure) => throw Exception(failure.toString()),
      (medals) => setState(() => _items = medals),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });

    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value) {
        _loadItems();
      }
    });
  }

  String _getTitle() {
    switch (widget.attachmentType) {
      case 'meal':
        return 'Select Meal';
      case 'ingredient':
        return 'Select Ingredient';
      case 'challenge':
        return 'Select Challenge';
      case 'medal':
        return 'Select Medal';
      default:
        return 'Select Item';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _getTitle(),
          style: AppTypography.headline.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (widget.attachmentType == 'meal' ||
              widget.attachmentType == 'ingredient')
            _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(LucideIcons.search, size: 20),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.circleAlert, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTypography.body.copyWith(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              (widget.attachmentType == 'meal' ||
                      widget.attachmentType == 'ingredient')
                  ? 'Start typing to search'
                  : 'No items available',
              style: AppTypography.body.copyWith(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(dynamic item) {
    switch (widget.attachmentType) {
      case 'meal':
        return _buildMealCard(item);
      case 'ingredient':
        return _buildIngredientCard(item);
      case 'challenge':
        return _buildChallengeCard(item as Challenge);
      case 'medal':
        return _buildMedalCard(item as Medal);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            LucideIcons.utensils,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          meal['name'] ?? 'Unknown',
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${meal['kcal_per_100gr'] ?? 0} kcal',
          style: AppTypography.body.copyWith(fontSize: 12),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
        onTap:
            () => Navigator.pop(context, {
              'id': meal['id'],
              'name': meal['name'],
              'type': 'meal',
            }),
      ),
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(LucideIcons.leaf, color: Colors.green, size: 24),
        ),
        title: Text(
          ingredient['name'] ?? 'Unknown',
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${ingredient['kcal_per_100gr'] ?? 0} kcal',
          style: AppTypography.body.copyWith(fontSize: 12),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
        onTap:
            () => Navigator.pop(context, {
              'id': ingredient['id'],
              'name': ingredient['name'],
              'type': 'ingredient',
            }),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    Color difficultyColor;
    switch (challenge.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: difficultyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              challenge.imageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      challenge.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stack) => Icon(
                            LucideIcons.flag,
                            color: difficultyColor,
                            size: 24,
                          ),
                    ),
                  )
                  : Icon(LucideIcons.flag, color: difficultyColor, size: 24),
        ),
        title: Text(
          challenge.name,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          challenge.difficulty.toUpperCase(),
          style: AppTypography.body.copyWith(
            fontSize: 12,
            color: difficultyColor,
          ),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
        onTap:
            () => Navigator.pop(context, {
              'id': challenge.id,
              'name': challenge.name,
              'type': 'challenge',
            }),
      ),
    );
  }

  Widget _buildMedalCard(Medal medal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              medal.imageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      medal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stack) => const Icon(
                            LucideIcons.trophy,
                            color: Colors.amber,
                            size: 24,
                          ),
                    ),
                  )
                  : const Icon(
                    LucideIcons.trophy,
                    color: Colors.amber,
                    size: 24,
                  ),
        ),
        title: Text(
          medal.name,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
        onTap:
            () => Navigator.pop(context, {
              'id': medal.id,
              'name': medal.name,
              'type': 'medal',
            }),
      ),
    );
  }
}
