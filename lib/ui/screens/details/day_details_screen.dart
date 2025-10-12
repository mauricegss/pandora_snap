import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandora_snap/ui/screens/home/calendar_viewmodel.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';
import 'package:provider/provider.dart';

class DayDetailsScreen extends StatelessWidget {
  final DateTime date;

  const DayDetailsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();
    final photos = viewModel.photosByDate[date] ?? [];

    if (photos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fotos do Dia'),
          centerTitle: true,
        ),
        body: const Center(child: Text('Nenhuma foto encontrada para este dia.')),
      );
    }

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