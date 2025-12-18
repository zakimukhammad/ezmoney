import 'package:flutter/material.dart';

class IconHelper {
  /// Returns a constant IconData for known code points to support tree shaking.
  /// Dynamic IconData invocation breaks the Flutter build's tree shaker.
  static IconData getIcon(int codePoint) {
    // Map known code points to constants.
    // Explicit const constructors or Material Icons constants are required here.
    switch (codePoint) {
      case 0xe04f:
        return Icons.account_balance_wallet; // Wallet (Default Account)
      case 0xe57f:
        return Icons.star; // Star/Category (Default Category)

      // Add other commonly used icons here if needed, e.g.:
      // case 0xe88a: return Icons.home;

      default:
        // Use a fallback icon for unknown codes to prevent crash,
        // while still satisfying the compiler (constant return).
        // Note: The specific unknown icon won't be rendered correctly if tree-shaken out,
        // but at least the build will succeed.
        return Icons.help_outline;
    }
  }
}
