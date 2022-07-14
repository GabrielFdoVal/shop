import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductFormPage> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlFocus = FocusNode();
  final _imageUrlControler = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _formData = Map<String, Object>();

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlControler.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.removeListener(updateImage);
    _imageUrlFocus.dispose();
  }

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValid = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWithFile =
        url.endsWith(".png") || url.endsWith(".jpg") || url.endsWith(".jpeg");
    return isValid && endsWithFile;
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    Provider.of<ProductList>(context, listen: false).saveProduct(_formData);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulário produto"),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nome",
                  //errorBorder: InputBorder.none,
                ),
                initialValue: _formData['name']?.toString(),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocus);
                },
                onSaved: (name) => _formData["name"] = name ?? "",
                validator: (_name) {
                  final name = _name ?? "";

                  if (name.trim().isEmpty) {
                    return "Nome é obrigatório.";
                  }

                  if (name.trim().length < 3) {
                    return "Nome precisa ter mais que 3 letras.";
                  }

                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Preço"),
                textInputAction: TextInputAction.next,
                initialValue: _formData['price']?.toString(),
                focusNode: _priceFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocus);
                },
                onSaved: (price) =>
                    _formData["price"] = double.parse(price ?? '0'),
                validator: (_price) {
                  final priceString = _price ?? '';
                  final price = double.parse(priceString);

                  if (price <= 0) {
                    return "Informe um preço válido";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Descrição"),
                focusNode: _descriptionFocus,
                initialValue: _formData['name']?.toString(),
                keyboardType: TextInputType.multiline,
                //textInputAction: TextInputAction.next,
                maxLines: 3,
                onSaved: (description) =>
                    _formData["description"] = description ?? "",
                validator: (_description) {
                  final description = _description ?? "";

                  if (description.trim().isEmpty) {
                    return "Descrição é obrigatório.";
                  }

                  if (description.trim().length < 10) {
                    return "Descrição precisa ter mais que 10 letras.";
                  }

                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: "URL da imagem"),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      focusNode: _imageUrlFocus,
                      controller: _imageUrlControler,
                      onSaved: (imageUrl) =>
                          _formData["imageUrl"] = imageUrl ?? "",
                      onFieldSubmitted: (_) => _submitForm(),
                      validator: (_imageUrl) {
                        final imageUrl = _imageUrl ?? '';
                        if (!isValidImageUrl(imageUrl)) {
                          return "Retorne uma URL válida";
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _imageUrlControler.text.isEmpty
                        ? const Text("Informe uma URL")
                        : FittedBox(
                            fit: BoxFit.cover,
                            child: Image.network(_imageUrlControler.text),
                          ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
