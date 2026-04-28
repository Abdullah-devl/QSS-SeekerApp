import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/widgets/service_card.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/features/home/services/view/service_details_view.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';
import 'package:seeker/features/search/viewmodels/search_viewmodel.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';

/// 📂 اسم الملف: search_view.dart
/// 📝 الوصف: واجهة البحث المتقدم والفلترة.

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✍️ تعبئة مربع البحث بالكلمة القادمة من الصفحة الرئيسية (إن وجدت)
    final viewModel = context.read<SearchViewModel>();
    _searchController.text = viewModel.query;

    // 🚩 إذا تم طلب فتح الفلاتر من الصفحة الرئيسية، نفتحها الآن
    if (viewModel.shouldOpenFilters) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFilterBottomSheet(context);
        viewModel.clearFiltersTrigger();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            context.tr('search_title'),
            style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _showFilterBottomSheet(context),
              icon: Icon(Icons.tune_rounded, color: colors.primary),
            ),
          ],
        ),
        body: Column(
          children: [
            // 🔍 شريط البحث العلوي
            _buildSearchInput(context),

            // 📜 قائمة النتائج
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<SearchViewModel>().performSearch(),
                color: colors.primary,
                child: Consumer<SearchViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      );
                    }

                    if (viewModel.errorMessage != null) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Center(
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(color: colors.error),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (viewModel.results.isEmpty && viewModel.query.isNotEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _buildEmptyState(context),
                        ],
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
                      itemCount: viewModel.results.length,
                      itemBuilder: (context, index) {
                        final service = viewModel.results[index];
                        return ServiceCard(
                          service: service,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (context) => ServiceDetailsViewModel(
                                    context.read<HomeRepository>(),
                                  ),
                                  child:
                                      ServiceDetailsView(initialService: service),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSearchInput(BuildContext context) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: colors.text),
        onSubmitted: (value) {
          context.read<SearchViewModel>().setQuery(value);
          context.read<SearchViewModel>().performSearch();
        },
        decoration: InputDecoration(
          hintText: context.tr('searchHint'),
          hintStyle: TextStyle(color: colors.textSub.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search, color: colors.textSub),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colors.textSub),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchViewModel>().resetFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: colors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.qsColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: colors.textSub.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            context.tr('no_results'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('no_results_desc'),
            style: TextStyle(color: colors.textSub),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final viewModel = context.read<SearchViewModel>();
    final categories = context.read<HomeViewModel>().categories;
    final colors = context.qsColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('filters'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          viewModel.resetFilters();
                          Navigator.pop(context);
                        },
                        child: Text(
                          context.tr('reset_filters'),
                          style: TextStyle(color: colors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // القسم
                  Text(
                    context.tr('category'),
                    style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    dropdownColor: colors.background,
                    style: TextStyle(color: colors.text),
                    value: viewModel.selectedCategoryId,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          context.tr('seeAll'),
                          style: TextStyle(color: colors.text),
                        ),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, style: TextStyle(color: colors.text)),
                        ),
                      ),
                    ],
                    onChanged: (val) => viewModel.setCategory(val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.textSub.withValues(alpha: 0.1)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // نطاق السعر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('price_range'),
                        style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
                      ),
                      Text(
                        '${viewModel.minPrice?.toInt() ?? 0} - ${(viewModel.maxPrice == null || viewModel.maxPrice == 100000) ? context.tr('no_max_limit') : viewModel.maxPrice?.toInt().toString()} ${context.tr('currency_sar')}',
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: RangeValues(
                      viewModel.minPrice ?? 0,
                      viewModel.maxPrice ?? 100000,
                    ),
                    min: 0,
                    max: 100000,
                    divisions: 200,
                    activeColor: colors.primary,
                    inactiveColor: colors.primary.withValues(alpha: 0.2),
                    labels: RangeLabels(
                      '${viewModel.minPrice?.toInt() ?? 0}',
                      viewModel.maxPrice == 100000
                          ? context.tr('no_max_limit')
                          : '${viewModel.maxPrice?.toInt() ?? 100000}',
                    ),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        viewModel.setPriceRange(values.start, values.end);
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      viewModel.performSearch();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.tr('apply_filters'),
                      style: TextStyle(color: colors.background, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
