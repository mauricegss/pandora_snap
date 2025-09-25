import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/screens/home/calendar_screen.dart';
import 'package:pandora_snap/ui/screens/home/collection_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Logout'),
        content: const Text('Tem a certeza de que deseja sair?'),
        actions: [
          TextButton(
            child: const Text('CANCELAR'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('SAIR'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      if (mounted) {
        context.read<UserRepository>().logout();
        context.goNamed(AppRoutes.welcome.name);
      }
    }
  }

  void _openDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A dashboard será implementada aqui.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pandora Snap'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Fazer Logout',
          onPressed: _showLogoutDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Dashboard',
            onPressed: _openDashboard,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.black,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Coleção'),
            Tab(text: 'Calendário'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CollectionScreen(),
          CalendarScreen(),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () {
          // Câmera será implementada aqui
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          size: 28,
        ),
      ),
    );
  }
}