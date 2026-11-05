import 'package:flutter/material.dart';
 
void main() {
  runApp(const MyApp());
}
 
// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fresh Fruits',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const FruitHomePage(),
    );
  }
}
 
// Fruit data model
class Fruit {
  final String name;
  final String emoji;
  final String description;
  final String price;
 
  const Fruit({
    required this.name,
    required this.emoji,
    required this.description,
    required this.price,
  });
}
 
// Main home page
class FruitHomePage extends StatelessWidget {
  const FruitHomePage({super.key});
 
  // List of fruit items
  static const List<Fruit> fruits = [
    Fruit(
      name: 'Apple',
      emoji: '🍎',
      description: 'Fresh and juicy red apples',
      price: '₹120 / kg',
    ),
    Fruit(
      name: 'Banana',
      emoji: '🍌',
      description: 'Sweet and ripe bananas',
      price: '₹60 / dozen',
    ),
    Fruit(
      name: 'Orange',
      emoji: '🍊',
      description: 'Rich in Vitamin C',
      price: '₹80 / kg',
    ),
    Fruit(
      name: 'Strawberry',
      emoji: '🍓',
      description: 'Fresh and delicious strawberries',
      price: '₹200 / box',
    ),
    Fruit(
      name: 'Grapes',
      emoji: '🍇',
      description: 'Sweet seedless grapes',
      price: '₹100 / kg',
    ),
    Fruit(
      name: 'Watermelon',
      emoji: '🍉',
      description: 'Refreshing summer fruit',
      price: '₹40 / kg',
    ),
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fresh Fruits 🍃',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
 
      // Column arranges the header and list vertically
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section using Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Choose your favourite fresh fruits.',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
 
          // Section heading
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              'Available Fruits',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
 
          // ListView displays all fruit cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: fruits.length,
              itemBuilder: (context, index) {
                return FruitCard(fruit: fruits[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
 
// Reusable custom widget for displaying a fruit
class FruitCard extends StatelessWidget {
  final Fruit fruit;
 
  const FruitCard({
    super.key,
    required this.fruit,
  });
 
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(14),
 
        // Row arranges fruit details horizontally
        child: Row(
          children: [
            // Container displays the fruit emoji
            Container(
              width: 65,
              height: 65,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                fruit.emoji,
                style: const TextStyle(fontSize: 35),
              ),
            ),
 
            const SizedBox(width: 15),
 
            // Column arranges fruit details vertically
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fruit.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fruit.price,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
 
            const Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
