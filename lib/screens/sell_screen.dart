import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/expandable_category.dart';
import '../widgets/order_summary_card.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().reloadForSell();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= AppConstants.largeTabletBreakpoint;

    return Scaffold(
      appBar: const AppHeader(),
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildProductArea(horizontalPadding: 24)),
        const OrderSummaryCard(useSidePanel: true),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        Expanded(child: _buildProductArea(horizontalPadding: 16)),
        const OrderSummaryCard(),
      ],
    );
  }

  Widget _buildProductArea({required double horizontalPadding}) {
    return Consumer2<CatalogProvider, CartProvider>(
      builder: (context, catalog, cart, _) {
        final categories = catalog.filteredCategories;

        if (catalog.errorMessage != null) {
          return Center(
            child: Text(
              catalog.errorMessage!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                8,
              ),
              child: CustomTextField(
                controller: _searchController,
                hintText: 'Search products...',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  catalog.setSearchQuery(value);
                  setState(() {});
                },
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          catalog.setSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
            Expanded(
              child: categories.isEmpty
                  ? (catalog.searchQuery.isNotEmpty
                        ? _EmptySearchState(
                            onClear: () {
                              _searchController.clear();
                              catalog.setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : const _EmptyCatalogState())
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        4,
                        horizontalPadding,
                        16,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ExpandableCategory(
                          category: category,
                          onToggle: () => catalog.toggleCategory(category.id),
                          getQuantity: cart.getQuantitySync,
                          onAdd: cart.addProduct,
                          onIncrement: cart.increment,
                          onDecrement: cart.decrement,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onClear, child: const Text('Clear search')),
        ],
      ),
    );
  }
}

class _EmptyCatalogState extends StatelessWidget {
  const _EmptyCatalogState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No products yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Go to Manage to create categories and add products.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
