import 'package:flutter/material.dart';
import 'home_page.dart';
import 'bank_page.dart';
import 'crud_page.dart';
import 'exchange_page.dart';
import 'profile_page.dart';
import 'report_page.dart';

/// Halaman utama dengan BottomNavigationBar 5 tab.
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});
  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _selectedIndex = 0;
  final List<int> _tabHistory = [0];

  List<Widget> get _pages => [
    HomePage(onTabChanged: _onItemTapped),
    const BankPage(),
    const CrudPage(),
    const ExchangePage(),
    const ProfilePage(),
  ];

  final List<String> _titles = [
    'Home',
    'Data Bank',
    'Dompetku',
    'Kurs Mata Uang',
    'Profil',
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _tabHistory.add(index);
        _selectedIndex = index;
      });
    }
  }

  void _goBack() {
    if (_tabHistory.length > 1) {
      _tabHistory.removeLast();
      setState(() => _selectedIndex = _tabHistory.last);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = _tabHistory.length > 1;

    return PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          title: Text(
            _titles[_selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: canGoBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Kembali',
                  onPressed: _goBack,
                )
              : null,
          actions: [
            // Tombol Laporan (buka halaman terpisah)
            if (_selectedIndex == 2) // Hanya tampil di tab Dompetku
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                tooltip: 'Laporan Keuangan',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReportPage()),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.home_rounded),
              tooltip: 'Ke Halaman Utama',
              onPressed: () {
                setState(() {
                  _tabHistory.clear();
                  _tabHistory.add(0);
                  _selectedIndex = 0;
                });
              },
            ),
          ],
          elevation: 0,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF1565C0),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance_rounded),
              label: 'Bank',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Dompetku',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.currency_exchange_rounded),
              activeIcon: Icon(Icons.currency_exchange_rounded),
              label: 'Kurs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
