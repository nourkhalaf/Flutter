import 'package:flutter/material.dart';
import 'package:real_shop/providers/auth.dart';
import 'package:real_shop/providers/cart.dart';
import 'package:real_shop/providers/orders.dart';
import 'package:real_shop/providers/products.dart';
import 'package:real_shop/screens/auth_screen.dart';
import 'package:real_shop/screens/cart_screen.dart';
import 'package:real_shop/screens/edit_product_screen.dart';
import 'package:real_shop/screens/orders_screen.dart';
import 'package:real_shop/screens/product_detail_screen.dart';
import 'package:real_shop/screens/product_overview_screen.dart';
import 'package:real_shop/screens/splash_screen.dart';
import 'package:real_shop/screens/user_products_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, authValue, previousProducts) => previousProducts!
            ..getData(
              authValue.token!,
              authValue.userId!,
              previousProducts.items,
            ),
        ),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, authValue, previousOrders) => previousOrders!
            ..getData(
              authValue.token!,
              authValue.userId!,
              previousOrders.orders,
            ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : Authscreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
            CartScreen.routeName: (_) => CartScreen(),
            EditProductScreen.routeName: (_) => EditProductScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            UserProductsScreen.routeName: (_) => UserProductsScreen(),
          },
        ),
      ),
    );
  }
}
