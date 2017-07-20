import 'package:flutter/material.dart';
import 'package:instagram/instagram.dart';
import 'detail.dart';
import 'my_pictures.dart';
import 'profile.dart';

class IGBrowser extends StatefulWidget {
  final ThemeData themeData;
  final InstagramApi client;

  IGBrowser(this.themeData, this.client);

  @override
  State createState() => new _IGBrowserState(themeData, client);
}

class _IGBrowserState extends State<IGBrowser> {
  final List<Media> media = [];
  final InstagramApi client;
  final ThemeData themeData;
  bool error = false, loadingUser = true;
  String route = 'my_pictures', title = 'My Pictures';
  Media currentMedia;
  User user;

  _IGBrowserState(this.themeData, this.client);

  void _setCurrentMedia(Media media) {
    setState(() {
      currentMedia = media;
      route = 'detail';
      var mediaType = media.type;
      var upper = mediaType.substring(0, 1).toUpperCase();
      title = upper + mediaType.substring(1);
    });
  }

  @override
  void initState() {
    super.initState();

    client.users.self.get().then((self) {
      setState(() => user = self);
    }).catchError((_) {
      setState(() => error == true);
    }).whenComplete(() {
      setState(() => loadingUser = false);
    });
  }

  Widget buildDrawer(BuildContext context) {
    return user == null
        ? null
        : new Drawer(
            child: new ListView(
              children: <Widget>[
                new UserAccountsDrawerHeader(
                  accountName: new Text(user.fullName),
                  accountEmail: new Text('@${user.username}'),
                  currentAccountPicture: new CircleAvatar(
                    backgroundImage: new NetworkImage(user.profilePicture),
                  ),
                ),
                new ListTile(
                  onTap: () {
                    setState(() {
                      route = 'my_pictures';
                      title = 'My Pictures';
                    });
                    Navigator.pop(context);
                  },
                  leading: new Icon(Icons.rss_feed),
                  title: new Text('My Pictures'),
                ),
                new Divider(),
                new ListTile(
                  onTap: () {
                    setState(() {
                      route = 'profile';
                      title = '@${user.username}';
                    });
                    Navigator.pop(context);
                  },
                  leading: new Icon(Icons.person),
                  title: new Text('My Profile'),
                ),
                new ListTile(
                  leading: new Icon(Icons.exit_to_app),
                  title: new Text('Log Out'),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    FloatingActionButton floatingActionButton;

    if (error)
      body = new Text('An error occurred while connecting to Instagram.');
    else if (loadingUser) {
      body = new Column(
        children: <Widget>[
          new Text('Connecting to Instagram...'),
          new Divider(
            color: Colors.transparent,
          ),
          new CircularProgressIndicator(),
        ],
      );
    } else {
      switch (route) {
        case 'detail':
          body = new MediaDetail(currentMedia, client.comments);
          floatingActionButton = new FloatingActionButton(
            child: new Icon(Icons.chat_bubble),
            onPressed: null,
          );
          break;
        case 'my_pictures':
          body = new MyPictures(client, _setCurrentMedia);
          floatingActionButton = new FloatingActionButton(
            child: new Icon(Icons.search),
            onPressed: null,
          );
          break;
        case 'profile':
          body = new MyProfile(user);
          break;
      }
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      drawer: buildDrawer(context),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
