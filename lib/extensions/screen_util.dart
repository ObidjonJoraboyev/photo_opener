double height = 0;
double width = 0;

extension ScreenSizeExtension on num {
  /// Responsive height based on screen height
  double get h => this * height / 812;

  /// Responsive width based on screen width
  double get w => this * width / 375;

  /// Responsive radius based on screen width
  double get r => this * width / 375;

  /// Responsive font size based on screen width
  double get sp => this * width / 375;
}
