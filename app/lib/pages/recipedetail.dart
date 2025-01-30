// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/api/fetchproductprices.dart';
import 'package:app/api/recipe.dart';
import 'package:app/pages/ingredient_prices_page.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const RecipeDetailsPage({super.key, required this.recipeData});
  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  final Map<String, List<ProductPrice>> _ingredientPrices = {};
  final Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    // _fetchAllPrices();
  }

  Future<void> _fetchAllPrices() async {
    final recipe = Recipe.fromJson(widget.recipeData);
    for (String ingredient in recipe.cleanedIngredients) {
      if (ingredient.trim().isEmpty) continue;
      setState(() {
        _loadingStates[ingredient] = true;
      });

      try {
        final prices =
            await PriceTrackingService.getPricesForIngredient(ingredient);
        setState(() {
          _ingredientPrices[ingredient] = prices;
          _loadingStates[ingredient] = false;
        });
      } catch (e) {
        print('Error fetching prices for $ingredient: $e');
        setState(() {
          _loadingStates[ingredient] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = Recipe.fromJson(widget.recipeData);

    return Scaffold(
      appBar: AppBar(
        title: Text('RecipAura',
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colour.purpur,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Image.network(
                recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.food_bank, size: 100);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name and Veg/Non-veg indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.translatedRecipeName,
                          style: GoogleFonts.raleway(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: recipe.isVeg ? Colors.green : Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.isVeg ? 'VEG' : 'NON-VEG',
                          style: TextStyle(
                            color: recipe.isVeg ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Info Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.timer, color: Colors.deepPurple),
                              Text('${recipe.totalTimeInMins} mins',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.deepPurple),
                              Text('${recipe.calorieCount} cal',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.restaurant_menu,
                                  color: Colors.deepPurple),
                              Text('${recipe.ingredientCount} items',
                                  style: GoogleFonts.raleway()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ingredients Section
                  Text(
                    'Ingredients',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.cleanedIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient =
                          recipe.cleanedIngredients[index].trim();
                      if (ingredient.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.fiber_manual_record,
                                size: 8, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(ingredient,
                                  style: GoogleFonts.raleway(fontSize: 16)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Instructions Section
                  Text(
                    'Instructions',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.translatedInstructions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                recipe.translatedInstructions[index],
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Shopping Section
                  // Shopping Section
                  Text(
                    'Ingredients Pricing',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.cleanedIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient =
                          recipe.cleanedIngredients[index].trim();
                      if (ingredient.isEmpty) return const SizedBox.shrink();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            ingredient,
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IngredientPricesPage(
                                  ingredient: ingredient,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
