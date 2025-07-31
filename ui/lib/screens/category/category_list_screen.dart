import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../product/product_list_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoriesData = await _apiService.getCategories();
      setState(() {
        _categories = categoriesData.map<Category>((json) => Category.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCategories() async {
    await _loadCategories();
  }

  void _navigateToProductList(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(categoryId: category.id),
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1200) {
      return 5; // Desktop/large tablets
    } else if (screenWidth >= 900) {
      return 4; // Tablets
    } else if (screenWidth >= 600) {
      return 3; // Small tablets/large phones
    } else if (screenWidth >= 400) {
      return 2; // Standard phones
    } else {
      return 1; // Small phones
    }
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth >= 1200) {
      return 0.75; // Taller cards for desktop
    } else if (screenWidth >= 900) {
      return 0.72; // Tablets
    } else if (screenWidth >= 600) {
      return 0.7; // Small tablets
    } else if (screenWidth >= 400) {
      return 0.68; // Phones
    } else {
      return 0.65; // Small phones
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategories,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshCategories,
                  child: _categories.isEmpty
                      ? const Center(
                          child: Text('No categories found'),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = constraints.maxWidth;
                            final crossAxisCount = _getCrossAxisCount(screenWidth);
                            final childAspectRatio = _getChildAspectRatio(screenWidth);
                            
                            return GridView.builder(
                              padding: EdgeInsets.all(
                                screenWidth >= 600 ? 24 : 16,
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: screenWidth >= 600 ? 20 : 12,
                                mainAxisSpacing: screenWidth >= 600 ? 20 : 12,
                              ),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return _buildCategoryCard(category);
                              },
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return SizedBox(
      height: 290,
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToProductList(category),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: category.image != null && category.image!.isNotEmpty
                      ? Image.network(
                          category.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.category,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.category,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),
              ),
              // Category Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Name
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Description
                      if (category.description != null && category.description!.isNotEmpty)
                        Text(
                          category.description!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}