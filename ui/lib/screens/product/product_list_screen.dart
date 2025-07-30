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
        final results = response['results'] as List<dynamic>;
        _products.addAll(results.map((json) => Product.fromJson(json)).toList());
        _hasMoreProducts = response['next'] != null;
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
        final results = response['results'] as List<dynamic>;
        _products.addAll(results.map((json) => Product.fromJson(json)).toList());
        _hasMoreProducts = response['next'] != null;
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
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _products.length + (_isLoading && _hasMoreProducts ? 2 : 0),
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
                  ),
      ),
    );
  }
}