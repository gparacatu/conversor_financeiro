import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var request = Uri.parse("https://api.hgbrasil.com/finance?key=c5d96a3c");

void main() async {
  runApp(
    MaterialApp(
      home: const Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar = 0;
  double euro = 0;

  void _realChanged(String text) {
    if (text.isNotEmpty) {
      try {
        text = decimalValidate(text);
        double real = double.parse(text);
        dollarController.text = (real / dollar).toStringAsFixed(2);
        euroController.text = (real / euro).toStringAsFixed(2);
      }catch(e){
        return;
    }
    }else {
      _clearAll();
      return;
    }
  }

  void _dollarChanged(String text) {
    if (text.isNotEmpty) {
      try {
        text = decimalValidate(text);
        double dollar = double.parse(text);
        realController.text = (dollar * this.dollar).toStringAsFixed(2);
        euroController.text =
            ((dollar * this.dollar) / euro).toStringAsFixed(2);
      }catch(e){
    return;
    }
    }else {
      _clearAll();
      return;
    }
  }

  void _euroChanged(String text) {
    if (text.isNotEmpty) {
      try{
      text = decimalValidate(text);
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dollarController.text =
          ((euro * this.euro) / dollar).toStringAsFixed(2);
      }catch(e){
        return;
      }
    }else {
      _clearAll();
      return;
    }
  }

  void _clearAll(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Conversor Financeiro Online"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    "Carregando dados online...",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Erro ao carregar dados online :(",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dollar =
                      snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        const Divider(),
                        buildText("Valor atual em relação ao real: USD: \$${dollar.toStringAsFixed(2)} | EUR: €${euro.toStringAsFixed(2)}"),
                        const Divider(),
                        buildText("Digite o valor para conversão"),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        const Divider(),
                        buildTextField(
                          "Dólares",
                          "US\$",
                          dollarController,
                          _dollarChanged,
                        ),
                        const Divider(),
                        buildTextField(
                          "Euros",
                          "€",
                          euroController,
                          _euroChanged,
                        ),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix,
    TextEditingController controllerIn, Function f) {
  return TextField(
    controller: controllerIn,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.amber,
      ),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: (t) {
      f(t);
    },
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}

Widget buildText(String textIn){
  return Text(
    textIn,
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 15,
    ),
    textAlign: TextAlign.center,
  );
}

String decimalValidate(String text){
  if(text.contains(",")){
    text = text.replaceAll(",", ".");
  }
  return text;
}