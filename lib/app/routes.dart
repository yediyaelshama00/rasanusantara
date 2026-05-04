import 'package:flutter/material.dart';

import '../features/ai/ai_recommendation_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/game/peta_rasa_game_screen.dart';
import '../features/map/culinary_map_screen.dart';
import '../features/navigation/main_navigation.dart';
import '../features/profile/feedback_tpm_screen.dart';
import '../features/recipe/book/recipe_book_screen.dart';
import '../features/recipe/recipe_detail_screen.dart';
import '../features/sensor/shake_random_recipe_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  static const String detail = '/recipe-detail';
  static const String recipeDetail = detail;

  static const String ai = '/ai-recommendation';
  static const String aiRecommendation = ai;

  static const String game = '/peta-rasa-game';
  static const String petaRasaGame = game;

  static const String shake = '/shake-random-recipe';
  static const String shakeRandomRecipe = shake;

  static const String feedback = '/feedback-tpm';
  static const String feedbackTpm = feedback;

  static const String culinaryMap = '/culinary-map';
  static const String recipeBook = '/recipe-book';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainNavigation(),
    detail: (context) => const RecipeDetailScreen(),
    ai: (context) => const AiRecommendationScreen(),
    game: (context) => const PetaRasaGameScreen(),
    shake: (context) => const ShakeRandomRecipeScreen(),
    feedback: (context) => const FeedbackTpmScreen(),
    culinaryMap: (context) => const CulinaryMapScreen(),
    recipeBook: (context) => const RecipeBookScreen(),
  };

  static Map<String, WidgetBuilder> get values => routes;
}