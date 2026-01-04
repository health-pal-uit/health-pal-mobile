import 'package:da1/src/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
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
        return MaterialApp.router(
          title: 'My App',
          routerConfig: AppRoutes.router,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          // darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
        );
      },
    );
  }
}
