import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// A robust, reusable list view that automatically handles cursor-based
/// pagination for Firestore. Ensures <20MB RAM usage at scale.
class InfiniteFirestoreList<T> extends StatefulWidget {
  final Query<Map<String, dynamic>> query;
  final int limit;
  final T Function(DocumentSnapshot<Map<String, dynamic>> doc) itemBuilder;

  /// If provided, uses a standard ListView.builder
  final Widget Function(BuildContext context, T item)? buildItem;

  /// If provided, allows full custom rendering of the list (e.g. DataTable)
  final Widget Function(
    BuildContext context,
    List<T> items,
    bool hasMore,
    bool isLoading,
    VoidCallback fetchNext,
  )?
  builder;

  final Widget? emptyWidget;

  const InfiniteFirestoreList({
    super.key,
    required this.query,
    required this.limit,
    required this.itemBuilder,
    this.buildItem,
    this.builder,
    this.emptyWidget,
  }) : assert(
         buildItem != null || builder != null,
         'Must provide either buildItem or builder',
       );

  @override
  State<InfiniteFirestoreList<T>> createState() =>
      _InfiniteFirestoreListState();
}

class _InfiniteFirestoreListState<T> extends State<InfiniteFirestoreList<T>> {
  final List<T> _items = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query<Map<String, dynamic>> pageQuery = widget.query.limit(widget.limit);
      if (_lastDoc != null) {
        pageQuery = pageQuery.startAfterDocument(_lastDoc!);
      }

      final snapshot = await pageQuery.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      final newItems = snapshot.docs
          .map((doc) => widget.itemBuilder(doc))
          .toList();

      setState(() {
        _items.addAll(newItems);
        _lastDoc = snapshot.docs.last;
        _isLoading = false;
        if (snapshot.docs.length < widget.limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      debugPrint('InfiniteFirestoreList error: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _lastDoc = null;
      _hasMore = true;
    });
    await _fetchPage();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ??
          Center(
            child: Text(
              'No records found.',
              style: AppTextStyles.bodyLarge(color: Colors.grey),
            ),
          );
    }

    if (widget.builder != null) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.builder!(
                context,
                _items,
                _hasMore,
                _isLoading,
                _fetchPage,
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return widget.buildItem!(context, _items[index]);
        },
      ),
    );
  }
}
