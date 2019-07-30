import 'package:flutter/material.dart';
//biblioteca para fazer requisições http
import 'package:http/http.dart' as http;
//biblioteca ara trabalhar com métodos assincronos
import 'dart:async';
//bilioteca de converções
import 'dart:convert';

const url = 'https://api.hgbrasil.com/finance?format=json&key=b214c2bb';
//void main() => runApp(MyApp());
void main() async {
  runApp(new MaterialApp(
    home: new Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

//Criando função futura
Future<Map> getDados() async {
  http.Response reponse = await http.get(url);
  return json.decode(reponse.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = new TextEditingController();
  final dolarController = new TextEditingController();
  final euroController = new TextEditingController();

  var dolar = 0.0;
  var euro = 0.0;

  void _digitouReal(String text){
    if(text.isEmpty) {
      _limparCampos();
      return;
    }
    var valor = double.parse(text);
    dolarController.text = (valor/dolar).toStringAsFixed(2);
    euroController.text = (valor/euro).toStringAsFixed(2);
  } 

  void _digitouDolar(String text){
    if(text.isEmpty) {
      _limparCampos();
      return;
    }
    var valor = double.parse(text);
    realController.text = (valor  * dolar).toStringAsFixed(2);
    euroController.text = (valor * dolar / euro).toStringAsFixed(2);
  } 

  void _digitouEuro(String text){
    if(text.isEmpty) {
      _limparCampos();
      return;
    }
    var valor = double.parse(text);
    realController.text = (valor  * euro).toStringAsFixed(2);
    dolarController.text = (valor * euro / dolar).toStringAsFixed(2);
  } 

  void _limparCampos(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Conversor de Moeda\$'),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        //Componente para tratar dados futuros (programação assincrona)
        body: FutureBuilder<Map>(
            future: getDados(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Text('Carregando...',
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center);
                default:
                  if (snapshot.hasError) {
                    return Text('Erro ao carregar dados :(',
                        style: TextStyle(color: Colors.amber, fontSize: 25),
                        textAlign: TextAlign.center);
                  } else {
                    dolar =
                        snapshot.data['results']['currencies']['USD']['buy'];
                    euro = snapshot.data['results']['currencies']['EUR']['buy'];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          buildeTextField('Reais','R\$',realController,_digitouReal),
                          Divider(),
                          buildeTextField('Dólar','US\$',dolarController,_digitouDolar),
                          Divider(),
                          buildeTextField('Euro','€',euroController,_digitouEuro)
                         
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}


Widget buildeTextField(String label, String prefixo, TextEditingController controlador, Function funcao){
  return TextField(
          decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.amber),
              border: OutlineInputBorder(),
              prefixText: prefixo),
          style: TextStyle(color: Colors.amber, fontSize: 25),
          controller:  controlador,
          onChanged: funcao,
          //keyboardType: TextInputType.number,
          keyboardType: TextInputType.numberWithOptions(decimal: true)//Compatibilidade com o IOs
        );
}