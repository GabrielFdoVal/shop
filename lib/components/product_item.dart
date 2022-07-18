import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/excepitons/http_excepiton.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(product.imageUrl),
          ),
          title: Text(product.name),
          // ignore: sized_box_for_whitespace
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.product_form,
                      arguments: product,
                    );
                  },
                  icon: const Icon(Icons.edit),
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Tem certeza?"),
                        content: const Text("Quer remover o item do carrinho?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            },
                            child: const Text("Não"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
                            child: const Text("Sim"),
                          ),
                        ],
                      ),
                    ).then((c) async {
                      final bool _confirm = c ?? false;
                      if (_confirm) {
                        try {
                          await Provider.of<ProductList>(
                            context,
                            listen: false,
                          ).removeProduct(product.id);
                        } on HttpExcepiton catch (erro) {
                          msg.showSnackBar(
                            SnackBar(
                              content: Text(erro.toString()),
                            ),
                          );
                        }
                      }
                    });
                  },
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).errorColor,
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
