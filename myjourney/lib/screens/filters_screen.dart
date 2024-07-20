import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String _selectedType = 'Cualquiera';
  String _selectedCategory = 'Cualquiera';
  double? _minPrice;
  double? _maxPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: <String>['Cualquiera', 'Reseña', 'Actividad'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Type',
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: <String>[
                'Cualquiera',
                'Restaurante',
                'Mirador',
                'Museo',
                'Sitio Histórico'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_capitalize(value)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Category',
              ),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: 'Precio mínimo'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _minPrice = double.tryParse(value);
              },
            ),
            TextFormField(
              decoration: InputDecoration(hintText: 'Precio máximo'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _maxPrice = double.tryParse(value);
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'type': _selectedType,
                  'category': _selectedCategory,
                  'minPrice': _minPrice,
                  'maxPrice': _maxPrice,
                });
              },
              child: Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}
