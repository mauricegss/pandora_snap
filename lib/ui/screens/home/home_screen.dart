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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pandora Snap'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.read<UserRepository>().logout();
            context.goNamed(AppRoutes.welcome.name);
          },
        ),
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
        onPressed: () {},
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Icon(Icons.camera_alt_rounded, size: 28,),
      ),
    );
  }
}