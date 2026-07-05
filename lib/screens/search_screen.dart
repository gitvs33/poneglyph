import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/search_provider.dart';
import '../../providers/library_provider.dart';
import 'reader/reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().clearSearch();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<SearchProvider>(
      builder: (context, search, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Search header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.grid16,
                    DesignTokens.grid16,
                    DesignTokens.grid16,
                    DesignTokens.grid8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search books, authors, tags…',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(100),
                        ),
                        suffixIcon: search.isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _controller.clear();
                                      search.clearSearch();
                                    },
                                  )
                                : null,
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onSubmitted: (query) => search.search(query),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          search.clearSearch();
                        }
                      },
                    ),
                  ),
                ),

                // Recent searches (when no query)
                if (_controller.text.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.grid24,
                      DesignTokens.grid16,
                      DesignTokens.grid24,
                      DesignTokens.grid8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Searches', style: theme.textTheme.titleMedium),
                        if (search.recentSearches.isNotEmpty)
                          GestureDetector(
                            onTap: search.clearRecentSearches,
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (search.recentSearches.isEmpty)
                    const Expanded(
                      child: Center(child: Text('No recent searches')),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: search.recentSearches.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final recent = search.recentSearches[index];
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(recent),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => search.removeRecentSearch(recent),
                            ),
                            onTap: () {
                              _controller.text = recent;
                              search.search(recent);
                            },
                          );
                        },
                      ),
                    ),
                ],

                // Search results
                if (_controller.text.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.grid24,
                      DesignTokens.grid8,
                      DesignTokens.grid24,
                      DesignTokens.grid8,
                    ),
                    child: Text(
                      '${search.results.length} results',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                      ),
                    ),
                  ),
                  Expanded(
                    child: search.results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 48,
                                    color: theme.textTheme.bodySmall?.color?.withAlpha(80)),
                                const SizedBox(height: 16),
                                Text('No results found',
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: search.results.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final result = search.results[index];
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.menu_book, color: theme.colorScheme.primary),
                                ),
                                title: Text(result.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(result.author,
                                        style: theme.textTheme.bodySmall),
                                    Text(result.snippet,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                trailing: Text(result.chapter,
                                    style: theme.textTheme.labelSmall),
                                onTap: () {
                                  final library = context.read<LibraryProvider>();
                                  final book = library.books.where((b) => b.id == result.bookId).firstOrNull;
                                  if (book != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReaderScreen(book: book),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
