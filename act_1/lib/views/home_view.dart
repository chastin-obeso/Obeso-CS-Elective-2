import 'package:flutter/material.dart';
import 'product_list_view.dart';
import '../widgets/herobanner.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        HeroBannerWidget(),
        Expanded(child: ProductListView()),
      ],
    );
  }
}