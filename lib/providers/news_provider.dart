import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/service/news_service.dart';
import '../models/article.dart';

final newsServiceProvider = Provider((ref) => NewsService());

final businessNewsProvider = FutureProvider<List<Article>>((ref) {
  final newsService = ref.watch(newsServiceProvider);
  return newsService.fetchBusinessNews();
});

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref.read(newsServiceProvider));
});

class NewsState {
  final List<Article> articles;
  final String? currentCategory;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;

  NewsState({
    required this.articles,
    this.currentCategory,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
  });

  NewsState copyWith({
    List<Article>? articles,
    String? currentCategory,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      currentCategory: currentCategory ?? this.currentCategory,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final NewsService _newsService;

  NewsNotifier(this._newsService) : super(NewsState(articles: []));

  Future<void> loadInitial({String? category}) async {
    if (state.isLoading) return;

    // Reset state for new category
    state = state.copyWith(
      articles: [],
      isLoading: true,
      hasMore: true,
      error: null,
      currentPage: 1,
      currentCategory: category ?? state.currentCategory,
    );

    try {
      final articles = await _newsService.fetchTopHeadlines(
        category: state.currentCategory,
        page: 1,
        pageSize: 20,
      );
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        hasMore: articles.length == 20, // if we got less than pageSize, no more pages
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final newArticles = await _newsService.fetchTopHeadlines(
        category: state.currentCategory,
        page: nextPage,
        pageSize: 20,
      );
      final updatedArticles = [...state.articles, ...newArticles];
      state = state.copyWith(
        articles: updatedArticles,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newArticles.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final articles = await _newsService.fetchTopHeadlines(
        category: state.currentCategory,
        page: 1,
        pageSize: 20,
      );
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        hasMore: articles.length == 20,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setCategory(String category) {
    if (state.currentCategory == category) return;
    state = state.copyWith(currentCategory: category);
    loadInitial(); // reload with new category
  }
}