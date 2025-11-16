import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:async';
import 'app_theme.dart';
import 'ui_tokens.dart';
import 'widgets/sales_banner_carousel.dart';
import 'widgets/category_section.dart';
import 'widgets/modern_search_bar.dart';
import 'widgets/modern_product_card.dart';
import 'widgets/shimmer_loader.dart';
import 'widgets/bottom_nav_bar.dart';

// Conditional import for web-only JavaScript interop
import 'razorpay_web.dart' if (dart.library.io) 'razorpay_stub.dart' as razorpay_js;


class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int inStock;
  final String imageUrl; 

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.inStock,
    required this.imageUrl, 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      inStock: json['in_stock'] ?? 0,
      imageUrl: json['image_url'] ?? '', 
    );
  }
}

class ElectronicsProduct extends Product {
  final String brand;
  final String model;

  ElectronicsProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String category,
    required int inStock,
    required String imageUrl, 
    required this.brand,
    required this.model,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          category: category,
          inStock: inStock,
          imageUrl: imageUrl, 
        );

  factory ElectronicsProduct.fromJson(Map<String, dynamic> json) {
    return ElectronicsProduct(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      inStock: json['in_stock'] ?? 0,
      imageUrl: json['image_url'] ?? '', 
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
    );
  }
}

String? currentUserEmail;

void main() {
  runApp(const MyApp());
}

// AppColors and appTheme are now imported from app_theme.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adiana',
      theme: appTheme,
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/products': (context) => const ProductListPage(),
      },
    );
  }
}


class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
              child: Card(
              elevation: UITokens.elevationSmall,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UITokens.radiusSmall),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UITokens.radiusSmall),
                  color: AppColors.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(UITokens.radiusSmall),
                      ),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0, // Square aspect ratio for premium look
                            child: Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                ),
                                child: const Center(
                                  child: Icon(Icons.image_outlined, size: 40, color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ),
                          // Price Badge - Bottom Right
                          Positioned(
                            bottom: UITokens.spacing8,
                            right: UITokens.spacing8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: UITokens.spacing8,
                                vertical: UITokens.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(UITokens.radiusSmall),
                                boxShadow: UITokens.shadowSmall,
                              ),
                              child: Text(
                                '₹${widget.product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(UITokens.spacing12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: UITokens.spacing8),
                          
                          // Product Description
                          Text(
                            widget.product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: UITokens.spacing8),
                          
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UITokens.spacing8,
                              vertical: UITokens.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(UITokens.radiusSmall),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.product.category,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class ProductCatalog extends StatelessWidget {
  final List<Product> products;
  final void Function(Product)? onProductTap;

  const ProductCatalog({Key? key, required this.products, this.onProductTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(UITokens.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: UITokens.spacing16,
        mainAxisSpacing: UITokens.spacing16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 30)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: ModernProductCard(
                  product: products[index],
                  onTap: onProductTap != null ? () => onProductTap!(products[index]) : null,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse('${getBackendUrl()}/login'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: 'username=${Uri.encodeComponent(_emailController.text.trim())}&password=${Uri.encodeComponent(_passwordController.text)}',
        );
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          final token = jsonDecode(response.body);
          currentUserEmail = _emailController.text.trim();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          Navigator.pushReplacementNamed(context, '/products');
        } else {
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['detail'] ?? 'Login failed')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UITokens.spacing24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo/Title
                  Container(
                    padding: const EdgeInsets.all(UITokens.spacing32),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(UITokens.radiusMedium),
                            boxShadow: UITokens.shadowMedium,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: UITokens.spacing24),
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: UITokens.spacing8),
                        Text(
                          'Sign in to continue shopping',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Login Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UITokens.spacing24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email Field
                            Text(
                              'Email Address',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: UITokens.spacing8),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                hintText: 'Enter your email address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your email';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: UITokens.spacing20),
                            
                            // Password Field
                            Text(
                              'Password',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: UITokens.spacing8),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                hintText: 'Enter your password',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your password';
                                if (value.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: UITokens.spacing24),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.onPrimary,
                                        ),
                                      )
                                    : const Text('Sign In'),
                              ),
                            ),
                            const SizedBox(height: UITokens.spacing20),
                            
                            // Sign Up Link
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: "Don't have an account? ",
                                      ),
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse('${getBackendUrl()}/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          currentUserEmail = _emailController.text.trim();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful! Please log in.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['detail'] ?? 'Signup failed')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UITokens.spacing24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo/Title
                  Container(
                    padding: const EdgeInsets.all(UITokens.spacing32),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(UITokens.radiusMedium),
                            boxShadow: UITokens.shadowMedium,
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 40,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: UITokens.spacing24),
                        Text(
                          'Join Us Today',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: UITokens.spacing8),
                        Text(
                          'Create your account to start shopping',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Signup Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UITokens.spacing24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username Field
                            Text(
                              'Full Name',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: UITokens.spacing8),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                                hintText: 'Enter your full name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your name';
                                return null;
                              },
                            ),
                            const SizedBox(height: UITokens.spacing20),
                            
                            // Email Field
                            Text(
                              'Email Address',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: UITokens.spacing8),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                hintText: 'Enter your email address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your email';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: UITokens.spacing20),
                            
                            // Password Field
                            Text(
                              'Password',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: UITokens.spacing8),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                hintText: 'Create a strong password',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your password';
                                if (value.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: UITokens.spacing12),
                            
                            // Password Requirements
                            Container(
                              padding: const EdgeInsets.all(UITokens.spacing12),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(UITokens.radiusSmall),
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: AppColors.info),
                                  const SizedBox(width: UITokens.spacing8),
                                  Expanded(
                                    child: Text(
                                      'Password must be at least 6 characters long',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: UITokens.spacing24),
                            
                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signup,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.onPrimary,
                                        ),
                                      )
                                    : const Text('Create Account'),
                              ),
                            ),
                            const SizedBox(height: UITokens.spacing20),
                            
                            // Sign In Link
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: 'Already have an account? ',
                                      ),
                                      TextSpan(
                                        text: 'Sign In',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}


class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0; // For bottom navigation

  // Category definitions
  static const List<String> _categories = [
    'Electronics',
    'Clothing',
    'Groceries',
    'Books',
    'Sports',
    'Home & Garden',
    'Toys',
  ];

  // Map category names to display names
  static const Map<String, String> _categoryDisplayNames = {
    'Electronics': 'Electronics',
    'Clothing': 'Clothing',
    'Groceries': 'Groceries',
    'Books': 'Books',
    'Sports': 'Sports',
    'Home & Garden': 'Home & Garden',
    'Toys': 'Toys',
  };

  // Map category names to icons
  static const Map<String, IconData> _categoryIcons = {
    'Electronics': Icons.devices,
    'Clothing': Icons.checkroom,
    'Groceries': Icons.shopping_basket,
    'Books': Icons.menu_book,
    'Sports': Icons.sports_soccer,
    'Home & Garden': Icons.home,
    'Toys': Icons.toys,
  };

  // Group products by category
  Map<String, List<Product>> _groupProductsByCategory() {
    final Map<String, List<Product>> grouped = {};
    for (final product in _products) {
      final category = product.category.trim();
      // Normalize category name
      String normalizedCategory = category;
      for (final cat in _categories) {
        if (category.toLowerCase().contains(cat.toLowerCase()) ||
            cat.toLowerCase().contains(category.toLowerCase())) {
          normalizedCategory = cat;
          break;
        }
      }
      // If category doesn't match any predefined, use "Other"
      if (!_categories.contains(normalizedCategory)) {
        normalizedCategory = 'Other';
      }
      grouped.putIfAbsent(normalizedCategory, () => []).add(product);
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    if (_searchQuery.isEmpty) {
      _fetchProducts();
    } else {
      _searchProducts(_searchQuery);
    }
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('${getBackendUrl()}/products'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load products';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('${getBackendUrl()}/products/search?name=${Uri.encodeComponent(query)}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to search products';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  Widget _buildCategorizedView() {
    final groupedProducts = _groupProductsByCategory();
    final orderedCategories = _categories.where((cat) => groupedProducts.containsKey(cat)).toList();
    
    // Add "Other" category if it exists
    if (groupedProducts.containsKey('Other')) {
      orderedCategories.add('Other');
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: UITokens.spacing16),
      children: [
        // Sales Banner Carousel
        const Padding(
          padding: EdgeInsets.only(top: UITokens.spacing16),
          child: SalesBannerCarousel(),
        ),
        const SizedBox(height: UITokens.spacing24),
        
        // Category Sections
        if (orderedCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.all(UITokens.spacing24),
            child: Center(
              child: Text(
                'No products available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...orderedCategories.map((category) {
            return CategorySection(
              categoryName: _categoryDisplayNames[category] ?? category,
              products: groupedProducts[category] ?? [],
              onProductTap: _openProductDetail,
              icon: _categoryIcons[category] ?? Icons.category,
            );
          }).toList(),
      ],
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(UITokens.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: UITokens.spacing16,
        mainAxisSpacing: UITokens.spacing16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 30)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: ModernProductCard(
                  product: _products[index],
                  onTap: () => _openProductDetail(_products[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(UITokens.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: UITokens.spacing16,
        mainAxisSpacing: UITokens.spacing16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ProductCardShimmer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false, // Remove drawer icon
        iconTheme: const IconThemeData(color: AppColors.onSurface, size: 24),
        title: Row(
          children: [
            // App Logo with enhanced styling
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(UITokens.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: AppColors.onPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: UITokens.spacing12),
            Text(
              'Adiana',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            // Modern Search Bar
            SizedBox(
              width: 220,
              child: ModernSearchBar(
                controller: _searchController,
                hintText: 'Search products...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  if (value.isEmpty) {
                    _fetchProducts();
                  } else {
                    _searchProducts(value);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          // Cart Icon
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: AppColors.onSurface),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: const Text(
                      '0',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Wishlist Icon
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.favorite_border, color: AppColors.onSurface),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Results Header
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceVariant,
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Search results for "$_searchQuery"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_products.length} products found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          
          // Products Grid
          Expanded(
            child: _isLoading
                ? _buildShimmerLoader()
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Oops! Something went wrong',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _fetchProducts,
                              icon: Icon(Icons.refresh),
                              label: Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.onSurfaceVariant.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No products found',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty 
                                    ? 'Try adjusting your search terms'
                                    : 'Check back later for new products',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      _fetchProducts();
                                    },
                                    icon: Icon(Icons.clear),
                                    label: Text('Clear Search'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : _searchQuery.isNotEmpty
                            // Show search results in grid
                            ? _buildProductGrid()
                            // Show categorized products with banner
                            : _buildCategorizedView(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleBottomNavTap(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart_rounded),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag_rounded),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0: // Home
        // Already on home page, just reset to first tab
        if (Navigator.canPop(context)) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
        break;
      case 1: // Cart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        ).then((_) {
          // Reset to home when coming back
          setState(() => _currentIndex = 0);
        });
        break;
      case 2: // Wishlist
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WishlistScreen()),
        ).then((_) {
          // Reset to home when coming back
          setState(() => _currentIndex = 0);
        });
        break;
      case 3: // Orders
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrdersPage()),
        ).then((_) {
          // Reset to home when coming back
          setState(() => _currentIndex = 0);
        });
        break;
    }
  }
}

// Helper function for bottom navigation
void _handleBottomNav(BuildContext context, int index) {
  switch (index) {
    case 0: // Home
      Navigator.popUntil(context, (route) => route.isFirst);
      break;
    case 1: // Cart
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
      break;
    case 2: // Wishlist
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WishlistScreen()),
      );
      break;
    case 3: // Orders
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrdersPage()),
      );
      break;
  }
}


class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _inCart = false;
  bool _inWishlist = false;
  bool _loading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _checkCartAndWishlist();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _checkCartAndWishlist() async {
    setState(() { _loading = true; });
    try {
      final cartResp = await http.get(Uri.parse('${getBackendUrl()}/cart?user_email=$currentUserEmail'));
      final wishlistResp = await http.get(Uri.parse('${getBackendUrl()}/wishlist?user_email=$currentUserEmail'));
      if (cartResp.statusCode == 200 && wishlistResp.statusCode == 200) {
        final cartData = jsonDecode(cartResp.body);
        final wishlistData = jsonDecode(wishlistResp.body);
        final cartItems = (cartData['items'] as List);
        final wishlistItems = (wishlistData['products'] as List);
        final inCart = cartItems.any((item) => item['product_id'].toString() == widget.product.id.toString());
        final inWishlist = wishlistItems.map((e) => e.toString()).contains(widget.product.id.toString());
        setState(() { _inCart = inCart; _inWishlist = inWishlist; _loading = false; });
      } else {
        setState(() { _loading = false; });
      }
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _toggleCart() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    if (_inCart) {
      final resp = await http.delete(
        Uri.parse('${getBackendUrl()}/cart/remove'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inCart = false; });
      }
    } else {
      final resp = await http.post(
        Uri.parse('${getBackendUrl()}/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id, 'quantity': _quantity}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inCart = true; });
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    if (_inWishlist) {
      final resp = await http.delete(
        Uri.parse('${getBackendUrl()}/wishlist/remove'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inWishlist = false; });
      }
    } else {
      final resp = await http.post(
        Uri.parse('${getBackendUrl()}/wishlist/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inWishlist = true; });
      }
    }
  }

  Future<void> _handleBuyNow() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    if (_quantity > widget.product.inStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${widget.product.inStock} items available in stock'))
      );
      return;
    }
    // Navigate to checkout page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          product: widget.product,
          quantity: _quantity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading product details...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 350,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.onSurface,
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    tooltip: _inWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                    onPressed: _toggleWishlist,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _inWishlist 
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: _inWishlist 
                          ? Border.all(color: AppColors.error.withOpacity(0.3))
                          : null,
                      ),
                      child: Icon(
                        _inWishlist ? Icons.favorite : Icons.favorite_border,
                        color: _inWishlist ? AppColors.error : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                          ),
                          child: const Center(
                            child: Icon(Icons.image_outlined, size: 64, color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                    // Premium gradient overlay that fades to background color
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withOpacity(0.3),
                            AppColors.background.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    // Premium price badge
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Description'),
                  Tab(text: 'Details'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                children: [
                  // Description Tab
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      product.category,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: product.inStock > 10 
                                        ? AppColors.success.withOpacity(0.1)
                                        : AppColors.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 14,
                                          color: product.inStock > 10 
                                            ? AppColors.success
                                            : AppColors.warning,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'In stock: ${product.inStock}',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: product.inStock > 10 
                                              ? AppColors.success
                                              : AppColors.warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                product.description,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Quantity Selector
                      Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantity',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: AppColors.primary),
                                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Text(
                                        '$_quantity',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: AppColors.primary),
                                      onPressed: () => setState(() => _quantity++),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Features
                      Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Features & Benefits',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.local_shipping_outlined,
                                AppColors.accent,
                                'Free delivery on orders over ₹499',
                                'Standard delivery in 3-5 business days',
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                Icons.assignment_turned_in_outlined,
                                AppColors.success,
                                '7-day replacement policy',
                                'Easy returns if the item is damaged or defective',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                  // Details Tab
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Details',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildDetailItem('Material', 'Premium quality materials'),
                              _buildDetailItem('Warranty', '1 year limited warranty'),
                              _buildDetailItem('Care', 'Refer to instructions included in the package'),
                              _buildDetailItem('Origin', 'Made in India'),
                              _buildDetailItem('Weight', 'Lightweight and portable'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Reviews Tab
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Reviews',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildReviewItem('Sarah M.', 'Great value for money!', 'Loved the quality and delivery was quick.'),
                              _buildReviewItem('John D.', 'As described', 'Product matches the description and images.'),
                              _buildReviewItem('Emma L.', 'Excellent quality', 'Very satisfied with my purchase.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleWishlist,
                        icon: Icon(
                          _inWishlist ? Icons.favorite : Icons.favorite_border,
                          color: _inWishlist ? AppColors.error : AppColors.onSurfaceVariant,
                        ),
                        label: Text(
                          _inWishlist ? 'Wishlisted' : 'Wishlist',
                          style: TextStyle(
                            color: _inWishlist ? AppColors.error : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _inWishlist ? AppColors.error : AppColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _toggleCart,
                        icon: Icon(
                          _inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                          color: Colors.white,
                        ),
                        label: Text(
                          _inCart ? 'In Cart' : 'Add to Cart',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _inCart ? AppColors.success : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: (_inCart ? AppColors.success : AppColors.primary).withOpacity(0.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Buy Now Button - Full Width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBuyNow(),
                    icon: const Icon(Icons.shopping_bag, color: Colors.white),
                    label: const Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.accent.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Cart and Wishlist Screens ---
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _fetchCart() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      setState(() { _error = 'Please log in first'; _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.get(Uri.parse('${getBackendUrl()}/cart/detailed?user_email=$currentUserEmail'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { _items = data['items']; _loading = false; });
      } else {
        setState(() { _error = 'Failed to load cart'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.surfaceVariant,
            AppColors.accent.withOpacity(0.05),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Your Cart',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.onSurface),
        ),
        body: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your cart...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchCart,
                          icon: Icon(Icons.refresh),
                          label: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Your cart is empty',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add some products to get started',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.shopping_bag_outlined),
                              label: Text('Start Shopping'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          final product = item['product'];
                          return Card(
                            elevation: 8,
                            shadowColor: AppColors.accent.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      product['image_url'] ?? '',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'] ?? '',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Qty: ${item['quantity']}',
                                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: AppColors.accent,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '₹${(product['price'] ?? 0).toStringAsFixed(0)}',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: AppColors.accent,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.delete_outline, color: AppColors.error),
                                    ),
                                    onPressed: () async {
                                      await http.delete(
                                        Uri.parse('${getBackendUrl()}/cart/remove'),
                                        headers: {'Content-Type': 'application/json'},
                                        body: jsonEncode({'user_email': currentUserEmail, 'product_id': product['_id']}),
                                      );
                                      _fetchCart();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
        bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<http.Response>(
                      future: http.get(Uri.parse('${getBackendUrl()}/cart/total?user_email=$currentUserEmail')),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text(
                            'Total: ...',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          );
                        }
                        try {
                          final json = jsonDecode(snapshot.data!.body);
                          return Text(
                            'Total: ₹${(json['total'] ?? 0).toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          );
                        } catch (_) {
                          return Text(
                            'Total: --',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          );
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: _items.isEmpty ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartCheckoutPage(cartItems: _items),
                          ),
                        );
                      },
                      icon: Icon(Icons.payment),
                      label: Text('Checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: AppColors.accent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          AppBottomNavBar(
            currentIndex: 1, // Cart
            onTap: (index) => _handleBottomNav(context, index),
          ),
        ],
      ),
      ),
    );
  }
}

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<dynamic> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _fetchWishlist() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      setState(() { _error = 'Please log in first'; _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.get(Uri.parse('${getBackendUrl()}/wishlist/detailed?user_email=$currentUserEmail'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { _products = data['products']; _loading = false; });
      } else {
        setState(() { _error = 'Failed to load wishlist'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.surfaceVariant,
            AppColors.error.withOpacity(0.05),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Your Wishlist',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.onSurface),
        ),
        body: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your wishlist...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchWishlist,
                          icon: Icon(Icons.refresh),
                          label: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_outline,
                                size: 64,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Your wishlist is empty',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add products you love to your wishlist',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.shopping_bag_outlined),
                              label: Text('Start Shopping'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, i) {
                          final product = _products[i];
                          return Card(
                            elevation: 8,
                            shadowColor: AppColors.error.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: Product(
                                        id: product['_id'] ?? '',
                                        name: product['name'] ?? '',
                                        description: product['description'] ?? '',
                                        price: (product['price'] ?? 0).toDouble(),
                                        category: product['category'] ?? '',
                                        inStock: product['in_stock'] ?? 0,
                                        imageUrl: product['image_url'] ?? '',
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: AspectRatio(
                                          aspectRatio: 1.2,
                                          child: Image.network(
                                            product['image_url'] ?? '',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.grey.shade100, Colors.grey.shade200],
                                                ),
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.favorite, color: AppColors.error, size: 20),
                                            onPressed: () async {
                                              await http.delete(
                                                Uri.parse('${getBackendUrl()}/wishlist/remove'),
                                                headers: {'Content-Type': 'application/json'},
                                                body: jsonEncode({'user_email': currentUserEmail, 'product_id': product['_id']}),
                                              );
                                              _fetchWishlist();
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '₹${(product['price'] ?? 0).toStringAsFixed(0)}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            product['category'] ?? '',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 2, // Wishlist
          onTap: (index) => _handleBottomNav(context, index),
        ),
      ),
    );
  }
}

// ========== CHECKOUT PAGE ==========
class CheckoutPage extends StatefulWidget {
  final Product product;
  final int quantity;
  
  const CheckoutPage({Key? key, required this.product, required this.quantity}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isProcessing = false;

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess({
    required BuildContext context,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String orderId,
  }) async {
    try {
      final verifyResponse = await http.post(
        Uri.parse('${getBackendUrl()}/orders/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'order_id': orderId,
        }),
      );

      if (verifyResponse.statusCode == 200 && mounted) {
        setState(() => _isProcessing = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(orderId: orderId),
          ),
        );
      } else {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment verification failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openRazorpayCheckout({
    required BuildContext context,
    required String keyId,
    required String orderId,
    required double amount,
    required String orderIdForVerification,
  }) async {
    if (!kIsWeb) return;

    try {
      // Convert amount to paise (multiply by 100)
      final amountInPaise = (amount * 100).toInt();

      // Create Razorpay options
      final options = razorpay_js.RazorpayJS.createOptions({
        'key': keyId,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'Adiana',
        'description': 'Order Payment',
        'order_id': orderId,
        'handler': razorpay_js.RazorpayJS.allowInterop((response) {
          // Payment successful - handle asynchronously
          _handlePaymentSuccess(
            context: context,
            razorpayOrderId: response['razorpay_order_id']?.toString() ?? '',
            razorpayPaymentId: response['razorpay_payment_id']?.toString() ?? '',
            razorpaySignature: response['razorpay_signature']?.toString() ?? '',
            orderId: orderIdForVerification,
          );
        }),
        'prefill': {
          'name': _nameController.text,
          'email': currentUserEmail ?? '',
          'contact': _phoneController.text,
        },
        'theme': {
          'color': '#4A90E2',
        },
        'modal': {
          'ondismiss': razorpay_js.RazorpayJS.allowInterop(() {
            // User closed the payment dialog
            if (mounted) {
              setState(() => _isProcessing = false);
            }
          }),
        },
      });

      // Wait a bit for Razorpay script to load if needed
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get Razorpay from window
      final razorpay = razorpay_js.RazorpayJS.getRazorpayFromContext();
      if (razorpay == null) {
        throw Exception('Razorpay script not loaded. Please refresh the page.');
      }

      // Create and open Razorpay instance
      final razorpayInstance = razorpay_js.RazorpayJS.createRazorpayInstance(razorpay, [options]);
      razorpayInstance.callMethod('open');
      
      // Note: _isProcessing will be set to false in the handler or on dismiss
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment() async {
    print('_processPayment called'); // Debug: Check if method is being called
    
    // Check if user is logged in
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final totalAmount = widget.product.price * widget.quantity;

      // Step 1: Create order in database
      final orderResponse = await http.post(
        Uri.parse('${getBackendUrl()}/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_email': currentUserEmail,
          'items': [
            {
              'product_id': widget.product.id,
              'product_name': widget.product.name,
              'quantity': widget.quantity,
              'price': widget.product.price,
              'image_url': widget.product.imageUrl,
            }
          ],
          'shipping_address': {
            'full_name': _nameController.text,
            'phone': _phoneController.text,
            'address_line1': _address1Controller.text,
            'address_line2': _address2Controller.text.isEmpty ? null : _address2Controller.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'postal_code': _postalCodeController.text,
            'country': 'India',
          },
          'total_amount': totalAmount,
          'payment_method': 'razorpay',
        }),
      );

      if (orderResponse.statusCode != 200) {
        throw Exception('Failed to create order');
      }

      final orderData = jsonDecode(orderResponse.body);
      final orderId = orderData['order']['order_id'];

      // Step 2: Create Razorpay order
      final razorpayOrderResponse = await http.post(
        Uri.parse('${getBackendUrl()}/orders/create-razorpay-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': totalAmount,
          'currency': 'INR',
          'receipt': orderId,
          'user_email': currentUserEmail,
        }),
      );

      if (razorpayOrderResponse.statusCode != 200) {
        throw Exception('Failed to create payment order');
      }

      final razorpayData = jsonDecode(razorpayOrderResponse.body);
      final razorpayOrderId = razorpayData['order_id'];
      final razorpayKeyId = razorpayData['key_id'];

      // Step 3: Open Razorpay Checkout
      if (kIsWeb) {
        // Use Razorpay Checkout for web
        if (razorpayKeyId == 'demo_key_id') {
          // Demo mode - simulate payment
          await Future.delayed(const Duration(seconds: 2));
          final verifyResponse = await http.post(
            Uri.parse('${getBackendUrl()}/orders/verify-payment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'razorpay_order_id': razorpayOrderId,
              'razorpay_payment_id': 'pay_demo_${DateTime.now().millisecondsSinceEpoch}',
              'razorpay_signature': 'demo_signature_${DateTime.now().millisecondsSinceEpoch}',
              'order_id': orderId,
            }),
          );
          if (verifyResponse.statusCode == 200 && mounted) {
            setState(() => _isProcessing = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessPage(orderId: orderId),
              ),
            );
          }
        } else {
          // Real Razorpay integration
          await _openRazorpayCheckout(
            context: context,
            keyId: razorpayKeyId,
            orderId: razorpayOrderId,
            amount: totalAmount,
            orderIdForVerification: orderId,
          );
        }
      } else {
        // For mobile, use Razorpay Flutter SDK
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile: Install Razorpay Flutter SDK for payment integration'),
          ),
        );
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
        print('Payment processing error: $e'); // Debug output
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.product.price * widget.quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.image),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: ${widget.quantity}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(widget.product.price * widget.quantity).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Shipping Address Form
              Text(
                'Shipping Address',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter phone number';
                  if (value!.length < 10) return 'Please enter valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter address' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter city' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter state' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter postal code';
                  if (value!.length < 6) return 'Please enter valid postal code';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Proceed to Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Proceed to Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
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

// ========== CART CHECKOUT PAGE ==========
class CartCheckoutPage extends StatefulWidget {
  final List<dynamic> cartItems;
  
  const CartCheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isProcessing = false;

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      final product = item['product'];
      final quantity = item['quantity'];
      total += (product['price'] ?? 0.0) * (quantity ?? 1);
    }
    return total;
  }

  Future<void> _handlePaymentSuccess({
    required BuildContext context,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String orderId,
  }) async {
    try {
      final verifyResponse = await http.post(
        Uri.parse('${getBackendUrl()}/orders/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'order_id': orderId,
        }),
      );

      if (verifyResponse.statusCode == 200 && mounted) {
        setState(() => _isProcessing = false);
        // Clear cart after successful payment
        try {
          await http.post(
            Uri.parse('${getBackendUrl()}/cart/clear'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_email': currentUserEmail}),
          );
        } catch (_) {}
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(orderId: orderId),
          ),
        );
      } else {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment verification failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openRazorpayCheckout({
    required BuildContext context,
    required String keyId,
    required String orderId,
    required double amount,
    required String orderIdForVerification,
  }) async {
    if (!kIsWeb) return;

    try {
      final amountInPaise = (amount * 100).toInt();
      final options = razorpay_js.RazorpayJS.createOptions({
        'key': keyId,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'Adiana',
        'description': 'Cart Order Payment',
        'order_id': orderId,
        'handler': razorpay_js.RazorpayJS.allowInterop((response) {
          _handlePaymentSuccess(
            context: context,
            razorpayOrderId: response['razorpay_order_id']?.toString() ?? '',
            razorpayPaymentId: response['razorpay_payment_id']?.toString() ?? '',
            razorpaySignature: response['razorpay_signature']?.toString() ?? '',
            orderId: orderIdForVerification,
          );
        }),
        'prefill': {
          'name': _nameController.text,
          'email': currentUserEmail ?? '',
          'contact': _phoneController.text,
        },
        'theme': {
          'color': '#4A90E2',
        },
        'modal': {
          'ondismiss': razorpay_js.RazorpayJS.allowInterop(() {
            if (mounted) {
              setState(() => _isProcessing = false);
            }
          }),
        },
      });

      await Future.delayed(const Duration(milliseconds: 500));
      final razorpay = razorpay_js.RazorpayJS.getRazorpayFromContext();
      if (razorpay == null) {
        throw Exception('Razorpay script not loaded. Please refresh the page.');
      }
      final razorpayInstance = razorpay_js.RazorpayJS.createRazorpayInstance(razorpay, [options]);
      razorpayInstance.callMethod('open');
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final totalAmount = _calculateTotal();

      // Prepare order items from cart
      final orderItems = widget.cartItems.map((item) {
        final product = item['product'];
        return {
          'product_id': product['_id'],
          'product_name': product['name'],
          'quantity': item['quantity'],
          'price': product['price'],
          'image_url': product['image_url'],
        };
      }).toList();

      // Step 1: Create order in database
      final orderResponse = await http.post(
        Uri.parse('${getBackendUrl()}/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_email': currentUserEmail,
          'items': orderItems,
          'shipping_address': {
            'full_name': _nameController.text,
            'phone': _phoneController.text,
            'address_line1': _address1Controller.text,
            'address_line2': _address2Controller.text.isEmpty ? null : _address2Controller.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'postal_code': _postalCodeController.text,
            'country': 'India',
          },
          'total_amount': totalAmount,
          'payment_method': 'razorpay',
        }),
      );

      if (orderResponse.statusCode != 200) {
        throw Exception('Failed to create order');
      }

      final orderData = jsonDecode(orderResponse.body);
      final orderId = orderData['order']['order_id'];

      // Step 2: Create Razorpay order
      final razorpayOrderResponse = await http.post(
        Uri.parse('${getBackendUrl()}/orders/create-razorpay-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': totalAmount,
          'currency': 'INR',
          'receipt': orderId,
          'user_email': currentUserEmail,
        }),
      );

      if (razorpayOrderResponse.statusCode != 200) {
        throw Exception('Failed to create payment order');
      }

      final razorpayData = jsonDecode(razorpayOrderResponse.body);
      final razorpayOrderId = razorpayData['order_id'];
      final razorpayKeyId = razorpayData['key_id'];

      // Step 3: Open Razorpay Checkout
      if (kIsWeb) {
        if (razorpayKeyId == 'demo_key_id') {
          await Future.delayed(const Duration(seconds: 2));
          final verifyResponse = await http.post(
            Uri.parse('${getBackendUrl()}/orders/verify-payment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'razorpay_order_id': razorpayOrderId,
              'razorpay_payment_id': 'pay_demo_${DateTime.now().millisecondsSinceEpoch}',
              'razorpay_signature': 'demo_signature_${DateTime.now().millisecondsSinceEpoch}',
              'order_id': orderId,
            }),
          );
          if (verifyResponse.statusCode == 200 && mounted) {
            setState(() => _isProcessing = false);
            try {
              await http.post(
                Uri.parse('${getBackendUrl()}/cart/clear'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'user_email': currentUserEmail}),
              );
            } catch (_) {}
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessPage(orderId: orderId),
              ),
            );
          }
        } else {
          await _openRazorpayCheckout(
            context: context,
            keyId: razorpayKeyId,
            orderId: razorpayOrderId,
            amount: totalAmount,
            orderIdForVerification: orderId,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile: Install Razorpay Flutter SDK for payment integration'),
          ),
        );
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotal();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UITokens.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UITokens.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: UITokens.spacing16),
                      ...widget.cartItems.map((item) {
                        final product = item['product'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: UITokens.spacing12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(UITokens.radiusSmall),
                                child: Image.network(
                                  product['image_url'] ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: AppColors.surfaceVariant,
                                    child: const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: UITokens.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? '',
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty: ${item['quantity']}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${((product['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UITokens.spacing24),
              
              // Shipping Address Form
              Text(
                'Shipping Address',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: UITokens.spacing16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: UITokens.spacing16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter phone number';
                  if (value!.length < 10) return 'Please enter valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: UITokens.spacing16),
              
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1 *',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter address' : null,
              ),
              const SizedBox(height: UITokens.spacing16),
              
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (Optional)',
                ),
              ),
              const SizedBox(height: UITokens.spacing16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City *',
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter city' : null,
                    ),
                  ),
                  const SizedBox(width: UITokens.spacing16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State *',
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter state' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UITokens.spacing16),
              
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code *',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter postal code';
                  if (value!.length < 6) return 'Please enter valid postal code';
                  return null;
                },
              ),
              const SizedBox(height: UITokens.spacing32),
              
              // Proceed to Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: UITokens.spacing16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UITokens.radiusSmall)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Proceed to Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
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

// ========== PAYMENT SUCCESS PAGE ==========
class PaymentSuccessPage extends StatelessWidget {
  final String orderId;
  
  const PaymentSuccessPage({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed successfully',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: $orderId',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== ORDERS PAGE ==========
class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${getBackendUrl()}/orders?user_email=$currentUserEmail'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _orders = data['orders'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start shopping to see your orders here',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ExpansionTile(
                              title: Text(
                                'Order #${order['order_id']}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${(order['total_amount'] ?? 0).toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status'] ?? 'pending').withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order['status'] ?? 'pending',
                                      style: TextStyle(
                                        color: _getStatusColor(order['status'] ?? 'pending'),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Items',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...((order['items'] as List?) ?? []).map((item) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                item['image_url'] ?? '',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: AppColors.surfaceVariant,
                                                  child: const Icon(Icons.image, size: 24),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['product_name'] ?? '',
                                                    style: Theme.of(context).textTheme.bodyMedium,
                                                  ),
                                                  Text(
                                                    'Qty: ${item['quantity']} × ₹${(item['price'] ?? 0).toStringAsFixed(2)}',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: AppColors.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                      const Divider(),
                                      if (order['shipping_address'] != null) ...[
                                        Text(
                                          'Shipping Address',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${order['shipping_address']['full_name']}\n'
                                          '${order['shipping_address']['address_line1']}\n'
                                          '${order['shipping_address']['address_line2'] != null ? "${order['shipping_address']['address_line2']}\n" : ""}'
                                          '${order['shipping_address']['city']}, ${order['shipping_address']['state']} ${order['shipping_address']['postal_code']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Text(
                                        'Order Date: ${DateTime.parse(order['created_at'] ?? DateTime.now().toIso8601String()).toString().substring(0, 16)}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3, // Orders
        onTap: (index) => _handleBottomNav(context, index),
      ),
    );
  }
}

