import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'platform_adaptive.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, required;
import 'models.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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
    return new ListTile(
      title: new Text(article.title)
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
  List<ArticleListItem> articles = new List<ArticleListItem>();

  void mapToArticle(articles)
  {

  }

  _buildArticleList() async
  {
    var httpClient = createHttpClient();
    var response = await httpClient.get("https://newsapi.org/v2/everything?q=Breitbart&from=2017-11-30&sortBy=popularity&apiKey=37dc4a19b1ac42318fb62fc1ec05a125");
    Map data = JSON.decode(response.body);
    List<ArticleListItem> newArticles = new List<ArticleListItem>();
    for (var article in data["articles"] )
    {
      newArticles.add(new ArticleListItem(new Article(title:article["title"])));
    }
    setState(() {
      articles = newArticles;
    });
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
      body: new ArticleList(articles),
        floatingActionButton: new FloatingActionButton(
          onPressed: _buildArticleList,
          tooltip: 'Refresh',
          child: new Icon(Icons.refresh)
    ));
  }
}

