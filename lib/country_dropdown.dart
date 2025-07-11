import 'dart:convert';

import 'package:Travellish/models/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<Country>> _loadCountries() async {
  final res = await rootBundle
      .loadString('assets/countries.json');
  final data = jsonDecode(res) as List;
  return List<Country>.from(
    data.map((item) => Country.fromJson(item)),
  );
}

class CountryDropdown extends StatefulWidget {
  
  const CountryDropdown({ super.key, this.onChange });

  final Function(String?)? onChange;

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  String? value;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadCountries(),
      builder: (context, snapshot) {
        return DropdownButton<String>(
          isExpanded: true,
          hint: Text("Select"),
          value: value,
          onChanged: (newValue) => {
            widget.onChange!(newValue),
            setState(() {
              value = newValue;
            })
          },
          items: snapshot.data != null
              ? snapshot.data!
                    .map(
                      (fc) => DropdownMenuItem<String>(
                        value: fc.name,
                        child: Text(fc.name),
                      ),
                    )
                    .toList()
              : [],
        );
      },
    );
  }
}
