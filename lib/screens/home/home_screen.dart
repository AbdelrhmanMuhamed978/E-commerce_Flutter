import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/product_model.dart';
import '../../shared/utils/responsive_utils.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'electronics',
    'men\'s clothing',
    'jewelery',
    'women\'s clothing'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();

      // Only load cart if user is authenticated
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Provider.of<CartProvider>(context, listen: false).getCart();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Function to determine number of columns based on screen width
  int _getCrossAxisCount(BuildContext context) {
    return ResponsiveUtils.getGridCrossAxisCount(context);
  }

  // Function to get display name for categories
  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'All':
        return 'All';
      case 'electronics':
        return 'Electronics';
      case 'men\'s clothing':
        return 'Men\'s';
      case 'jewelery':
        return 'Jewelry';
      case 'women\'s clothing':
        return 'Women\'s';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // This hides the back button
        actions: [
          // Android Download Button - Only show on web
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.android),
              tooltip: 'Download Android App',
              onPressed: () {
                // TODO: Add your Android app download link here
                _showDownloadDialog(context);
              },
            ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartProvider.cartItemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cartProvider.cartItemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (String value) {
                  switch (value) {
                    case 'profile':
                      Navigator.pushNamed(context, '/profile');
                      break;
                    case 'orders':
                      Navigator.pushNamed(context, '/orders');
                      break;
                    case 'admin':
                      if (authProvider.isAdmin) {
                        Navigator.pushNamed(context, '/admin');
                      }
                      break;
                    case 'logout':
                      authProvider.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'orders',
                    child: Row(
                      children: [
                        Icon(Icons.receipt),
                        SizedBox(width: 8),
                        Text('Orders'),
                      ],
                    ),
                  ),
                  if (authProvider.isAdmin)
                    const PopupMenuItem<String>(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings),
                          SizedBox(width: 8),
                          Text('Admin Dashboard'),
                        ],
                      ),
                    ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  height: ResponsiveUtils.getResponsiveHeight(
                      context, 0.06), // Responsive height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getResponsiveSpacing(context) / 2),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Container(
                        margin: EdgeInsets.only(
                            right:
                                ResponsiveUtils.getResponsiveSpacing(context) /
                                    2),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveUtils.getResponsiveSpacing(context),
                              vertical: ResponsiveUtils.getResponsiveSpacing(
                                      context) /
                                  2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.blue : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryDisplayName(category),
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context, 12),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Products Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading products',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productProvider.error!,
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => productProvider.fetchProducts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredProducts =
                    _filterProducts(productProvider.products);

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.fetchProducts(),
                  child: GridView.builder(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      childAspectRatio:
                          0.72, // Adjusted for centered description layout
                      crossAxisSpacing:
                          ResponsiveUtils.getResponsiveSpacing(context),
                      mainAxisSpacing:
                          ResponsiveUtils.getResponsiveSpacing(context),
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: filteredProducts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Show download dialog for Android app
  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.android, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text('Download Android App'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_download, size: 48, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Get the full experience with our Android app!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Download the app for the best mobile experience!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Launch the Android APK download
                const String apkUrl =
                    'https://abdelrhman-dev.me/Abdelrhman/E-commerce.apk';
                try {
                  final Uri url = Uri.parse(apkUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Download started! Check your downloads folder.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open download link'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, size: 18),
                  SizedBox(width: 4),
                  Text('Download'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent overflow
          children: [
            // Smaller image container
            Container(
              height: ResponsiveUtils.getResponsiveHeight(
                  context, 0.15), // Responsive height
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color:
                    Colors.white, // White background for better image display
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: ResponsiveUtils.getResponsiveMargin(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Prevent overflow
                  children: [
                    // Product Title
                    Text(
                      product.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 12),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(context) /
                            4), // Reduced spacing
                    // Product Description - Only show on web, not on mobile
                    if (kIsWeb) ...[
                      Expanded(
                        child: Center(
                          child: Text(
                            product.description,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 9),
                              color: Colors.grey[600],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                          height:
                              ResponsiveUtils.getResponsiveSpacing(context) /
                                  4), // Reduced spacing
                    ],
                    // Price and Rating Row with Add to Cart Button
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context, 13),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                        context) /
                                    4), // Reduced spacing
                            // Add to Cart Button under price on left side
                            Consumer<CartProvider>(
                              builder: (context, cartProvider, child) {
                                final iconSize =
                                    ResponsiveUtils.getResponsiveIconSize(
                                        context, 14);
                                final buttonSize = iconSize + 14; // Add padding

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                      size: iconSize,
                                    ),
                                    onPressed: () async {
                                      await cartProvider.addToCart(
                                          product.id, 1);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${product.title} added to cart'),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    padding: const EdgeInsets.all(4),
                                    constraints: BoxConstraints(
                                      minWidth: buttonSize,
                                      minHeight: buttonSize,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Rating on right side
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star,
                                color: Colors.amber,
                                size: ResponsiveUtils.getResponsiveIconSize(
                                    context, 12)),
                            const SizedBox(width: 2),
                            Text(
                              '${product.rating}',
                              style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context, 10)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(context) /
                            4), // Reduced final spacing
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
