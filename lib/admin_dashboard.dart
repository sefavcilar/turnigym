import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TurniGym Yönetim Paneli")),
      body: Row(
        children: [
          // Sol Menü
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {},
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Panel'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Üyeler'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Ana İçerik
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatCard("Toplam Giriş", "124"),
                _buildStatCard("Şu An İçeride", "12"),
                const SizedBox(height: 20),
                const Text(
                  "Son Etkinlikler",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Canlı Giriş Logları
                const ListTile(
                  title: Text("Sefa Avcılar giriş yaptı"),
                  subtitle: Text("12:00"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
