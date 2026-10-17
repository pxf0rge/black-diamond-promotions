import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/transaction_provider.dart';

/// Reloads catalog, cart, and transactions after switching the current event.
Future<void> reloadEventScopedData(BuildContext context) async {
  final navIndex = context.read<NavigationProvider>().currentIndex;
  final catalog = context.read<CatalogProvider>();
  final cart = context.read<CartProvider>();
  final transactions = context.read<TransactionProvider>();

  if (navIndex == 2) {
    await catalog.reloadForManage();
  } else {
    await catalog.reloadForSell();
  }
  await cart.init();
  await transactions.refresh();
}
