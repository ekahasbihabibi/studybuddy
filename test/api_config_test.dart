import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/config/api_config.dart';

void main() {
  test('API base URL supports overrides and removes trailing slashes', () {
    final uri = Uri.parse(ApiConfig.baseUrl);
    expect(uri.scheme, isIn(['http', 'https']));
    expect(uri.host, isNotEmpty);
    expect(ApiConfig.baseUrl.endsWith('/'), isFalse);
    expect(
      ApiConfig.baseUrl,
      const String.fromEnvironment(
        'EXPECTED_API_BASE_URL',
        defaultValue: 'http://192.168.100.109/studybuddy',
      ),
    );
  });
}
