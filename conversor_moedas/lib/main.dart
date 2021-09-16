import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const REQUEST  = "https://api.hgbrasil.com/finance?format=json-cors&key=3e12a650";

void main() async{

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amberAccent,
      primaryColor: Colors.white
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar, euro;

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar*this.dollar).toStringAsFixed(2);
    euroController.text = ((dolar*this.dollar)/euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = ((euro*this.euro)/dollar).toStringAsFixed(2);
  }
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor"),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao carregar dados",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController txtEdtCtrl, Function function){
  return TextField(
    controller: txtEdtCtrl,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amberAccent, fontSize: 25
    ),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}


Future<Map> getData() async{
  http.Response response = await http.get(REQUEST);
  return json.decode(response.body);
}
