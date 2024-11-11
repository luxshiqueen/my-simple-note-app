import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteItem {
  final String name;
  final String date;
  final String type;
  bool isFavorite;

  FavoriteItem({
    required this.name,
    required this.date,
    required this.type,
    this.isFavorite = false,
  });

  // FavoriteItem to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date,
      'type': type,
      'isFavorite': isFavorite,
    };
  }

  // Create a FavoriteItem from a map
  static FavoriteItem fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      name: map['name'],
      date: map['date'],
      type: map['type'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final List<FavoriteItem> favorites = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedType = 'Birthday';
  int? _editingIndex;
  bool _isDetailView = false;
  FavoriteItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // Load favorites when the page is initialized
  }

  Future<void> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteData = prefs.getStringList('favorites');

    if (favoriteData != null) {
      setState(() {
        favorites.clear();
        for (String item in favoriteData) {
          favorites.add(FavoriteItem.fromMap(
              Map<String, dynamic>.from(jsonDecode(item))));
        }
      });
    }
  }

  Future<void> _saveFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteData =
        favorites.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList('favorites', favoriteData);
  }

  void _saveFavorite() {
    String name = _nameController.text;
    String date = _dateController.text;

    if (name.isNotEmpty && date.isNotEmpty) {
      setState(() {
        if (_editingIndex == null) {
          favorites.add(FavoriteItem(
            name: name,
            date: date,
            type: _selectedType,
          ));
        } else {
          favorites[_editingIndex!] = FavoriteItem(
            name: name,
            date: date,
            type: _selectedType,
            isFavorite: favorites[_editingIndex!].isFavorite,
          );
          _editingIndex = null;
        }
        _nameController.clear();
        _dateController.clear();
      });
      _saveFavorites(); // Save favorites after adding/updating
    }
  }

  void _editFavorite(int index) {
    setState(() {
      _editingIndex = index;
      _nameController.text = favorites[index].name;
      _dateController.text = favorites[index].date;
      _selectedType = favorites[index].type;
      _isDetailView = false;
    });
  }

  Future<void> _confirmDelete(int index) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this favorite?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      _deleteFavorite(index);
    }
  }

  void _deleteFavorite(int index) {
    setState(() {
      favorites.removeAt(index);
      _isDetailView = false;
    });
    _saveFavorites(); // Save favorites after deletion
  }

  void _viewFavorite(FavoriteItem item) {
    setState(() {
      _selectedItem = item;
      _isDetailView = true;
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      favorites[index].isFavorite = !favorites[index].isFavorite;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Start from the year 1900
      lastDate: DateTime(2101), // End at the year 2101
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color.fromARGB(255, 233, 54, 140),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isDetailView) ...[
              DropdownButton<String>(
                value: _selectedType,
                items: <String>['Birthday', 'Memory'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveFavorite,
                child: Text(
                    _editingIndex == null ? 'Add Favorite' : 'Update Favorite'),
              ),
            ] else if (_selectedItem != null) ...[
              ListTile(
                title: Text(_selectedItem!.name),
                subtitle:
                    Text('${_selectedItem!.date} - ${_selectedItem!.type}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(favorites.indexOf(_selectedItem!));
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _editingIndex = favorites.indexOf(_selectedItem!);
                  _nameController.text = _selectedItem!.name;
                  _dateController.text = _selectedItem!.date;
                  _selectedType = _selectedItem!.type;
                  setState(() {
                    _isDetailView = false;
                  });
                },
                child: const Text('Edit Favorite'),
              ),
            ],
            const SizedBox(height: 10),
            // Display list of favorites
            Expanded(
              child: ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(favorites[index].name),
                    subtitle: Text(
                        '${favorites[index].date} - ${favorites[index].type}'),
                    trailing: IconButton(
                      icon: Icon(
                        favorites[index].isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favorites[index].isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        _toggleFavorite(index);
                      },
                    ),
                    onTap: () => _viewFavorite(favorites[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
