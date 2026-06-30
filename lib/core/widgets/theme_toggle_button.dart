import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/theme/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return IconButton(
      tooltip: 'Ganti Tema',
      onPressed: () {
        final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
        context.read<ThemeCubit>().changeTheme(newMode);
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: child.key == const ValueKey('moon')
                ? Tween<double>(begin: 0.5, end: 1.0).animate(animation)
                : Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: isDark
            ? const Icon(
                Icons.nightlight_round,
                key: ValueKey('moon'),
                color: Colors.amberAccent,
                size: 26,
              )
            : const Icon(
                Icons.wb_sunny_rounded,
                key: ValueKey('sun'),
                color: Colors.orange,
                size: 26,
              ),
      ),
    );
  }
}
