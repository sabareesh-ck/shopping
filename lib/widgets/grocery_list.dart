import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceryLists extends StatefulWidget {
  const GroceryLists({super.key});

  @override
  State<GroceryLists> createState() => _GroceryListsState();
}

class _GroceryListsState extends State<GroceryLists> {
  String? error;
  var isloading = true;
  List<GroceryItem> _groceryitem = [];
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final url = Uri.https(
        'flutter-prep-890f5-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      error = 'Failed to fetch data please Try Again later';
    }
    if (response.body == 'null') {
      setState(() {
        isloading = false;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItem = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((catItem) => catItem.value.name == item.value['category'])
          .value;
      loadedItem.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
      setState(() {
        _groceryitem = loadedItem;
        isloading = false;
      });
    }
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryitem.add(newItem);
    });
  }

  void removeitem(GroceryItem grocery) {
    final url = Uri.https('flutter-prep-890f5-default-rtdb.firebaseio.com',
        'shopping-list/${grocery.id}.json');
    http.delete(url);
    final groceryindex = _groceryitem.indexOf(grocery);

    setState(() {
      _groceryitem.remove(grocery);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Grocery Deleted"),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              _groceryitem.insert(groceryindex, grocery);
            });
          }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var emptyitem = _groceryitem.isEmpty;

    Widget content = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No Item is Added"),
          SizedBox(
            height: 8,
          ),
          Text("To add a item press the '+' icon in right top corner")
        ],
      ),
    );
    if (isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (error != null) {
      content = Center(
        child: Text(error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Groceries",
        ),
        actions: [IconButton(onPressed: addItem, icon: const Icon(Icons.add))],
      ),
      body: emptyitem
          ? content
          : ListView.builder(
              itemCount: _groceryitem.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  background: Container(
                    color: const Color.fromARGB(255, 238, 122, 113),
                  ),
                  onDismissed: (direction) {
                    removeitem(_groceryitem[index]);
                  },
                  key: ValueKey(_groceryitem[index]),
                  child: ListTile(
                    title: Text(_groceryitem[index].name),
                    leading: Container(
                      height: 24,
                      width: 24,
                      color: _groceryitem[index].category.color,
                    ),
                    trailing: Text(_groceryitem[index].quantity.toString()),
                  ),
                );
              },
            ),
    );
  }
}
