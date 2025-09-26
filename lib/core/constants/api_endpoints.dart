class ApiEndpoints {
  // auth
  static const authLogin = "/auth/login";
  static const authRegister = "/auth/register";

  // recipes
  static const recipesLatest = "/recipes/latest";

  static const recipesCRUD = "/recipes";

  // image upload
  static const imageUpload = "/uploads";

  // profile/user endpoints
  static const userProfile = "/users";
  static const userRecipes = "/recipes/user/";
  static const userRatings = "/ratings";
  static const userInfo = "/users/id";

  // collections and favorites
  static const favorites = "/favorites";
  static const collectionsUser = "/collections/user";
  static const collectionsCRUD = "/collections";
}
