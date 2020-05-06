import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


 // var _corTarefa = false;

 List _listaTarefas = [];
 Map<String,dynamic> _ultimaTarefaExcluida = Map();
 TextEditingController _controllerTarefa = TextEditingController();


Future<File> _getFile() async{

   final diretorio = await getApplicationDocumentsDirectory();
   return File(diretorio.path+"/dados.json");

 }

 _salvarTarefa(){
   String  textoDigitado = _controllerTarefa.text;
   Map< String, dynamic> tarefa = Map();
   tarefa["titulo"] = textoDigitado;
   tarefa["realizada"] = false;

   setState(() {
     _listaTarefas.add(tarefa);
   });

   _salvarArquivo();
   _controllerTarefa.text="";
 }

 _salvarArquivo () async{

   var arquivo = await _getFile();

   String dados = json.encode(_listaTarefas);
   arquivo.writeAsString(dados);

 }

 _lerArquivo () async {

   try{

     final arquivo = await _getFile();
    return arquivo.readAsString();


   }catch(e){
     return null;
   }

 }


 @override
  void initState() {
    //
    super.initState();
    _lerArquivo().then( (dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    } );
  }


  Widget criarItemLista(context, indice){

    //final item = _listaTarefas[indice]["titulo"]; //identificar quem eu to clicando


    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()), //chave tem que ser unica
        direction: DismissDirection.endToStart,
        onDismissed: (direction){ //ação ao excluir

          //recuperar ultimo item excluido
          _ultimaTarefaExcluida = _listaTarefas[indice];



          //remover item da lista
          _listaTarefas.removeAt(indice);
          _salvarArquivo();


          //snack bar
          final snackbar = SnackBar( //configura snackbar
            //backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
              content: Text("Tarefa removida!!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){

                  //desfazer a ação
                 setState(() {
                   _listaTarefas.insert(indice,_ultimaTarefaExcluida
                   );
                 });
                  _salvarArquivo();

                }
            ),
          );

          Scaffold.of(context).showSnackBar(snackbar); //exibe snackbar

        } ,
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
            title: Text(_listaTarefas[indice]["titulo"]),
            value: _listaTarefas[indice]["realizada"],
            //selected: _corTarefa,

            onChanged: (bool valor){
              setState(() {

                _listaTarefas[indice]["realizada"] = valor;

                /*//mudar a cor da tarefa para tachado
                if (_listaTarefas[indice]["realizada"] == true){
                  _corTarefa = true;
                }else if (_listaTarefas[indice]["realizada"] == false){
                  _corTarefa = false;
                }*/

                _salvarArquivo();
              });
            }
        )
    );

  }


  @override
  Widget build(BuildContext context) {

    //_salvarArquivo();
   // print("itens oxi: "+ DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
            "Lista de Tarefas",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: _listaTarefas.length,
            itemBuilder: criarItemLista //metodo para criar os widgets de lista
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 6,
          mini: true,
          onPressed: (){

            showDialog(
                context: context,
              builder: (context){

                  return AlertDialog(
                    title: Text("Adicionar Tarefa"),
                    content: TextField(
                      controller: _controllerTarefa,
                      decoration: InputDecoration(
                        labelText: "Digite sua tarefa"
                      ),
                      onChanged: (text){

                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancelar"),
                        onPressed: (){ Navigator.pop(context); _controllerTarefa.text="";}
                      ),
                      FlatButton(
                        child: Text("Salvar"),
                        onPressed: (){
                          //salvar
                          _salvarTarefa();
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );

              }
            );
          },
        child: Icon(Icons.add),
      ),

    );
  }



}
