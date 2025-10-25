import 'package:flutter/material.dart';

void main() {
  runApp(const ConversionApp());
}

class ConversionApp extends StatefulWidget {
  const ConversionApp({super.key});

  @override
  State<ConversionApp> createState() => _ConversionAppState();
}

class _ConversionAppState extends State<ConversionApp> {
  // --- State Variables ---
  String? _fromUnit;
  String? _toUnit;
  late TextEditingController _controller;
  String _result = "";

  // --- Conversion Data ---
  // It's better to define this once.
  final Map<String, List<double>> _unitsData = {
    'Miles': [1.0, 1.60934, 0.0, 0.0],
    'Kilometers': [0.621371, 1.0, 0.0, 0.0],
    'Kilo': [0.0, 0.0, 1.0, 2.20462],
    'Pounds': [0.0, 0.0, 0.453592, 1.0]
  };

  // The order of this list must match the order in the lists above.
  late final List<String> _unitKeys;

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _unitKeys = _unitsData.keys.toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Conversion Logic ---
  void _convert() {
    final double? value = double.tryParse(_controller.text);

    if (value == null || _fromUnit == null || _toUnit == null) {
      setState(() {
        _result = "Please enter a value and select units.";
      });
      return;
    }
    final int toIndex = _unitKeys.indexOf(_toUnit!);
    final List<double>? multipliers = _unitsData[_fromUnit!];

    // Check if conversion is possible
    if (multipliers == null || toIndex == -1 || multipliers[toIndex] == 0.0) {
      setState(() {
        _result = "Cannot convert from $_fromUnit to $_toUnit.";
      });
      return;
    }
    final double factor = multipliers[toIndex];
    final double convertedValue = value * factor;

    setState(() {
      _result = '${_formatNumber(value)} $_fromUnit = ${_formatNumber(convertedValue)} $_toUnit';
    });
  }

  // Helper to format numbers nicely
  String _formatNumber(double number) {
    if (number == number.truncateToDouble()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Conversion App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)
              )
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Unit Conversion App'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'Enter the value to convert',
                  ),
                ),
                const SizedBox(height: 20),
                _buildUnitDropdown(
                  hint: 'From',
                  value: _fromUnit,
                  onChanged: (newValue) => setState(() => _fromUnit = newValue),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Icon(Icons.swap_vert, size: 30, color: Colors.grey),
                ),
                _buildUnitDropdown(
                  hint: 'To',
                  value: _toUnit,
                  onChanged: (newValue) => setState(() => _toUnit = newValue),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _convert,
                  child: const Text('Convert'),
                ),
                const SizedBox(height: 30),
                if (_result.isNotEmpty)
                  Text(
                    _result,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildUnitDropdown({required String hint, String? value, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      ),
      items: _unitKeys.map((String unit) {
        return DropdownMenuItem<String>(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
