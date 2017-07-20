import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:instagram/instagram.dart';

class MyProfile extends StatelessWidget {
  final User user;

  MyProfile(this.user);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new CircleAvatar(
              backgroundImage: new NetworkImage(user.profilePicture),
              radius: 60.0,
            ),
            new Divider(
              color: Colors.transparent,
            ),
            new Text(
              user.fullName,
              textScaleFactor: 2.0,
            ),
            new Divider(
              color: Colors.transparent,
            ),
            new Text(
              user.bio,
              textScaleFactor: 1.1,
            ),
            new Divider(
              color: Colors.transparent,
            ),
            user.website == null
                ? new Text('')
                : new GestureDetector(
                    onTap: () {
                      new FlutterWebviewPlugin().launch(user.website);
                    },
                    child: new Text(
                      user.website,
                      style: new TextStyle(
                        color: Theme.of(context).accentColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
