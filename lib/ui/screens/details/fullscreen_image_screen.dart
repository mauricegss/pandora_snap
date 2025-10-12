import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/screens/home/calendar_viewmodel.dart';
import 'package:pandora_snap/ui/screens/home/collection_viewmodel.dart';
import 'package:provider/provider.dart';

class FullscreenImageScreen extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;

  const FullscreenImageScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageScreen> createState() => _FullscreenImageScreenState();
}

class _FullscreenImageScreenState extends State<FullscreenImageScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _deletePhoto() async {
    final photoToDelete = widget.photos[_currentIndex];
    final photoRepository = context.read<PhotoRepository>();
    final collectionViewModel = context.read<CollectionViewModel>();
    final calendarViewModel = context.read<CalendarViewModel>();
    final user = context.read<UserRepository>().currentUser;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Foto'),
        content: const Text('Tem a certeza de que deseja apagar esta foto? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('CANCELAR')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('APAGAR')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final imageUrl = photoToDelete.url;
        await photoRepository.deletePhotoById(photoToDelete.id);
        await CachedNetworkImage.evictFromCache(imageUrl);

        collectionViewModel.fetchData(user);
        calendarViewModel.fetchData(user);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto apagada com sucesso!'), backgroundColor: Colors.green),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao apagar a foto: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty || _currentIndex >= widget.photos.length) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Nenhuma foto para exibir.")),
      );
    }
    
    final currentPhoto = widget.photos[_currentIndex];
    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(currentPhoto.date);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentPhoto.dogName} - $formattedDate'),
        centerTitle: true,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Apagar Foto',
                  onPressed: _deletePhoto,
                ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Hero(
                tag: widget.photos[index].id,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.photos[index].url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentIndex > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              if (_currentIndex == 0) const SizedBox(width: 48),
              if (_currentIndex < widget.photos.length - 1)
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              if (_currentIndex == widget.photos.length - 1) const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}