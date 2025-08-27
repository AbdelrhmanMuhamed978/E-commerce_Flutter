import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const ResponsiveWrapper(child: SplashScreen()),
      routes: {
        '/login': (context) => const ResponsiveWrapper(child: LoginScreen()),
        '/home': (context) => const ResponsiveWrapper(child: HomeScreen()),
        '/cart': (context) => const ResponsiveWrapper(child: CartScreen()),
        '/checkout': (context) =>
            const ResponsiveWrapper(child: CheckoutScreen()),
        '/orders': (context) => const ResponsiveWrapper(child: OrdersScreen()),
        '/profile': (context) =>
            const ResponsiveWrapper(child: ProfileScreen()),
        '/admin': (context) => const ResponsiveWrapper(child: AdminDashboard()),
      },
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we're on web
        if (kIsWeb) {
          return _buildWebLayout(context, constraints);
        } else {
          return _buildMobileLayout(context, constraints);
        }
      },
    );
  }

  Widget _buildWebLayout(BuildContext context, BoxConstraints constraints) {
    final screenHeight = constraints.maxHeight;

    // Phone dimensions for web
    final phoneWidth = 390.0; // iPhone 14 Pro width
    final phoneHeight = screenHeight * 0.9; // 90% of screen height

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: phoneWidth,
          height: phoneHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(phoneWidth - 16, phoneHeight - 16),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Ensure the app adapts to different screen sizes
        textScaleFactor: _calculateTextScaleFactor(constraints),
      ),
      child: child,
    );
  }

  double _calculateTextScaleFactor(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    // Base scale factor calculation based on screen size
    if (width < 360) {
      // Small phones
      return 0.85;
    } else if (width > 600) {
      // Tablets
      return 1.1;
    } else if (height < 600) {
      // Very short screens
      return 0.9;
    } else {
      // Normal phones
      return 1.0;
    }
  }
}
