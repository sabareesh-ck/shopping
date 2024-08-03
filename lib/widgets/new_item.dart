import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  var issending = false;
  var enteredname = "";
  var enteredquantity = 1;
  var selectedcategories = categories[Categories.vegetables]!;
  final url = Uri.https(
      'flutter-prep-890f5-default-rtdb.firebaseio.com', 'shopping-list.json');
  final _formKey = GlobalKey<FormState>();
  void saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        issending = true;
      });
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': enteredname,
            'quantity': enteredquantity,
            'category': selectedcategories.name
          }));
      response.body;
      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> responsedata = json.decode(response.body);
      Navigator.of(context).pop(GroceryItem(
          id: responsedata['name'],
          name: enteredname,
          quantity: enteredquantity,
          category: selectedcategories));
    }
  }

  void resetItem() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add your new Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length == 1 ||
                        value.trim().length > 50) {
                      return ' Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    enteredname = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: "1",
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return ' Should contain a positive numbers';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredquantity = int.parse(value!);
                        },
                        decoration:
                            const InputDecoration(label: Text('Quantity')),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: selectedcategories,
                          items: [
                            for (final category in categories.entries)
                              DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.name)
                                  ],
                                ),
                              )
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedcategories = value!;
                            });
                          }),
                    ),
                  ],
                ) // Instead of TextField
                ,
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: issending ? null : resetItem,
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: issending ? null : saveItem,
                        child: issending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Add Item'))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
