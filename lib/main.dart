import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Wikipedia search API'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final searchTextController = TextEditingController();
  List<WikiSearchEntity> searchList = [];

  void _search() {
    String str = searchTextController.text;
    RequestService.query(str).then((WikiSearchResponse response) {
      setState(() {
        searchList = response.query.search;
        if (searchList == null) {
          searchList = [];
        }
      });
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  child: TextField(
                    controller: searchTextController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'TextField',
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 60,
                  child: OutlineButton(
                    onPressed: _search,
                    highlightColor: Colors.lightBlue,
                    child: Text("Search"),
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    primary: false,
                    itemBuilder: (BuildContext context, int index) => new WikiSearchItemWidget(searchList[index]),
                    itemCount: searchList.length,
                    shrinkWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WikiSearchItemWidget extends StatelessWidget {
  final WikiSearchEntity _entity;

  WikiSearchItemWidget(this._entity);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _entity.title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: SingleChildScrollView(
        child: Html(data: _entity.snippet),
      ),
      onTap: () {},
    );
  }
}

class RequestService {
  static Future<WikiSearchResponse> query(String search) async {
    var response = await http.get("https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$search&format=json&origin=*");
    // Check if response is success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var map = json.decode(response.body);
      return WikiSearchResponse.fromJson(map);
    } else {
      print("Query failed: ${response.body} (${response.statusCode})");
      return null;
    }
  }
}

class WikiSearchResponse {
  String batchComplete;
  WikiQueryResponse query;
  WikiSearchResponse({this.batchComplete, this.query});

  factory WikiSearchResponse.fromJson(Map<String, dynamic> json) => WikiSearchResponse(batchComplete: json["batchcomplete"], query: WikiQueryResponse.fromJson(json["query"]));
}

class WikiQueryResponse {
  List<WikiSearchEntity> search;

  WikiQueryResponse({this.search});

  factory WikiQueryResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> resultList = json['search'];
    List<WikiSearchEntity> search = resultList.map((dynamic value) => WikiSearchEntity.fromJson(value)).toList(growable: false);
    return WikiQueryResponse(search: search);
  }
}

class WikiSearchEntity {
  int ns;
  String title;
  int pageId;
  int size;
  int wordCount;
  String snippet;
  String timestamp;
  WikiSearchEntity({this.ns, this.title, this.pageId, this.size, this.wordCount, this.snippet, this.timestamp});

  factory WikiSearchEntity.fromJson(Map<String, dynamic> json) => WikiSearchEntity(ns: json["ns"], title: json["title"], pageId: json["pageid"], size: json["size"], wordCount: json["wordcount"], snippet: json["snippet"], timestamp: json["timestamp"]);
}
