class HiveTypeIds {
  HiveTypeIds._();

  static const int event = 0;
  static const int category = 1;
  static const int product = 2;
  static const int cartItem = 3;
  static const int transaction = 4;
  static const int transactionItem = 5;
  static const int appSettings = 6;
  static const int paymentMethod = 7;
}

class HiveBoxes {
  HiveBoxes._();

  static const String events = 'events';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String transactions = 'transactions';
  static const String transactionItems = 'transaction_items';
  static const String cartItems = 'cart_items';
  static const String settings = 'settings';
  static const String meta = 'meta';
}

class MetaKeys {
  MetaKeys._();

  static const String initialized = 'initialized';
  static const String currentEventId = 'currentEventId';
  static const String receiptCounter = 'receiptCounter';
  static const String categoryCollapse = 'categoryCollapse';
  static const String authPasswordHash = 'authPasswordHash';
  static const String authPasswordSet = 'authPasswordSet';
  static const String authBiometricEnabled = 'authBiometricEnabled';
  static const String authLastPausedAt = 'authLastPausedAt';
}
