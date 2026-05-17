import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import '../service/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String type;
  final int id;

  const DetailScreen({super.key, required this.type, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Article? _article;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final article = await ApiService.fetchDetail(widget.type, widget.id);
      setState(() {
        _article = article;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case 'articles':
        return 'News Detail';
      case 'blogs':
        return 'Blog Detail';
      case 'reports':
        return 'Report Detail';
      default:
        return 'Detail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat data',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadDetail();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _buildDetailContent(),
      floatingActionButton: _article != null && _article!.url.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _launchUrl(_article!.url),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('See more...'),
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildDetailContent() {
    final article = _article!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: article.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                height: 220,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (ctx, url, err) => Container(
                height: 220,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image,
                    size: 60, color: Colors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    if (article.newsSite.isNotEmpty) ...[
                      Icon(Icons.source, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        article.newsSite,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(article.publishedAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                if (article.summary.isNotEmpty)
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  )
                else
                  Text(
                    'Tidak ada ringkasan tersedia.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}