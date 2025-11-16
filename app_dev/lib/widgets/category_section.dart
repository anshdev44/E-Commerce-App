import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../ui_tokens.dart';
import '../main.dart';
import 'category_header.dart';
import 'modern_product_card.dart';

/// Category section widget showing products by category with animations
class CategorySection extends StatelessWidget {
  final String categoryName;
  final List<Product> products;
  final void Function(Product)? onProductTap;
  final IconData icon;

  const CategorySection({
    Key? key,
    required this.categoryName,
    required this.products,
    this.onProductTap,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeader(
          categoryName: categoryName,
          icon: icon,
          onSeeAll: () {
            // Filter products by category
            if (onProductTap != null && products.isNotEmpty) {
              // Navigate to filtered product list
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _CategoryProductListPage(
                    categoryName: categoryName,
                    products: products,
                    onProductTap: onProductTap,
                  ),
                ),
              );
            }
          },
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: UITokens.spacing16),
            itemCount: products.length > 10 ? 10 : products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < (products.length > 10 ? 10 : products.length) - 1
                      ? UITokens.spacing12
                      : 0,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: ModernProductCard(
                          product: products[index],
                          onTap: onProductTap != null
                              ? () => onProductTap!(products[index])
                              : null,
                          isHorizontal: true,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: UITokens.spacing8),
      ],
    );
  }
}

/// Category product list page for "See All" functionality
class _CategoryProductListPage extends StatelessWidget {
  final String categoryName;
  final List<Product> products;
  final void Function(Product)? onProductTap;

  const _CategoryProductListPage({
    required this.categoryName,
    required this.products,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          categoryName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: products.isEmpty
          ? Center(
              child: Text(
                'No products in this category',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            )
          : GridView.builder(
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
                          onTap: onProductTap != null
                              ? () => onProductTap!(products[index])
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

