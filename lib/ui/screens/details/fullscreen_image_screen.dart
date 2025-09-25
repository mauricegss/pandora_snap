import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[_currentIndex];
    final formattedDate =
        DateFormat('dd/MM/yyyy', 'pt_BR').format(currentPhoto.date);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentPhoto.dogName} - $formattedDate'),
        centerTitle: true,
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
                  child: Image.network(widget.photos[index].url),
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