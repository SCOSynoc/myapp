# myapp

A new Flutter project.

## Folder structure explanation 

- core folder will contains constants and utility functions 
- models folder will contain data models for fetching data from an api 
- presentation layer contains all UI screens
  - In presentation layer sub-folders are created based on features 
  - Also in widget folder there are reusable widgets for an app 
- Providers folder contains all features providers which manage app's features states effectively 
- service folders contains functionality related to fetching data from an api 
different files were created for fetching data from different APIs 

- This folder structure keeps architecture clean and scalable and allows modification in an application without affecting UI.

## Key Decisons 

- State Management – Riverpod

        Used StateNotifierProvider for complex state like news feed, favorites to encapsulate logic.
        FutureProvider for simple async operations like fetching categories.
        Provides clean dependency injection and reactivity across widgets.

- Local Storage – Hive

        Lightweight, NoSQL solution with type-safe adapters.
        Stores user session for offline access.
        Articles stored with URL as key to prevent duplicates.

-Separation of Concerns

    Models: Plain Dart classes for data Article, User.
    Services: API calls (NewsService) and Hive operations (FavoritesService, AuthService).
    Providers: Bridge between services and UI, managing state and business logic.
    Screens & Widgets: UI only, observing providers.
    Ensures maintainability and testability.

-Pagination & Pull-to-Refresh

    NewsNotifier tracks page, loading state, and hasMore flag.
    Infinite scroll via ScrollController listener triggering loadMore().
    RefreshIndicator triggers refresh() to reset page and reload data.

- Category Filtering

        Horizontal ChoiceChip list built from NewsService.categories.
        Selecting a category calls setCategory() which resets state and loads new data.

- Favorites Management

        Dedicated FavoritesService and FavoritesNotifier for CRUD operations.
        Favorite status checked on article detail screen using isFavorite() method.
        Favorites screen shows all saved articles, with real-time updates.
        Full Article View – No WebView
        Used flutter_html to render article content (if available) from API.
        Provides "Open in Browser" button that launches external browser via    url_launcher.
        Simplifies development, avoids WebView complexities, and reduces app size.

- Persistent Login State

        User object stored in Hive; AuthNotifier loads user on app start.
        ConsumerWidget in MyApp listens to authProvider to decide initial route.
        Logout clears Hive and updates state, triggering navigation to login.

Error Handling & User Feedback

    Try-catch blocks in services; errors propagated to providers.
    UI shows error messages with retry button for initial loads.
    Loading states (isLoading, isLoadingMore) provide visual feedback.

Scalability & Extensibility

        Modular folders like models, services, providers, screens, widgets.
        Adding new features (e.g., search, dark mode) requires minimal changes.
        Easy to replace services (e.g., API provider) without affecting UI.



