import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart';
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/ui/widgets/calendar_widget.dart';
import 'package:pandora_snap/ui/widgets/dog_card_widget.dart';

class HomeScreen extends StatefulWidget {

  final DogRepository dogRepository;
  final PhotoRepository photoRepository;

  const HomeScreen({
    super.key,
    required this.dogRepository,
    required this.photoRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<Dog> dogCollection;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUser = UserRepository().currentUser;
    
    List<Dog> unsortedDogs = widget.dogRepository.getDogs();

    unsortedDogs.sort((a, b) {
      final photoCountA = widget.photoRepository.getPhotosForDog(a.name, currentUser).length;
      final photoCountB = widget.photoRepository.getPhotosForDog(b.name, currentUser).length;
      final countCompare = photoCountB.compareTo(photoCountA);
      if (countCompare != 0) return countCompare;
      return a.name.compareTo(b.name);
    });

    dogCollection = unsortedDogs;
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
            UserRepository().logout();
            context.pushNamed(AppRoutes.auth.name);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.black,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          tabs: const [ Tab(text: 'Coleção'), Tab(text: 'Calendário'), ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ _buildColecaoView(), const CalendarWidget(), ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () {},
        child: const Icon(Icons.camera_alt_rounded),
      ),
    );
  }

  Widget _buildColecaoView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.95,
      ),
      itemCount: dogCollection.length,
      itemBuilder: (context, index) {
        final dog = dogCollection[index];

        final bool isCaptured = widget.photoRepository.getPhotosForDog(dog.name, currentUser).isNotEmpty;
        final coverPhotoUrl = widget.photoRepository.getLatestCoverPhotoForDog(dog.name, currentUser);

        return DogCard(
          dog: dog,
          isCaptured: isCaptured,
          coverPhotoUrl: coverPhotoUrl,
        );
      },
    );
  }
}
