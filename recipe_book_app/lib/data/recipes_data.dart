import '../models/recipe.dart';

final List<Recipe> sampleRecipes = [
  Recipe(
    name: 'Spaghetti Bolognese',
    imagePath: 'assets/images/pasta.jpg',
    ingredients: [
      'Spaghetti',
      'Ground beef',
      'Tomato sauce',
      'Onion',
      'Garlic',
    ],
    instructions:
        'Cook pasta. Brown beef with onion & garlic. Add sauce. Combine & serve.',
  ),
  Recipe(
    name: 'Ramen',
    imagePath: 'assets/images/ramen.jpg',
    ingredients: [
      'Ramen noodles',
      'Chicken broth',
      'Soft-boiled egg',
      'Green onions',
      'Soy sauce',
      'Sesame oil',
    ],
    instructions:
        'Boil noodles. Heat broth with soy sauce & sesame oil. Combine in bowl, top with egg and green onions.',
  ),
  Recipe(
    name: 'Burger',
    imagePath: 'assets/images/burger.jpg',
    ingredients: [
      'Ground beef',
      'Burger buns',
      'Cheese',
      'Lettuce',
      'Tomato',
      'Onion',
      'Ketchup',
      'Mustard',
    ],
    instructions:
        'Form beef into patties. Grill to desired doneness. Toast buns. Add cheese, lettuce, tomato, onion, ketchup & mustard.',
  ),
  Recipe(
    name: 'Mac and Cheese',
    imagePath: 'assets/images/mac.jpg',
    ingredients: [
      'Macaroni',
      'Cheddar cheese',
      'Milk',
      'Butter',
      'Flour',
      'Salt',
      'Pepper',
    ],
    instructions:
        'Cook macaroni. Make roux with butter & flour. Add milk, then cheese. Combine with pasta and bake until golden.',
  ),
];
