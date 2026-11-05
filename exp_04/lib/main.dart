import 'package:flutter/material.dart';
 
void main() {
  runApp(const MileageApp());
}
 
// MAIN APPLICATION
class MileageApp extends StatelessWidget {
  const MileageApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Mileage Calculator',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const MileageHomePage(),
    );
  }
}
 
// MAIN STATEFUL WIDGET
class MileageHomePage extends StatefulWidget {
  const MileageHomePage({super.key});
 
  @override
  State<MileageHomePage> createState() =>
      _MileageHomePageState();
}
 
class _MileageHomePageState extends State<MileageHomePage> {
  // FORM KEY
  final _formKey = GlobalKey<FormState>();
 
  // INPUT CONTROLLERS
  final TextEditingController distanceController =
      TextEditingController();
 
  final TextEditingController fuelController =
      TextEditingController();
 
  // MILEAGE RESULT
  double? mileage;
 
  // CALCULATE MILEAGE
  void calculateMileage() {
    if (_formKey.currentState!.validate()) {
      final double distance =
          double.parse(distanceController.text);
 
      final double fuel =
          double.parse(fuelController.text);
 
      setState(() {
        mileage = distance / fuel;
      });
 
      FocusScope.of(context).unfocus();
    }
  }
 
  // RESET ALL INPUTS
  void resetCalculator() {
    setState(() {
      distanceController.clear();
      fuelController.clear();
      mileage = null;
    });
 
    _formKey.currentState!.reset();
    FocusScope.of(context).unfocus();
  }
 
  @override
  void dispose() {
    distanceController.dispose();
    fuelController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
 
      // APP BAR
      appBar: AppBar(
        title: const Text(
          'Car Mileage Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
 
      // APPLICATION BODY
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      // HEADER ICON
                      const Icon(
                        Icons.directions_car,
                        size: 75,
                        color: Colors.green,
                      ),
 
                      const SizedBox(height: 12),
 
                      const Text(
                        'Calculate Your Mileage',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
 
                      const SizedBox(height: 8),
 
                      Text(
                        'Enter your travel details to calculate '
                        'your vehicle mileage.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
 
                      const SizedBox(height: 30),
 
                      // DISTANCE INPUT
                      const Text(
                        'Distance Travelled (km)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
 
                      const SizedBox(height: 8),
 
                      TextFormField(
                        controller: distanceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter distance in km',
                          prefixIcon: const Icon(
                            Icons.route,
                            color: Colors.green,
                          ),
                          suffixText: 'km',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter the distance';
                          }
 
                          final distance =
                              double.tryParse(value.trim());
 
                          if (distance == null) {
                            return 'Enter a valid number';
                          }
 
                          if (!distance.isFinite ||
                              distance <= 0) {
                            return 'Distance must be greater than zero';
                          }
 
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            mileage = null;
                          });
                        },
                      ),
 
                      const SizedBox(height: 22),
 
                      // FUEL INPUT
                      const Text(
                        'Fuel Consumed (litres)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
 
                      const SizedBox(height: 8),
 
                      TextFormField(
                        controller: fuelController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter fuel consumed',
                          prefixIcon: const Icon(
                            Icons.local_gas_station,
                            color: Colors.green,
                          ),
                          suffixText: 'L',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter fuel consumed';
                          }
 
                          final fuel =
                              double.tryParse(value.trim());
 
                          if (fuel == null) {
                            return 'Enter a valid number';
                          }
 
                          if (!fuel.isFinite || fuel <= 0) {
                            return 'Fuel must be greater than zero';
                          }
 
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            mileage = null;
                          });
                        },
                      ),
 
                      const SizedBox(height: 28),
 
                      // CALCULATE BUTTON
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: calculateMileage,
                          icon: const Icon(Icons.calculate),
                          label: const Text(
                            'Calculate Mileage',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
 
                      const SizedBox(height: 12),
 
                      // RESET BUTTON
                      OutlinedButton.icon(
                        onPressed: resetCalculator,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
 
                      // RESULT SECTION
                      if (mileage != null) ...[
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius:
                                BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.speed,
                                size: 40,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Your Vehicle Mileage',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${mileage!.toStringAsFixed(2)} km/l',
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Kilometres per litre',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
