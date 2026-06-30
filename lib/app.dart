import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/router/app_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/theme/theme_cubit.dart';
import 'package:mobile_app/features/auth/application/auth_bloc.dart'; 
import 'package:mobile_app/injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'DurenKu', 
            
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode, 
            
            routerConfig: sl<AppRouter>().router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}