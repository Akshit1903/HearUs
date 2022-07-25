import 'package:flutter/material.dart';
import '../services/database.dart';

class ListenerProfile extends StatefulWidget {
  final String listenerUsername, profilePicUrl, email;
  ListenerProfile({this.listenerUsername, this.email, this.profilePicUrl});
  @override
  _ListenerProfileState createState() => _ListenerProfileState();
}

class _ListenerProfileState extends State<ListenerProfile> {
  rating(context, r) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width - 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for (int i = 1; i <= r; i++)
            Icon(
              Icons.star,
              color: Colors.white,
              size: 50,
            ),
          for (int j = 1; j <= 5 - r; j++)
            Icon(
              Icons.star_border_outlined,
              color: Colors.grey,
              size: 50,
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    DatabaseMethods().getRating(widget.listenerUsername);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircleAvatar(
                radius: 50,
                backgroundImage: (widget.profilePicUrl != null)
                    ? NetworkImage("${widget.profilePicUrl}")
                    : AssetImage('assets/back1.jpg')),
          ),
          Container(
            child: (widget.listenerUsername != null)
                ? Text(
                    "${widget.listenerUsername}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  )
                : Text(''),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: (widget.email != null)
                ? Text(
                    "${widget.email}",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                    ),
                  )
                : Text(''),
          ),
          FutureBuilder(
              future: DatabaseMethods().getRating(widget.listenerUsername),
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  print('there is data');
                  return rating(context, snapshot.data);
                }
                return rating(context, 0);
              }),
        ],
      ),
    );
  }
}
