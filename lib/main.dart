import 'package:flutter/material.dart';
import 'package:pandora_snap/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  await Supabase.initialize(
    url: 'https://arimlekyqeyumnkqzkjk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyaW1sZWt5cWV5dW1ua3F6a2prIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2NjU4MTgsImV4cCI6MjA3NDI0MTgxOH0.zlE1WDVN8vjpK85Es_6cm2Iq3zswOsUd3ae3RBYrb30',
  );

  runApp(const App());
}

final supabase = Supabase.instance.client;