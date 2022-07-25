import 'package:HearUs/style/newFonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/psycho.dart';
import '../style/fonts.dart';
import '../style/colors.dart';
import '../util/modals.dart';
import '../widgets/widgets.dart';

class PsychoListPage extends StatefulWidget {
  final DataFromSharedPref userData;
  PsychoListPage({this.userData});

  @override
  _PsychoListPageState createState() => _PsychoListPageState();
}

class _PsychoListPageState extends State<PsychoListPage> {
  Widget psychoTile(DocumentSnapshot ds) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "PsychoProfile"),
          builder: (context) => PsychoProfile(dsa: ds, us: widget.userData),
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xFFF7F3F0),
          borderRadius: BorderRadius.all(Radius.circular(13)),
        ),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    ds["imgUrl"],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 140,
                  child: Text(
                    ds["name"],
                    style: AppTextStyle().psychoListHeadStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 6.0),
                  width: MediaQuery.of(context).size.width - 140,
                  child: Text(
                    ds['subProfile'],
                    style: AppTextStyle().psychoListbodyStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(widget.userData, context),
      body: SafeArea(
        child: Container(
            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: EdgeInsets.all(10),
              child: Text("${widget.userData.myUsername}, need help?",
                  style: NewAppTextStyle().psychoListMainHeadingStyle),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Text("Book a session",
                  style: NewAppTextStyle().psychoListMainBodyStyle),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 8),
                // height: MediaQuery.of(context).size.height - 180 - 7,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("psychologists")
                      .get()
                      .asStream(),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? Container(
                            // height: MediaQuery.of(context).size.height - 20,
                            child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 75, top: 10),
                                // reverse: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot ds =
                                      snapshot.data.docs[index];
                                  return psychoTile(ds);
                                }),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                                LinearProgressIndicator(
                                    backgroundColor: AppColor().mainBackColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColor().buttonColor))
                              ]);
                  },
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
