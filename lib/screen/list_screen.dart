import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import '../service/api_service.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  final String type;
  final String title;

  const ListScreen({super.key, required this.type, required this.title});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<Article> _articles = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newArticles = await ApiService.fetchList(
        widget.type,
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _articles.addAll(newArticles);
        _offset += _limit;
        _hasMore = newArticles.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _articles.clear();
      _offset = 0;
      _hasMore = true;
    });
    await _loadData();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _articles.isEmpty && !_isLoading
            ? const Center(
                child: Text(
                  'Tidak ada data',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _articles.length + (_isLoading ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == _articles.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildArticleCard(_articles[i]);
                },
              ),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailScreen(type: widget.type, id: article.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: article.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image,
                            size: 48, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image,
                          size: 48, color: Colors.grey),
                    ),
            ),

            // Konten
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (article.newsSite.isNotEmpty)
                    Text(
                      article.newsSite,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(article.publishedAt),
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF6C63FF),
                      ),
                    ],
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