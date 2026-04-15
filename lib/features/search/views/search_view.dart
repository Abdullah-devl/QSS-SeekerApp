import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/service_card.dart';
import '../../home/viewmodels/home_view_model.dart';
import '../../home/services/view/service_details_view.dart';
import '../../home/services/viewmodels/service_details_view_model.dart';
import '../../home/repositories/home_repository.dart';
import '../viewmodels/search_viewmodel.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FB),
        appBar: AppBar(
          title: Text(context.tr('search_title')),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => _showFilterBottomSheet(context),
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF1CB0F6)),
            ),
          ],
        ),
        body: Column(
          children: [
            // 🔍 شريط البحث العلوي
            _buildSearchInput(context),

            // 📜 قائمة النتائج
            Expanded(
              child: Consumer<SearchViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.errorMessage != null) {
                    return Center(child: Text(viewModel.errorMessage!));
                  }

                  if (viewModel.results.isEmpty && viewModel.query.isNotEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
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
                                child: ServiceDetailsView(initialService: service),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          context.read<SearchViewModel>().setQuery(value);
          context.read<SearchViewModel>().performSearch();
        },
        decoration: InputDecoration(
          hintText: context.tr('searchHint'),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchViewModel>().resetFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            context.tr('no_results'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('no_results_desc'),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final viewModel = context.read<SearchViewModel>();
    final categories = context.read<HomeViewModel>().categories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          viewModel.resetFilters();
                          Navigator.pop(context);
                        },
                        child: Text(context.tr('reset_filters')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // القسم
                  Text(context.tr('category'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: viewModel.selectedCategoryId,
                    items: [
                      DropdownMenuItem(value: null, child: Text(context.tr('seeAll'))),
                      ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (val) => viewModel.setCategory(val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // نطاق السعر
                  Text(context.tr('price_range'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: context.tr('min_price'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (v) => viewModel.setPriceRange(double.tryParse(v), viewModel.maxPrice),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: context.tr('max_price'),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (v) => viewModel.setPriceRange(viewModel.minPrice, double.tryParse(v)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      viewModel.performSearch();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB0F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(context.tr('apply_filters'), style: const TextStyle(color: Colors.white)),
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
