import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/ui/screens/home/calendar_viewmodel.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with AutomaticKeepAliveClientMixin {
  late DateTime _dataExibida;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dataExibida = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserRepository>().currentUser;
      context.read<CalendarViewModel>().fetchData(user);
    });
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
    super.build(context);
    final viewModel = context.watch<CalendarViewModel>();

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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: ehMesAtualOuFuturo ? null : _mesSeguinte,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: diasDaSemana
                .map((dia) => Expanded(
                    child: Center(
                        child: Text(dia,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)))))
                .toList(),
          ),
          const Divider(),
          if (viewModel.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: diasNoMes + diaDaSemanaInicio,
              itemBuilder: (context, index) {
                if (index < diaDaSemanaInicio) {
                  return const SizedBox.shrink();
                }

                final dia = index - diaDaSemanaInicio + 1;
                final dataAtual =
                    DateTime(_dataExibida.year, _dataExibida.month, dia);
                final temFoto = viewModel.datesWithPhotos.contains(dataAtual);

                return InkWell(
                  onTap: () {
                    if (temFoto) {
                      context.pushNamed(AppRoutes.dayDetails.name, extra: dataAtual);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              temFoto ? Colors.amber : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$dia',
                        style: TextStyle(
                            fontWeight:
                                temFoto ? FontWeight.bold : FontWeight.normal),
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