import 'package:flutter/material.dart';
 
void main() {
  runApp(const ShopEaseApp());
}
 
// PRODUCT MODEL
class Product {
  final String name;
  final String description;
  final String emoji;
  final double price;
  final Color color;
 
  const Product({
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    required this.color,
  });
}
 
// MAIN APPLICATION
class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase Navigation',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
 
      // NAMED ROUTES
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/details': (context) => const DetailsScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
 
// HOME SCREEN
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
 
  // PREDEFINED PRODUCTS
  static const List<Product> products = [
    Product(
      name: 'Wireless Headphones',
      description:
          'High-quality wireless headphones with clear sound '
          'and comfortable ear cushions.',
      emoji: '🎧',
      price: 1499,
      color: Color(0xFFEDE7F6),
    ),
    Product(
      name: 'Smart Watch',
      description:
          'A stylish smartwatch with fitness tracking and '
          'smart notifications.',
      emoji: '⌚',
      price: 2499,
      color: Color(0xFFE3F2FD),
    ),
    Product(
      name: 'Running Shoes',
      description:
          'Comfortable and lightweight running shoes '
          'designed for everyday activities.',
      emoji: '👟',
      price: 1999,
      color: Color(0xFFFFF3E0),
    ),
    Product(
      name: 'Backpack',
      description:
          'A spacious and durable backpack suitable '
          'for college and travel.',
      emoji: '🎒',
      price: 999,
      color: Color(0xFFE8F5E9),
    ),
    Product(
      name: 'Camera',
      description:
          'Capture memorable moments with this '
          'high-quality digital camera.',
      emoji: '📷',
      price: 5999,
      color: Color(0xFFFCE4EC),
    ),
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'ShopEase',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WELCOME SECTION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.deepPurple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to ShopEase!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 5),
                Text('Explore our latest products.'),
              ],
            ),
          ),
 
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Available Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
 
          // PRODUCT LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
 
                return ProductCard(
                  product: product,
                  onTap: () {
                    // NAVIGATE AND PASS DATA
                    Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: product,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
 
// REUSABLE PRODUCT CARD
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
 
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: product.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              product.emoji,
              style: const TextStyle(fontSize: 35),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '₹${product.price.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
 
// DETAILS SCREEN
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    // RECEIVE DATA FROM HOME SCREEN
    final product =
        ModalRoute.of(context)!.settings.arguments as Product;
 
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // PRODUCT IMAGE
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: product.color,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
 
                  const SizedBox(height: 20),
 
                  // PRODUCT NAME
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
 
                  const SizedBox(height: 12),
 
                  // DESCRIPTION
                  Text(
                    product.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
 
                  const SizedBox(height: 20),
 
                  // PRICE
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
 
                  const SizedBox(height: 25),
 
                  // ADD TO CART
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/cart',
                        arguments: product,
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
 
                  const SizedBox(height: 10),
 
                  // BACK BUTTON
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
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
 
// CART SCREEN
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    // RECEIVE PRODUCT DATA
    final product =
        ModalRoute.of(context)!.settings.arguments as Product?;
 
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: product == null
            ? const Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 20),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        ),
 
                        const SizedBox(height: 15),
 
                        const Text(
                          'Product Added Successfully!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
 
                        const SizedBox(height: 20),
 
                        Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 65),
                        ),
 
                        const SizedBox(height: 10),
 
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
 
                        const SizedBox(height: 8),
 
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
 
                        const SizedBox(height: 25),
 
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Continue Shopping'),
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
