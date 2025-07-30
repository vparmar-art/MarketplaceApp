import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';
import 'order_success_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final Product product;

  const CreateOrderScreen({super.key, required this.product});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  int _quantity = 1;
  String _shippingAddress = '';
  String _city = '';
  String _state = '';
  String _zipCode = '';
  String _country = '';
  String _paymentMethod = 'Credit Card';
  bool _isLoading = false;
  String? _errorMessage;

  double get _totalPrice => widget.product.price * _quantity;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userProfile != null) {
      setState(() {
        _shippingAddress = authService.userProfile!['address'] ?? '';
        _city = authService.userProfile!['city'] ?? '';
        _state = authService.userProfile!['state'] ?? '';
        _zipCode = authService.userProfile!['zip_code'] ?? '';
        _country = authService.userProfile!['country'] ?? '';
      });
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Create order items
      final orderItem = OrderItem(
        id: 0, // Will be assigned by backend
        product: widget.product,
        quantity: _quantity,
        price: widget.product.price,
      );

      // Create order
      final order = Order(
        id: 0, // Will be assigned by backend
        orderNumber: '', // Will be assigned by backend
        buyer: User.fromJson(authService.currentUser!),
        status: 'Pending', // Initial status
        items: [orderItem],
        totalAmount: _totalPrice,
        shippingAddress: _shippingAddress,
        shippingCity: _city,
        shippingState: _state,
        shippingCountry: _country,
        shippingZipCode: _zipCode,
        paymentMethod: _paymentMethod,
        paymentStatus: 'Pending', // Initial status
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        documents: [],
      );

      // Submit order to API
      final createdOrder = await _apiService.createOrder(order.toJson());
      
      if (!mounted) return;
      
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(order: Order.fromJson(createdOrder)),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create order: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Summary
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            if (widget.product.images.isNotEmpty)
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.network(
                                  widget.product.images.first.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            const SizedBox(width: 16),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Price: \$${widget.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity Selector
                                  Row(
                                    children: [
                                      const Text('Quantity:'),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: _quantity > 1
                                            ? () {
                                                setState(() {
                                                  _quantity--;
                                                });
                                              }
                                            : null,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_quantity',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: _quantity < widget.product.quantity
                                            ? () {
                                                setState(() {
                                                  _quantity++;
                                                });
                                              }
                                            : null,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Shipping Information
                    const Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      initialValue: _shippingAddress,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _shippingAddress = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _city,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your city';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _city = value!;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _state,
                            decoration: const InputDecoration(
                              labelText: 'State/Province',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your state';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _state = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _zipCode,
                            decoration: const InputDecoration(
                              labelText: 'ZIP/Postal Code',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your ZIP code';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _zipCode = value!;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _country,
                            decoration: const InputDecoration(
                              labelText: 'Country',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your country';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _country = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                        DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                        DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Order Summary
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text('\$${(widget.product.price * _quantity).toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shipping:'),
                              Text('\$0.00'),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '\$${_totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    if (_errorMessage != null) ...[  
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: AppTheme.errorColor.withOpacity(0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.errorColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppTheme.errorColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitOrder,
                        child: const Text(
                          'Place Order',
                          style: TextStyle(fontSize: 16),
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