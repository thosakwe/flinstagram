import 'package:flutter/material.dart';
import 'package:instagram/instagram.dart';

class CommentList extends StatefulWidget {
  final String mediaId;
  final InstagramCommentsApi commentsApi;

  CommentList(this.mediaId, this.commentsApi);

  @override
  State createState() => new _CommentListState(mediaId, commentsApi);
}

class _CommentListState extends State<CommentList> {
  final String mediaId;
  final InstagramCommentsApi commentsApi;
  final List<Comment> comments = [];
  bool error = false, loading = true;

  _CommentListState(this.mediaId, this.commentsApi);

  @override
  void initState() {
    super.initState();
    commentsApi.forMedia(mediaId).getComments().then((comments) {
      setState(() {
        this.comments
          ..clear()
          ..addAll(comments);
      });
    }).catchError((_) {
      setState(() => error = true);
    }).whenComplete(() {
      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return new CircularProgressIndicator();
    else if (error == true)
      return new Text('Error occurred loading comments.');
    else if (comments.isEmpty) {
      return new Text('No comments found.');
    } else {
      return new ListView(
        children: comments.map<Widget>((c) => new CommentListItem(c)).toList(),
      );
    }
  }
}

class CommentListItem extends StatelessWidget {
  final Comment comment;

  CommentListItem(this.comment);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new CircleAvatar(
        backgroundImage: new NetworkImage(comment.from.profilePicture),
      ),
      title: new Text(comment.from.username),
      subtitle: new Text(comment.text),
    );
  }
}
