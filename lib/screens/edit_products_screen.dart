import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductsScreen extends StatefulWidget {
  static const routeName = '/edit-products';
  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _priceFocusNode = FocusNode();
  final _descNode = FocusNode();
  final _imageUrlNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _existingProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  var _isLoading = false;
  var _isInit = true;
  var _initValue = {
    'title': '',
    'price': '',
    'description': '',
  };

  @override
  void initState() {
    _imageUrlNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments;
      if (productId != null) {
        _existingProduct = Provider.of<Products>(context).findtById(productId);
        _initValue = {
          'title': _existingProduct.title,
          'description': _existingProduct.description,
          'price': _existingProduct.price.toString(),
        };
        _imageUrlController.text = _existingProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descNode.dispose();
    _imageUrlNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _onSubmit() {
    final _isValid = _form.currentState.validate();
    if (!_isValid) return;

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_existingProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProducts(_existingProduct.id, _existingProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      Provider.of<Products>(context, listen: false)
          .addItem(_existingProduct)
          .catchError((err) {
        return showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('An error!'),
                content: Text('Something went wrong...'),
                actions: [
                  RaisedButton(
                    child: Text('Ok'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  )
                ],
              );
            });
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
            ),
            onPressed: _onSubmit,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValue['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (value) => _existingProduct = Product(
                        title: value,
                        description: _existingProduct.description,
                        price: _existingProduct.price,
                        imageUrl: _existingProduct.imageUrl,
                        id: _existingProduct.id,
                        isFavourite: _existingProduct.isFavourite,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a title!';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_descNode),
                      onSaved: (value) => _existingProduct = Product(
                        id: _existingProduct.id,
                        isFavourite: _existingProduct.isFavourite,
                        title: _existingProduct.title,
                        description: _existingProduct.description,
                        price: double.parse(value),
                        imageUrl: _existingProduct.imageUrl,
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Please provide a price';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid amount';
                        if (double.parse(value) <= 0)
                          return 'Please enter a valid amount';
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descNode,
                      onSaved: (value) => _existingProduct = Product(
                        id: _existingProduct.id,
                        isFavourite: _existingProduct.isFavourite,
                        title: _existingProduct.title,
                        description: value,
                        price: _existingProduct.price,
                        imageUrl: _existingProduct.imageUrl,
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please provide a description!';
                        if (value.length < 10)
                          return 'Should be atleast 10 characters';
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Enter URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlNode,
                            onFieldSubmitted: (_) => _onSubmit(),
                            onSaved: (value) => _existingProduct = Product(
                              id: _existingProduct.id,
                              isFavourite: _existingProduct.isFavourite,
                              title: _existingProduct.title,
                              description: _existingProduct.description,
                              price: _existingProduct.price,
                              imageUrl: value,
                            ),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter an image URL';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Please enter a valid URL';
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg'))
                                return 'Please enter valid image URL';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
