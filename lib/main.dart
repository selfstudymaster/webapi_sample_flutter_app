import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

// mainクラス
void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatelessWidget {
  final Future<List<Article>> articles = ConnpassClient.fetchArticle();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Connpass API '),
        ),
        body: Center(
          child: FutureBuilder<List<Article>>(
            future: articles,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ArticleListView(articles: snapshot.data);
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

// ListView (ArticleListViewクラスの定義)
class ArticleListView extends StatelessWidget {
  final List<Article> articles;
  ArticleListView({Key key, this.articles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (BuildContext context, int index) {
        final article = articles[index];
        return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(article.eventUrl),
            ),
            title: Text(article.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ArticleDetailPage(article: article)),
              );
            });
      },
    );
  }
}

// ArticleDetailPageクラスの定義
class ArticleDetailPage extends StatelessWidget {
  final Article article;

  ArticleDetailPage({Key key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: WebView(
            initialUrl: article.eventUrl,
          ),
        ),
      ),
    );
  }
}

// Userクラスの定義
// class User {
//   final String id; // メンバ変数
//   // final String iconUrl; // メンバ変数
//
//   User({
//     this.id,
//     // this.iconUrl
//   }); // メンバ関数
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     // JSONで値を返す
//     return User(
//       id: json['id'],
//       // iconUrl: json['profile_image_url'],
//     );
//   }
// }

// Articleクラスの定義
class Article {
  // final String title; // メンバ変数
  // final String event_url; // メンバ変数
  // final User user; // メンバ変数
  // final events;

  final int eventId;
  final String title;
  final String catchMessage;
  final String eventUrl;

  Article({
    this.eventId,
    this.title,
    this.catchMessage,
    this.eventUrl,
    // this.title,
    // this.event_url,
    // this.user,
    // this.events,
  }); // メンバ関数

  factory Article.fromJson(Map<String, dynamic> json) {
    // JSONで値を返す
    return Article(
      eventId: json['event_id'],
      title: json['title'],
      catchMessage: json['catch'],
      eventUrl: json['event_url'],
      // user: User.fromJson(json['user']),
      // title: json['title'],
      // event_url: json['event_url'],
      // user: User.fromJson(json['user']),
      // events: json['events'],
    );
  }
}

// ConnpassClientクラスの定義
// APIの呼び出し
class ConnpassClient {
  static Future<List<Article>> fetchArticle() async {
    final url = 'https://connpass.com/api/v1/event';

    // final url = 'https://qiita.com/api/v2/items';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonArray = json.decode(response.body);
      return jsonArray.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load article');
    }
  }
}
