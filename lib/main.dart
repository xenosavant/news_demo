import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'platform_adaptive.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, required;
import 'models.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'News Feed',
      theme: defaultTargetPlatform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme,
      home: new MyHomePage(title: 'News Feed'),
    );
  }
}

class ArticleListItem extends StatelessWidget
{
  ArticleListItem(this.article);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () async {
          await launch(article.url, forceSafariVC: false, forceWebView: false);
        },
        child: new Card(
          child: new Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: new Column(
                children: <Widget>[
                  article.imageUrl != null ? new Image.network(article.imageUrl,
                      fit: BoxFit.fitWidth) : new Row(),
                  new Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: new ListTile( title: new Text(article.title),
                            subtitle: new Text(article.description)
                    )
                  )
                ]
              )
          )
        )
    );
  }
}

class ArticleList extends StatelessWidget {

  final List<ArticleListItem> articles;

  ArticleList(this.articles);

  @override
  Widget build(BuildContext context) {
    return new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: articles
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<http.Response> _articlesFuture;
  List<ArticleListItem> articles = new List<ArticleListItem>();

  @override
  initState(){
    super.initState();
    _articlesFuture = http.get(
        "https://newsapi.org/v2/top-headlines?sources=google-news&from=2017-11-30&sortBy=popularity&apiKey=37dc4a19b1ac42318fb62fc1ec05a125");
  }

  Future<Null> _refresh() {
    return http.get(
        "https://newsapi.org/v2/top-headlines?sources=google-news&from=2017-11-30&sortBy=popularity&apiKey=37dc4a19b1ac42318fb62fc1ec05a125")
    .then((response) =>
        setState(() { articles = parseJSON(response);})).whenComplete(() => { });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new RefreshIndicator(
          onRefresh: _refresh,
          child: new FutureBuilder(
            future: _articlesFuture,
            builder: (BuildContext context, AsyncSnapshot<http.Response> response) {
            if (!response.hasData) {
              return const Center(
                child: const Text("Loading...")
              );
            }
            else if (response.data.statusCode != 200){
                return const Center(
                  child: const Text("An Error ocurred...")
                );
            }
            else {
              articles = parseJSON(response.data);
              return new ArticleList(articles);
            }
          })
      )
    );
    }
  }

  List<ArticleListItem> parseJSON(http.Response response)
  {
    var articles = new List<ArticleListItem>();
    Map data = JSON.decode(response.body);
    List<dynamic> parsedItems = data["articles"];
    for (var article in parsedItems) {
      var imageUrl = article["urlToImage"];
      if (!imageUrl.startsWith("http")) {
        imageUrl = null;
      }
      var articleUrl = article["url"];
      articles.add(new ArticleListItem(
          new Article(
              title: article["title"],
              imageUrl: imageUrl,
              description: article["description"],
              url: articleUrl))
      );
    }
    return articles;
  }

