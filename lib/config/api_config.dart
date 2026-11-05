/// Alamat backend PHP. Override melalui config/dev.json atau --dart-define.
class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.100.109/studybuddy',
  );

  // Hilangkan garis miring di akhir agar endpoint tidak memiliki // ganda.
  static String get baseUrl =>
      _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
}
