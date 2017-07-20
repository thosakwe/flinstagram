import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/instagram.dart';
import 'browser.dart';
import 'login.dart';

const String clientId = 'b205571a80e34fb19ddffb6cfbadd5c4';
const int port = 4445;
const String redirectUrl = 'http://localhost:$port/token';

class Flinstagram extends StatefulWidget {
  @override
  State createState() => new _FlinstagramState();
}

class _FlinstagramState extends State<Flinstagram> {
  final InstagramApiAuth auth =
      new InstagramApiAuth(clientId, null, redirectUri: Uri.parse(redirectUrl));
  InstagramApi client;
  http.Client httpClient;
  HttpServer httpServer;
  String title = 'Flinstagram';

  void _handleToken(BuildContext context, String token) {
    setState(() {
      client = InstagramApiAuth.authorizeViaAccessToken(
          token, httpClient = new http.Client());
    });
  }

  void _handleRequest(HttpRequest request, BuildContext context) {}

  void _startServer(BuildContext context, String redirect) {
    var c = new Completer();

    HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
      httpServer = server
        ..listen((request) {
          if (request.uri.pathSegments.isNotEmpty &&
              request.uri.pathSegments.first == 'token') {
            if (request.uri.queryParameters.containsKey('token')) {
              var token = request.uri.queryParameters['token'];
              c.complete(token);

              request.response
                ..statusCode = HttpStatus.BAD_REQUEST
                ..headers.contentType = ContentType.HTML
                ..write(r'''
                  <html>
                    <head>
                      <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
                      <title>Interstitial</title>
                    </head>
                    <body>
                      <noscript>
                        You must enable JavaScript to complete the log-in flow.
                      </noscript>
                      <script>
                        window.history.go(-2);
                      </script>
                      ''');
            } else {
              request.response
                ..statusCode = HttpStatus.BAD_REQUEST
                ..headers.contentType = ContentType.HTML
                ..write(r'''
                  <html>
                    <head>
                      <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
                      <title>Interstitial</title>
                    </head>
                    <body>
                      <noscript>
                        You must enable JavaScript to complete the log-in flow.
                      </noscript>
                      <script>
                        var hash = window.location.hash;
                        var rgx = /#access_token=([^$]+)/;
                        var m = rgx.exec(hash);
                        
                        if (!m)
                          document.write('Oops... Something went wrong while logging in.');
                        else {
                          var accessToken = m[1];
                          var url = 'http://' + window.location.host + '/token?token=' + accessToken;
                          console.info(url);
                          window.location = url;
                          /*
                          document.write('Redirecting you to ' + url + '...');
                          
                          var xhr = new XMLHttpRequest();
                          xhr.open('GET', url);
                          xhr.send();
                          //window.location.href = window.location.href + '?token=' + accessToken;
                          */
                        }
                      </script>
                    </body>
                  </html>
                  ''');
            }
          } else {
            request.response
              ..statusCode = HttpStatus.BAD_REQUEST
              ..headers.contentType = ContentType.HTML
              ..write('''
                  <html>
                    <head>
                      <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
                      <title>Invalid Request</title>
                    </head>
                    <body>
                      <h1>Invalid request.</h1>
                      <p>URI: ${request.requestedUri}</p>
                    </body>
                  </html>
                ''');
          }

          request.response.close();
        }, onError: c.completeError);

      // Open the URL now.

      var wv = new FlutterWebviewPlugin();
      wv.launch(redirect);
      /*canLaunch(redirect).then((can) {
        if (!can)
          throw 'Cannot open URL "$redirect".';
        else {
          launch(redirect).then((_) {
            //throw 'User closed window without authenticating.';
          }).catchError(c.completeError);
        }
      }).catchError(c.completeError);*/
    });

    c.future.then((String token) {
      new FlutterWebviewPlugin().close();
      _handleToken(context, token);
    }).catchError((e) {
      showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text('Couldn\'t log you in. $e'),
          content: new Text('Try again later. Sorry for the inconvenience.'),
        ),
      );
    }).whenComplete(() {
      httpServer?.close(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = new ThemeData(
      primarySwatch: Colors.pink,
    );
    Widget home;

    if (client == null) {
      return new MaterialApp(
        theme: themeData,
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Log In to Continue'),
          ),
          body: new IGLogin(auth, _handleToken, _startServer),
        ),
      );
      //title = 'Log In to Continue';
    } else {
      return new MaterialApp(
        theme: themeData,
        home: new Scaffold(
          body: new IGBrowser(themeData, client),
        ),
      );
    }
  }
}
