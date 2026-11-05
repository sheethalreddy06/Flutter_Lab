import 'package:flutter/material.dart';
 
void main() {
  runApp(const ShopEaseApp());
}
 
// MAIN APPLICATION
class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const ProductHomePage(),
    );
  }
}
 
// PRODUCT DATA MODEL
class Product {
  final String name;
  final String category;
  final String emoji;
  final double price;
  final double rating;
  final Color color;
 
  const Product({
    required this.name,
    required this.category,
    required this.emoji,
    required this.price,
    required this.rating,
    required this.color,
  });
}
 
// MAIN PRODUCT PAGE
class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});
 
  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}
 
class _ProductHomePageState extends State<ProductHomePage> {
  // PRODUCT LIST
  final List<Product> products = const [
    Product(
      name: 'Wireless Headphones',
      category: 'Electronics',
      emoji: '🎧',
      price: 1499,
      rating: 4.8,
      color: Color(0xFFEDE7F6),
    ),
    Product(
      name: 'Smart Watch',
      category: 'Electronics',
      emoji: '⌚',
      price: 2499,
      rating: 4.6,
      color: Color(0xFFE3F2FD),
    ),
    Product(
      name: 'Running Shoes',
      category: 'Fashion',
      emoji: '👟',
      price: 1999,
      rating: 4.5,
      color: Color(0xFFFFF3E0),
    ),
    Product(
      name: 'Backpack',
      category: 'Accessories',
      emoji: '🎒',
      price: 999,
      rating: 4.4,
      color: Color(0xFFE8F5E9),
    ),
    Product(
      name: 'Camera',
      category: 'Electronics',
      emoji: '📷',
      price: 5999,
      rating: 4.9,
      color: Color(0xFFFCE4EC),
    ),
    Product(
      name: 'Sunglasses',
      category: 'Fashion',
      emoji: '🕶️',
      price: 799,
      rating: 4.3,
      color: Color(0xFFFFF9C4),
    ),
    Product(
      name: 'Smartphone',
      category: 'Electronics',
      emoji: '📱',
      price: 12999,
      rating: 4.7,
      color: Color(0xFFE0F7FA),
    ),
    Product(
      name: 'Wrist Watch',
      category: 'Accessories',
      emoji: '⌚',
      price: 1799,
      rating: 4.5,
      color: Color(0xFFF3E5F5),
    ),
  ];
 
  int cartCount = 0;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
 
      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'ShopEase',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                const SizedBox(width: 5),
                Text('$cartCount'),
              ],
            ),
          ),
        ],
      ),
 
      // RESPONSIVE BODY
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
 
          // RESPONSIVE BREAKPOINTS
          int columns;
 
          if (width < 600) {
            columns = 2;
          } else if (width < 900) {
            columns = 3;
          } else {
            columns = 4;
          }
 
          // DIFFERENT CARD SIZES
          double cardRatio;
 
          if (width < 600) {
            cardRatio = 0.62;
          } else if (width < 900) {
            cardRatio = 0.72;
          } else {
            cardRatio = 0.78;
          }
 
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
 
                  // WELCOME BANNER
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover Amazing Products!',
                          style: TextStyle(
                            fontSize: width < 600 ? 18 : 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Find the best products at great prices.',
                        ),
                      ],
                    ),
                  ),
 
                  // SECTION TITLE
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Text(
                      'Popular Products',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
 
                  // RESPONSIVE PRODUCT GRID
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      itemCount: products.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: cardRatio,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: products[index],
                          onAddToCart: () {
                            setState(() {
                              cartCount++;
                            });
 
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${products[index].name} added to cart!',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
 
// REUSABLE CUSTOM PRODUCT WIDGET
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
 
  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });
 
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE AREA
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 55),
                  ),
                ),
              ),
            ),
 
            const SizedBox(height: 10),
 
            // PRODUCT NAME
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
 
            const SizedBox(height: 3),
 
            // PRODUCT CATEGORY
            Text(
              product.category,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
 
            const SizedBox(height: 5),
 
            // PRICE AND RATING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 15,
                ),
                Text(
                  product.rating.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
 
            const SizedBox(height: 8),
 
            // ADD TO CART BUTTON
            SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
