import 'package:app/api/apiurl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchResultsRecipePage extends StatefulWidget {
  final String query;

  const SearchResultsRecipePage({super.key, required this.query});

  @override
  State<SearchResultsRecipePage> createState() => _SearchRecipesPageState();
}

class _SearchRecipesPageState extends State<SearchResultsRecipePage> {
  List<dynamic> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final Uri url = Uri.parse(
          '$apiUrl/api/recipes/search?skip=0&limit=50&q=${widget.query}');

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load results for "${widget.query}"')));
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
        title: Text('Results for "${widget.query}"',
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color:
                          recipe['veg'] ? Colors.greenAccent : Colors.redAccent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        recipe['TranslatedRecipeName'] ?? 'Unknown Recipe',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Time: ${recipe['TotalTimeInMins']} mins | ${recipe['veg'] ? 'Vegetarian' : 'Non-Vegetarian'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                      onTap: () {
                        // Navigate to recipe details page
                        // Navigator.push(context, MaterialPageRoute(
                        //   builder: (context) => RecipeDetailPage(recipe: recipe)
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

// Update the _buildCategoryTile in RecipePage to navigate to SearchResultsRecipePage
Widget _buildCategoryTile(BuildContext context, String title) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchResultsRecipePage(query: title)));
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
