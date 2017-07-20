import 'package:flutter/material.dart';
import 'package:instagram/instagram.dart';

typedef void HandleToken(BuildContext context, String token);
typedef void StartServer(BuildContext context, String redirect);

class IGLogin extends StatelessWidget {
  final InstagramApiAuth auth;
  final HandleToken handleToken;
  final StartServer startServer;

  IGLogin(this.auth, this.handleToken, this.startServer);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new Text('Click the button below to log in.'),
            new Divider(
              color: Colors.transparent,
            ),
            new RaisedButton(
              onPressed: () {
                startServer(context, auth.getImplicitRedirectUri().toString());
              },
              color: Theme.of(context).primaryColor,
              child: new Text(
                'LOG IN',
                style: new TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
