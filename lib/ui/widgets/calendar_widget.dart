import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pandora_snap/domain/models/user_model.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/screens/day_details_screen.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _dataExibida;
  late Set<DateTime> _datasComFotos;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _dataExibida = DateTime.now();
    initializeDateFormatting('pt_BR');
    currentUser = UserRepository().currentUser;
    _datasComFotos = PhotoRepository().getDatesWithPhotos(currentUser);
  }

  void _mesAnterior() {
    setState(() {
      _dataExibida = DateTime(_dataExibida.year, _dataExibida.month - 1, 1);
    });
  }

  void _mesSeguinte() {
    setState(() {
      _dataExibida = DateTime(_dataExibida.year, _dataExibida.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final diasNoMes = DateUtils.getDaysInMonth(_dataExibida.year, _dataExibida.month);
    final primeiroDiaDoMes = DateTime(_dataExibida.year, _dataExibida.month, 1);
    final diaDaSemanaInicio = primeiroDiaDoMes.weekday % 7;
    final diasDaSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final agora = DateTime.now();
    final ehMesAtualOuFuturo = _dataExibida.year > agora.year || (_dataExibida.year == agora.year && _dataExibida.month >= agora.month);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _mesAnterior,
              ),
              Text(
                DateFormat('MMMM y', 'pt_BR').format(_dataExibida),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: ehMesAtualOuFuturo ? null : _mesSeguinte,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: diasDaSemana.map((dia) => Expanded(child: Center(child: Text(dia, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))))).toList(),
          ),
          const Divider(),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: diasNoMes + diaDaSemanaInicio,
            itemBuilder: (context, index) {
              if (index < diaDaSemanaInicio) {
                return const SizedBox.shrink();
              }

              final dia = index - diaDaSemanaInicio + 1;
              final dataAtual = DateTime(_dataExibida.year, _dataExibida.month, dia);
              final temFoto = _datasComFotos.contains(dataAtual);

              return InkWell(
                onTap: () {
                  if (temFoto) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayDetailsScreen(date: dataAtual),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: temFoto ? Colors.amber : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$dia',
                      style: TextStyle(fontWeight: temFoto ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
