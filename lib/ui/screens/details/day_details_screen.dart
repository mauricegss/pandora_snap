import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';
import 'package:provider/provider.dart';

class DayDetailsScreen extends StatefulWidget {
  final DateTime date;

  const DayDetailsScreen({super.key, required this.date});

  @override
  State<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  @override
  Widget build(BuildContext context) {

    final User? currentUser = context.watch<UserRepository>().currentUser;
    final List<Photo> photoList =
        PhotoRepository().getPhotosForDate(widget.date, currentUser);

    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fotos de $formattedDate'),
        centerTitle: true,
      ),
      body: PhotoGridView(photoList: photoList),
    );
  }
}