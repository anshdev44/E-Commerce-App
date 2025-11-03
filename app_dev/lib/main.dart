import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:async';


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

// Premium E-commerce Color Palette
class AppColors {
  static const Color primary = Color(0xFF3A5A95); // Deep Sophisticated Indigo
  static const Color secondary = Color(0xFF007AFF); // Vibrant Tech Blue
  static const Color accent = Color(0xFF20B2AA); // Soft Teal
  static const Color background = Color(0xFFFAFBFC); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Very Light Gray
  static const Color onSurface = Color(0xFF1A1A1A); // Deep Black
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Medium Gray
  static const Color error = Color(0xFFEF4444); // Modern Red
  static const Color success = Color(0xFF10B981); // Modern Green
  static const Color warning = Color(0xFFF59E0B); // Modern Orange
  static const Color info = Color(0xFF3B82F6); // Modern Blue
  static const Color border = Color(0xFFE5E7EB); // Light Border
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.background,
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  iconTheme: IconThemeData(color: AppColors.onSurface),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.05),
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: AppColors.onSurface),
    titleTextStyle: TextStyle(
      color: AppColors.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.onSurface),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
    bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.onSurface),
    bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.onSurface),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurface),
  ),
);

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
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image with Premium Price Badge
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                          // Premium Price Badge - Bottom Right
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '₹${widget.product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Product Info - Clean Layout
                    Padding(
                      padding: const EdgeInsets.all(12),
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
                          const SizedBox(height: 6),
                          
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
                          const SizedBox(height: 8),
                          
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
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
                                fontSize: 11,
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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: onProductTap != null ? () => onProductTap!(products[index]) : null,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo/Title
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue shopping',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Login Form Card
                    Card(
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surface,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email Field
                              Text(
                                'Email Address',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                                  hintText: 'Enter your email address',
                                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
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
                              const SizedBox(height: 20),
                              
                              // Password Field
                              Text(
                                'Password',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter your password';
                                  if (value.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              
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
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Sign In'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
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
                                          style: TextStyle(color: AppColors.onSurfaceVariant),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo/Title
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.accent, AppColors.primary],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Join Us Today',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your account to start shopping',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Signup Form Card
                    Card(
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surface,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username Field
                              Text(
                                'Full Name',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                                  hintText: 'Enter your full name',
                                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter your name';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Email Field
                              Text(
                                'Email Address',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                                  hintText: 'Enter your email address',
                                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
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
                              const SizedBox(height: 20),
                              
                              // Password Field
                              Text(
                                'Password',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                                  hintText: 'Create a strong password',
                                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter your password';
                                  if (value.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              
                              // Password Requirements
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.info.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 14, color: AppColors.info),
                                    const SizedBox(width: 6),
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
                              const SizedBox(height: 24),
                              
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
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Create Account'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
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
                                          style: TextStyle(color: AppColors.onSurfaceVariant),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        title: Row(
          children: [
            // App Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Adiana',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            // Search Bar
            Container(
              width: 200,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
                ),
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
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person_outline,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to Adiana',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover amazing products',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Menu Items
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/products');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Your Cart',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite_outline,
                    title: 'Your Wishlist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistScreen()),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildDrawerItem(
                    icon: Icons.login_outlined,
                    title: 'Sign In',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_add_outlined,
                    title: 'Sign Up',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Loading amazing products...',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
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
                        : ProductCatalog(
                            products: _products,
                            onProductTap: _openProductDetail,
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: AppColors.primary.withOpacity(0.1),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
            child: Row(
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
        bottomNavigationBar: _items.isEmpty
            ? null
            : Container(
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
                        onPressed: () {},
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
      ),
    );
  }
}
