import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class Navbar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      backgroundColor: Colors.white,
      color: Colors.grey.shade600,
      activeColor: Colors.blueAccent,
      elevation: 5,
      height: 60,
      style: TabStyle.react, // ✅ aman untuk 4 item
      items: const [
        TabItem(icon: Icons.home, title: 'Beranda'),
        TabItem(icon: Icons.assignment, title: 'Aktivitas'),
        TabItem(icon: Icons.history, title: 'Riwayat'),
        TabItem(icon: Icons.person, title: 'Profil'),
      ],
      initialActiveIndex: widget.selectedIndex,
      onTap: widget.onItemTapped,
    );
  }
}
