import 'package:pks_12/api/product_api.dart';
import 'package:pks_12/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cart_bloc/cart_bloc.dart';
import '../cart_bloc/cart_state.dart';
import '../models/product.dart';
import '../widgets/cart_product_card.dart';



class CartPage extends StatelessWidget {
  final ProductApi productApi;

  const CartPage({
    Key? key,
    required this.productApi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return _buildScaffold(context, state.carts);
      },
    );
  }

  Future<Product?> getProduct(int productId) async {
    try {
      return await productApi.getProduct(productId);
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<int> calculateTotal(List<Cart> carts) async {
    int total = 0;
    for (var cart in carts) {
      Product? product = await getProduct(cart.productId);
      if (product != null) {
        total += product.price * cart.quantity;
      }
    }
    return total;
  }

  Widget _buildScaffold(BuildContext context, List<Cart> carts) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Корзина"),
        ),
        body: carts.isEmpty
            ? const Center(child: Text("Корзина пуста"))
            : Stack(
          children: [
            ListView.builder(
              itemCount: carts.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<Product?>(
                  future: getProduct(carts[index].productId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return CartProductCard(
                        product: snapshot.data!,
                        quantity: carts[index].quantity,
                      );
                    } else {
                      return const Text('Product not found');
                    }
                  },
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight - 55,
              child: FutureBuilder<int>(
                future: calculateTotal(carts),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    int total = snapshot.data ?? 0;
                    return Container(
                      padding: EdgeInsets.all(16),
                      color: const Color(0xFF504BFF),
                      child: Text(
                        'Итого: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        )
    );
  }
}