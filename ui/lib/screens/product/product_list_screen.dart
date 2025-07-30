import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int? categoryId;
  final String? searchQuery;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.searchQuery,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMoreProducts = true;
  String? _errorMessage;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreProducts) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final response = await _apiService.getProducts(
        page: _currentPage,
        search: widget.searchQuery,
        categoryId: widget.categoryId,
      );

      setState(() {
        _products.clear();
        
        // Handle both paginated and non-paginated responses
        List<dynamic> productsList;
        if (response is List) {
          // Non-paginated response (flat array)
          productsList = response;
          _hasMoreProducts = false; // No pagination
        } else if (response is Map<String, dynamic> && response.containsKey('results')) {
          // Paginated response
          productsList = response['results'] as List<dynamic>;
          _hasMoreProducts = response['next'] != null;
        } else {
          // Handle unexpected response format
          throw Exception('Unexpected API response format');
        }
        
        _products.addAll(productsList.map((json) => Product.fromJson(json)).toList());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMoreProducts) return;

    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final response = await _apiService.getProducts(
        page: _currentPage,
        search: widget.searchQuery,
        categoryId: widget.categoryId,
      );

      setState(() {
        // Handle both paginated and non-paginated responses
        List<dynamic> productsList;
        if (response is List) {
          // Non-paginated response (flat array)
          productsList = response;
          _hasMoreProducts = false; // No pagination
        } else if (response is Map<String, dynamic> && response.containsKey('results')) {
          // Paginated response
          productsList = response['results'] as List<dynamic>;
          _hasMoreProducts = response['next'] != null;
        } else {
          // Handle unexpected response format
          throw Exception('Unexpected API response format');
        }
        
        _products.addAll(productsList.map((json) => Product.fromJson(json)).toList());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    _currentPage = 1;
    await _loadProducts();
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    ).then((_) => _refreshProducts());
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
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: _errorMessage != null
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
                      onPressed: _loadProducts,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            : _products.isEmpty && !_isLoading
                ? const Center(
                    child: Text('No products found'),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final crossAxisCount = _getCrossAxisCount(screenWidth);
                      final childAspectRatio = _getChildAspectRatio(screenWidth);
                      
                      return GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(
                          screenWidth >= 600 ? 24 : 16,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: screenWidth >= 600 ? 20 : 12,
                          mainAxisSpacing: screenWidth >= 600 ? 20 : 12,
                        ),
                        itemCount: _products.length + (_isLoading && _hasMoreProducts ? crossAxisCount : 0),
                        itemBuilder: (context, index) {
                          if (index >= _products.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final product = _products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => _navigateToProductDetail(product),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}