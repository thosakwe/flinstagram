import 'package:flutter/material.dart';
import 'package:instagram/instagram.dart';
import 'package:timeago/timeago.dart';

typedef SetCurrentMedia(Media media);

class MyPictures extends StatefulWidget {
  final InstagramApi client;
  final SetCurrentMedia setCurrentMedia;

  MyPictures(this.client, this.setCurrentMedia);

  @override
  State createState() => new _MyPicturesState(client, setCurrentMedia);
}

class _MyPicturesState extends State<MyPictures> {
  final List<Media> media = [];
  final TimeAgo timeAgo = new TimeAgo();
  final InstagramApi client;
  final SetCurrentMedia setCurrentMedia;

  bool error = false, loading = true;

  _MyPicturesState(this.client, this.setCurrentMedia);

  @override
  void initState() {
    super.initState();
    client.users.self.getRecentMedia().then((media) {
      setState(() {
        this.media
          ..clear()
          ..addAll(media);
      });
    }).catchError((_) {
      setState(() => error = true);
    }).whenComplete(() {
      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: inner(context),
    );
  }

  Widget inner(BuildContext context) {
    if (loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else if (error) {
      return new Center(
        child: new Text('Unexpected error occurred.'),
      );
    } else if (media.isEmpty) {
      return new Center(
        child: new Text('You haven\'t uploaded any media.'),
      );
    }

    return new Scaffold(
      body: new ListView.builder(
          itemCount: media.length,
          itemBuilder: (_, i) {
            var m = media[i];

            return new ListTile(
              onTap: () {
                setCurrentMedia(m);
              },
              leading: new CircleAvatar(
                backgroundImage: new NetworkImage(m.images.thumbnail.url),
              ),
              title: new Text(m.caption.text),
              subtitle: new Text(timeAgo.format(m.createdTime)),
            );
          }),
    );
  }
}
