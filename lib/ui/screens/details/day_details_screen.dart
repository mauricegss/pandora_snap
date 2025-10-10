import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';

class DayDetailsScreen extends StatelessWidget {
  final List<Photo> photos;

  const DayDetailsScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fotos do Dia'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Nenhuma foto encontrada para este dia.')),
      );
    }

    final date = photos.first.date;
    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fotos de $formattedDate'),
        centerTitle: true,
      ),
      
      body: PhotoGridView(photoList: photos),
    );
  }
}