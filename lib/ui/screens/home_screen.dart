import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart';
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/screens/dog_details_screen.dart';
import 'package:pandora_snap/ui/screens/welcome_screen.dart';
import 'package:pandora_snap/ui/widgets/calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<Dog> dogCollection;
  final photoRepository = PhotoRepository();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUser = UserRepository().currentUser;
    
    List<Dog> unsortedDogs = DogRepository().getDogs();

    unsortedDogs.sort((a, b) {
      final photoCountA = photoRepository.getPhotosForDog(a.name, currentUser).length;
      final photoCountB = photoRepository.getPhotosForDog(b.name, currentUser).length;

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
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
        
        // A LÓGICA CORRETA ACONTECE AQUI:
        // 1. Verifica se o utilizador tem fotos deste cão.
        final bool isCaptured = photoRepository.getPhotosForDog(dog.name, currentUser).isNotEmpty;
        
        // 2. Pega a foto de capa (que será a imagem 'noImage' se não for capturado).
        final coverPhotoUrl = photoRepository.getLatestCoverPhotoForDog(dog.name, currentUser);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // 3. Só permite clicar se o cão tiver sido "capturado".
            onTap: () {
              if (isCaptured) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DogDetailsScreen(dog: dog),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    coverPhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    // 4. Mostra o nome do cão, mas com uma opacidade menor se não for capturado.
                    dog.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCaptured ? null : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
