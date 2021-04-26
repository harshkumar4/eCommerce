import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import '../screens/edit_products_screen.dart';

class UserProductsItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductsItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final snackbar = Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditProductsScreen.routeName,
                    arguments: id,
                  );
                }),
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
                onPressed: () {
                  Provider.of<Products>(context, listen: false)
                      .deleteProduct(id)
                      // .then((value) => null)
                      .catchError((_) {
                    snackbar.showSnackBar(
                      SnackBar(
                        content: Text(
                          _.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  });
                }),
          ],
        ),
      ),
    );
  }
}
