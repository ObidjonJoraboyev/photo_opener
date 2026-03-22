double height = 0;
double width = 0;

extension ScreenSizeExtension on num {
  /// Responsive height based on screen height (812pt design height).
  /// Falls back to 1:1 scale when not yet initialized.
  double get h => this * (height > 0 ? height : 812) / 812;

  /// Responsive width based on screen width (375pt design width).
  /// Falls back to 1:1 scale when not yet initialized.
  double get w => this * (width > 0 ? width : 375) / 375;

  /// Responsive radius based on screen width
  double get r => this * (width > 0 ? width : 375) / 375;

  /// Responsive font size based on screen width
  double get sp => this * (width > 0 ? width : 375) / 375;
}
