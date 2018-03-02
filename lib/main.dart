import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'key.dart' as keys;

void main() => runApp(new PHApp());

class Post{
  String name;
  String image_url;
  String tagline;
  int votes_count;
  int comments_count;
  Post.fromJson(Map jsonMap) {
    name = jsonMap['name'];
    var parsed_url = Uri.parse(jsonMap['thumbnail']['image_url']);
    image_url = 'https://ph-files.imgix.net' + parsed_url.path + '?auto=format&fit=crop&h=570&w=570';
    tagline = jsonMap['tagline'];
    votes_count = jsonMap['votes_count'];
    comments_count = jsonMap['comments_count'];
  }
  String toString() => 'Post: $name';
}

class PHApp extends StatefulWidget {
  PHAppState createState() => new PHAppState();
}

class PHAppState extends State<PHApp>{
  initState() {
    super.initState();
    listenForPosts();
  }

  var posts = <Post>[];

  listenForPosts() async { 
    var stream = await getPosts();
    stream.listen((post) => setState(() => posts.add(post)));
  }
  
  refreshPosts(){
    listenForPosts();
  }

  Future<Stream<Post>> getPosts() async {
    var url = 'https://api.producthunt.com/v1/posts/all?sort_by=votes_count';
    var client = new http.Client();
    var request = new http.Request('get', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer ' + keys.phApiKey;
    var streamedRes = await client.send(request);
    return streamedRes.stream
      .transform(UTF8.decoder)
      .transform(JSON.decoder)
      .expand((jsonBody) => (jsonBody as Map)['posts'])
      .map((jsonPost) => new Post.fromJson(jsonPost));
  }

  Widget build(BuildContext){
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.deepOrange),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Product Hunter'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: refreshPosts,
            )
          ],
        ),
        body: new ListView(
          children: posts.map((post) => new ListTile(
            leading: new Image.network(post.image_url),
            title: new Text(post.name),
            subtitle: new Text(post.tagline),
            trailing: new Column(
              children: <Widget>[
                new Icon(Icons.keyboard_arrow_up),
                new Text(post.comments_count.toString()),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}