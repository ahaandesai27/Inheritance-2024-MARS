// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:app/api/apiurl.dart';
import 'package:app/pages/recipedetail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SavedRecipesPage extends StatefulWidget {
  final String userID;

  const SavedRecipesPage({super.key, required this.userID});

  @override
  State<SavedRecipesPage> createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  List<dynamic> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final Uri url =
          Uri.parse('$apiUrl/api/user/recipes/saved/${widget.userID}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic parsedBody = json.decode(response.body);

        setState(() {
          recipes = parsedBody is List ? parsedBody : [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load saved recipes"')));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Recipes',
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: recipe['veg'] ? Colors.green : Colors.red,
                          width: 2.0),
                    ),
                    child: ListTile(
                      leading: recipe['image-url'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                recipe['image-url'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.food_bank, size: 80);
                                },
                              ),
                            )
                          : const Icon(Icons.food_bank, size: 80),
                      title: Text(
                        recipe['TranslatedRecipeName'] ?? 'Unknown Recipe',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Time: ${recipe['TotalTimeInMins']} mins | ${recipe['veg'] ? 'Vegetarian' : 'Non-Vegetarian'}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.black54),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailsPage(recipeData: recipe)));
                        // Navigate to recipe details page
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (context) => IngredientPage(recipe: recipe)
                        // ));
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// Category tile remains the same as before
Widget _buildCategoryTile(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SavedRecipesPage(userID: title)));
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
