import 'package:flutter/material.dart';
import 'package:instagram/instagram.dart';
import 'comment_list.dart';

class MediaDetail extends StatelessWidget {
  final Media media;
  final InstagramCommentsApi commentsApi;

  MediaDetail(this.media, this.commentsApi);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Center(
        child: new Column(
          children: <Widget>[
            displayMedia(),
            new CommentList(media.id, commentsApi),
          ],
        ),
      ),
    );
  }

  Widget displayMedia() {
    switch (media.type) {
      case 'image':
        return new Image.network(media.images.standardResolution.url);
    }

    return new Text('Unsupported media type: ${media.type}');
  }
}
