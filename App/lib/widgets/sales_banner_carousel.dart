import 'package:flutter/material.dart';
import 'dart:async';
import '../app_theme.dart';
import '../ui_tokens.dart';

/// Auto-sliding sales banner carousel
class SalesBannerCarousel extends StatefulWidget {
  final void Function(String category, double discountPercent)? onShopNow;

  const SalesBannerCarousel({
    Key? key,
    this.onShopNow,
  }) : super(key: key);

  @override
  State<SalesBannerCarousel> createState() => _SalesBannerCarouselState();
}

class _SalesBannerCarouselState extends State<SalesBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': '90% OFF',
      'subtitle': 'On Clothing',
      'description': 'Huge discounts on all clothing items',
      'color': AppColors.primary,
      'icon': Icons.checkroom,
      'category': 'Clothing',
      'discount': 90.0,
    },
    {
      'title': '20% OFF',
      'subtitle': 'On Electronics',
      'description': 'Special deals on electronics',
      'color': AppColors.accent,
      'icon': Icons.devices,
      'category': 'Electronics',
      'discount': 20.0,
    },
    {
      'title': '50% OFF',
      'subtitle': 'On Groceries',
      'description': 'Fresh groceries at amazing prices',
      'color': AppColors.success,
      'icon': Icons.shopping_basket,
      'category': 'Groceries',
      'discount': 50.0,
    },
    {
      'title': '30% OFF',
      'subtitle': 'On Books',
      'description': 'Expand your knowledge with great deals',
      'color': AppColors.warning,
      'icon': Icons.menu_book,
      'category': 'Books',
      'discount': 30.0,
    },
    {
      'title': '40% OFF',
      'subtitle': 'On Sports',
      'description': 'Gear up for your fitness journey',
      'color': AppColors.error,
      'icon': Icons.sports_soccer,
      'category': 'Sports',
      'discount': 40.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _banners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return _buildBanner(banner);
            },
          ),
        ),
        const SizedBox(height: UITokens.spacing8),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => Container(
              width: _currentPage == index ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(Map<String, dynamic> banner) {
    return GestureDetector(
      onTap: () {
        final category = banner['category']?.toString();
        final discountValue = banner['discount'];
        final discount = discountValue is num ? discountValue.toDouble() : 0.0;
        if (category != null && widget.onShopNow != null) {
          widget.onShopNow!(category, discount);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: UITokens.spacing16),
        decoration: BoxDecoration(
          color: const Color(0xFF232F3E), // RGB(35, 47, 62)
          borderRadius: BorderRadius.circular(UITokens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UITokens.spacing20,
            vertical: UITokens.spacing16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      banner['title'],
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: UITokens.spacing4),
                    Text(
                      banner['subtitle'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: UITokens.spacing8),
                    Text(
                      banner['description'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.95),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: UITokens.spacing12),
                    // CTA Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final category = banner['category']?.toString();
                            final discountValue = banner['discount'];
                            final discount = discountValue is num ? discountValue.toDouble() : 0.0;
                            if (category != null && widget.onShopNow != null) {
                              widget.onShopNow!(category, discount);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UITokens.spacing16,
                              vertical: UITokens.spacing8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Shop Now',
                                  style: TextStyle(
                                    color: banner['color'] as Color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: banner['color'] as Color,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: UITokens.spacing12),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  banner['icon'],
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

