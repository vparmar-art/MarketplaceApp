import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';
import '../../widgets/review_card.dart';
import '../order/create_order_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewError = null;
    });

    try {
      final reviewsData = await _apiService.getProductReviews(widget.product.id);
      setState(() {
        _reviews = reviewsData.map((json) => Review.fromJson(json)).toList();
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _reviewError = 'Failed to load reviews';
        _isLoadingReviews = false;
      });
    }
  }

  void _navigateToCreateOrder() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place an order')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(product: widget.product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Carousel
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: widget.product.image.isNotEmpty
                  ? Image.network(
                      widget.product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.product.averageRating != null) ...[  
                        RatingBarIndicator(
                          rating: widget.product.averageRating!,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: AppTheme.accentColor,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.product.averageRating!.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ] else
                        const Text(
                          'No ratings yet',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${widget.product.category.name}',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seller: ${widget.product.seller?.username ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available: ${widget.product.quantity} in stock',
                    style: TextStyle(
                      color: widget.product.quantity > 0
                          ? AppTheme.primaryColor
                          : AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.textSecondaryColor,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Description'),
                      Tab(text: 'Specifications'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                  
                  // Tab Content
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Description Tab
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(widget.product.description),
                          ),
                        ),
                        
                        // Specifications Tab
                        widget.product.specifications.isEmpty
                            ? const Center(child: Text('No specifications available'))
                            : ListView.builder(
                                itemCount: widget.product.specifications.length,
                                itemBuilder: (context, index) {
                                  final spec = widget.product.specifications[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            spec.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(spec.value),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        
                        // Reviews Tab
                        _isLoadingReviews
                            ? const Center(child: CircularProgressIndicator())
                            : _reviewError != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _reviewError!,
                                          style: const TextStyle(color: AppTheme.errorColor),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _loadReviews,
                                          child: const Text('Try Again'),
                                        ),
                                      ],
                                    ),
                                  )
                                : _reviews.isEmpty
                                    ? const Center(child: Text('No reviews yet'))
                                    : ListView.builder(
                                        itemCount: _reviews.length,
                                        itemBuilder: (context, index) {
                                          return ReviewCard(review: _reviews[index]);
                                        },
                                      ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.quantity > 0 ? _navigateToCreateOrder : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}