import 'dart:convert';
import 'dart:io';

class CurrencyConverter {
  static Map<String, double>? _cachedRates;
  static DateTime? _lastFetch;

  static const Map<String, double> _fallbackRates = {
    'USD': 16200.0,
    'GBP': 20300.0,
    'JPY': 110.0,
  };

  static Future<void> _fetchRates() async {
    if (_cachedRates != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inHours < 1) return;

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final req = await client.getUrl(
        Uri.parse('https://api.frankfurter.app/latest?from=IDR&to=USD,GBP,JPY'),
      );
      final res = await req.close().timeout(const Duration(seconds: 5));
      final body = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        _cachedRates = {
          'USD': 1.0 / (rates['USD'] as num).toDouble(),
          'GBP': 1.0 / (rates['GBP'] as num).toDouble(),
          'JPY': 1.0 / (rates['JPY'] as num).toDouble(),
        };
        _lastFetch = DateTime.now();
      }
    } catch (_) {
      // Gunakan fallback
    }
  }

  static Future<Map<String, String>> convertFromIdr(int amount) async {
    await _fetchRates();
    return convertFromIdrSync(amount);
  }

  static Map<String, String> convertFromIdrSync(int amount) {
    final rates = _cachedRates ?? _fallbackRates;
    return {
      'IDR': 'Rp${_formatIdr(amount.toDouble())}',
      'USD': '\$${(amount / rates['USD']!).toStringAsFixed(2)}',
      'GBP': '£${(amount / rates['GBP']!).toStringAsFixed(2)}',
      'JPY': '¥${(amount / rates['JPY']!).toStringAsFixed(0)}',
    };
  }

  static bool get isUsingLiveRate => _cachedRates != null;

  static String _formatIdr(double value) {
    final raw = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final index = raw.length - i;
      buffer.write(raw[i]);
      if (index > 1 && index % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }
}