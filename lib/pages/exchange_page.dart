import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Halaman Currency Exchange — konversi mata uang real-time via Frankfurter API.
class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});
  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  final TextEditingController _amountCtrl = TextEditingController(text: '1');
  Map<String, String> _currencies = {};
  bool _isLoadingCurrencies = true;
  bool _isConverting = false;
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  double? _result;
  String? _date;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  /// Fetch daftar mata uang dari API
  Future<void> _fetchCurrencies() async {
    try {
      final res = await http.get(
          Uri.parse('https://api.frankfurter.dev/v1/currencies'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        setState(() {
          _currencies = data.map((k, v) => MapEntry(k, v.toString()));
          _isLoadingCurrencies = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Gagal memuat daftar mata uang';
        _isLoadingCurrencies = false;
      });
    }
  }

  /// Konversi mata uang
  Future<void> _convert() async {
    if (_fromCurrency == _toCurrency) {
      setState(() {
        _result = double.tryParse(_amountCtrl.text) ?? 0;
        _date = 'Mata uang sama';
      });
      return;
    }

    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    setState(() {
      _isConverting = true;
      _errorMsg = '';
    });

    try {
      final res = await http.get(Uri.parse(
          'https://api.frankfurter.dev/v1/latest?amount=$amount&from=$_fromCurrency&to=$_toCurrency'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final rates = data['rates'] as Map<String, dynamic>;
        setState(() {
          _result = (rates[_toCurrency] as num).toDouble();
          _date = data['date'] ?? '';
          _isConverting = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Gagal konversi (${res.statusCode})';
          _isConverting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Koneksi gagal. Cek internet Anda.';
        _isConverting = false;
      });
    }
  }

  /// Swap mata uang
  void _swap() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _result = null;
    });
  }

  String _formatNumber(double val) {
    if (val >= 1) {
      final str = val.toStringAsFixed(2);
      final parts = str.split('.');
      final chars = parts[0].split('').reversed.toList();
      final result = <String>[];
      for (var i = 0; i < chars.length; i++) {
        if (i > 0 && i % 3 == 0) result.add('.');
        result.add(chars[i]);
      }
      return '${result.reversed.join()},${parts[1]}';
    }
    return val.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: _isLoadingCurrencies
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Header ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.currency_exchange_rounded,
                            size: 40, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Kurs Mata Uang',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Data dari European Central Bank',
                            style: TextStyle(
                                fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Input Card ──
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Amount input
                          TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Jumlah',
                              prefixIcon:
                                  const Icon(Icons.payments_rounded),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // From → To with swap
                          Row(
                            children: [
                              Expanded(child: _buildDropdown(
                                label: 'Dari',
                                value: _fromCurrency,
                                onChanged: (v) => setState(() {
                                  _fromCurrency = v!;
                                  _result = null;
                                }),
                              )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: IconButton(
                                  onPressed: _swap,
                                  icon: const Icon(
                                      Icons.swap_horiz_rounded,
                                      color: Color(0xFF1565C0),
                                      size: 28),
                                  tooltip: 'Tukar',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF1565C0)
                                            .withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              Expanded(child: _buildDropdown(
                                label: 'Ke',
                                value: _toCurrency,
                                onChanged: (v) => setState(() {
                                  _toCurrency = v!;
                                  _result = null;
                                }),
                              )),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Convert button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isConverting ? null : _convert,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              icon: _isConverting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                  : const Icon(
                                      Icons.calculate_rounded),
                              label: const Text('Konversi'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Error ──
                  if (_errorMsg.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_errorMsg,
                          style: const TextStyle(color: Colors.red)),
                    ),

                  // ── Result ──
                  if (_result != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                '${_amountCtrl.text} $_fromCurrency =',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_formatNumber(_result!)} $_toCurrency',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              if (_date != null && _date!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Kurs tanggal: $_date',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: _currencies.containsKey(value) ? value : _currencies.keys.first,
      items: _currencies.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.key, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      isExpanded: true,
    );
  }
}
