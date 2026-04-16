import 'package:da1/src/config/theme/app_theme.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'config/routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        final authBloc = BlocProvider.of<AuthBloc>(context);
        return MaterialApp.router(
          title: 'My App',
          routerConfig: AppRoutes.createRouter(authBloc),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          // darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
        );
      },
    );
  }
}
