import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect_mobile/src/app.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://nkmsjhreojoepqpdsxnh.supabase.co',
    anonKey: 'sb_publishable_l0rMDN4CmpLPifwa3QpgoA_wBYzL5hy',
  );
  
  runApp(
    const ProviderScope(
      child: MediConnectApp(),
    ),
  );
}
