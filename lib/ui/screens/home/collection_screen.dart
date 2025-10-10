import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/screens/home/collection_viewmodel.dart';
import 'package:pandora_snap/ui/widgets/dog_card_widget.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserRepository>().currentUser;
      context.read<CollectionViewModel>().fetchData(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewModel = context.watch<CollectionViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.dogsWithPhotos.isEmpty) {
      return const Center(child: Text('Nenhum cão encontrado.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.95,
      ),
      itemCount: viewModel.dogsWithPhotos.length,
      itemBuilder: (context, index) {
        final dogData = viewModel.dogsWithPhotos[index];
        return DogCard(
          dog: dogData.dog,
          isCaptured: dogData.isCaptured,
          coverPhotoUrl: dogData.coverPhotoUrl,
          photos: dogData.photos,
        );
      },
    );
  }
}