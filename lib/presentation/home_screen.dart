import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/feed/article_detail_screen.dart';
import 'package:myapp/presentation/widgets/Loading_Widgets.dart';
import 'package:myapp/presentation/widgets/article_card.dart';
import 'package:myapp/providers/auth_providers.dart';
import 'package:myapp/providers/news_provider.dart';
import 'package:myapp/service/news_service.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial news after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsProvider.notifier).loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final newsState = ref.watch(newsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business News'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: NewsService.categories.length,
              itemBuilder: (context, index) {
                final category = NewsService.categories[index];
                final isSelected = newsState.currentCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(newsProvider.notifier).setCategory(category);
                    },
                  ),
                );
              },
            ),
          ),
          // News list with pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(newsProvider.notifier).refresh(),
              child: _buildNewsList(newsState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(NewsState state) {
    if (state.isLoading && state.articles.isEmpty) {
      return const LoadingWidget();
    }

    if (state.error != null && state.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(newsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.articles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          // Loading more indicator
          if (state.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
        final article = state.articles[index];
        return ArticleCard(
          article: article,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(article: article),
              ),
            );
          },
        );
      },
    );
  }
}