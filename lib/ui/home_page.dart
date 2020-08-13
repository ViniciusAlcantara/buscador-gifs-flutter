import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String search;
  int offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (search == null) {
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=CG5r8bKr6jWBzoSVzyOCO7W88LHN0yuh&limit=20&rating=G');
    } else {
      response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=CG5r8bKr6jWBzoSVzyOCO7W88LHN0yuh&q=$search&limit=20&offset=$offset&rating=G');
    }
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((map) {
    });
  }

  int getCount(List dados) {
    if (dados == null) return 0;
    if (search == null) return dados.length;
    else return dados.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
          centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquise...',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.left,
              onSubmitted: (text) {
                setState(() {
                  search = text;
                });
              },
            ),
          ),
          Expanded(child: FutureBuilder(
            future: _getGifs(),
            builder: (context, snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 7.0,
                    ),
                  );
                default:
                  if (snapshot.hasError) return Container();
                  else return createGifTable(context, snapshot);
              }
            }
          ))
        ],
      ),
    );
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0
        ),
        itemCount: getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (search == null || index < snapshot.data['data'].length) {
            return GestureDetector(
                child: Image.network(snapshot.data['data'][index]['images']['fixed_height']['url'],
                    height: 300,
                    fit: BoxFit.cover,
                  ),
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text('Carrega mais...', style: TextStyle(color: Colors.white, fontSize: 22.0))
                  ],
                )
              )
            );
          }
        }
    );
  }
}
