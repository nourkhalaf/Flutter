import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/providers/product.dart';
import 'package:real_shop/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _edittedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      String? productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _edittedProduct = Provider.of<Products>(context).findById(productId);
        _initialValues = {
          'title': _edittedProduct.title,
          'description': _edittedProduct.description,
          'price': _edittedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _edittedProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlController.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.startsWith('.jpg') &&
              !_imageUrlController.text.startsWith('.jpeg'))) {
        return;
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (!_edittedProduct.id.isEmpty) {
      print('here...................');
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_edittedProduct.id, _edittedProduct);
    } else {
      try {
        print('here2...................');

        await Provider.of<Products>(context, listen: false)
            .addProduct(_edittedProduct);
      } catch (e) {
        print(e);
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured!'),
                  content: Text('Something went wrong.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Okay'),
                    )
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initialValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: ((value) {
                          if (value!.isEmpty)
                            return 'Please provide a value.';
                          else
                            return null;
                        }),
                        onSaved: ((newValue) {
                          _edittedProduct = Product(
                              id: _edittedProduct.id,
                              title: newValue!,
                              description: _edittedProduct.description,
                              price: _edittedProduct.price,
                              imageUrl: _edittedProduct.imageUrl,
                              isFavorite: _edittedProduct.isFavorite);
                        }),
                      ),
                      TextFormField(
                        initialValue: _initialValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        focusNode: _priceFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: ((value) {
                          if (value!.isEmpty) return 'Please provide a value.';
                          if (double.tryParse(value) ==
                              null) //if can not parse value to double , it return null
                            return 'Please provide a valid value.';
                          if (double.parse(value) <= 0)
                            return 'Please provide a valid value.';
                          else
                            return null;
                        }),
                        onSaved: ((newValue) {
                          _edittedProduct = Product(
                              id: _edittedProduct.id,
                              title: _edittedProduct.title,
                              description: _edittedProduct.description,
                              price: double.parse(newValue!),
                              imageUrl: _edittedProduct.imageUrl,
                              isFavorite: _edittedProduct.isFavorite);
                        }),
                      ),
                      TextFormField(
                        initialValue: _initialValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: ((value) {
                          if (value!.isEmpty) return 'Please provide a value.';
                          if (value.length < 10)
                            return 'Should be at least 10 characters long.';
                          else
                            return null;
                        }),
                        onSaved: ((newValue) {
                          _edittedProduct = Product(
                              id: _edittedProduct.id,
                              title: _edittedProduct.title,
                              description: newValue!,
                              price: _edittedProduct.price,
                              imageUrl: _edittedProduct.imageUrl,
                              isFavorite: _edittedProduct.isFavorite);
                        }),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter an Url')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller:
                                  _imageUrlController, //can not use initial value with controller
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.multiline,
                              focusNode: _imageUrlFocusNode,
                              validator: ((value) {
                                if (value!.isEmpty)
                                  return 'Please provide an url.';
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https'))
                                  return 'Please provide a valid url.';
                                if (!value.endsWith('png') &&
                                    !value.endsWith('jpg') &&
                                    !value.endsWith('jpeg'))
                                  return 'Please provide a valid url.';
                                else
                                  return null;
                              }),
                              onSaved: ((newValue) {
                                _edittedProduct = Product(
                                    id: _edittedProduct.id,
                                    title: _edittedProduct.title,
                                    description: _edittedProduct.description,
                                    price: _edittedProduct.price,
                                    imageUrl: newValue!,
                                    isFavorite: _edittedProduct.isFavorite);
                              }),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
