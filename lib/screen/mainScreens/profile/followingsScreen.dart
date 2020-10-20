import 'package:animated_background/animated_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/screen/mainScreens/search/searchProfile.dart';

class FollowingsPage extends StatefulWidget {
  final String uid;
  FollowingsPage({this.uid});
  @override
  _FollowingsPageState createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage>
    with TickerProviderStateMixin {
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  UserInfoStore _userInfoStore = UserInfoStore();
  UserAuth _userAuth = UserAuth();
  String nullImageUrl =
      "https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=200&w=1260";

  ParticleOptions particleOptions = ParticleOptions(
    image: Image.asset('assets/images/star_stroke.png'),
    baseColor: Colors.blue,
    spawnOpacity: 0.0,
    opacityChangeRate: 0.25,
    minOpacity: 0.1,
    maxOpacity: 0.4,
    spawnMinSpeed: 30.0,
    spawnMaxSpeed: 70.0,
    spawnMinRadius: 7.0,
    spawnMaxRadius: 15.0,
    particleCount: 40,
  );

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Following'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: StreamBuilder(
          stream: _userInfoStore.getFollowing(uid: widget.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitCircle(
                  color: AppTheme.primaryColor,
                  size: 60,
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                  child: Text(
                'Something went wrong',
                style: TextStyle(color: AppTheme.pureWhiteColor),
              ));
            } else if (snapshot.data.documents.length == 0) {
              return Container(
                  color: Colors.transparent,
                  child: AnimatedBackground(
                      behaviour: RandomParticleBehaviour(
                        options: particleOptions,
                        paint: particlePaint,
                      ),
                      vsync: this,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                  TextSpan(text: '', children: <InlineSpan>[
                                TextSpan(
                                  text: 'Follow',
                                  style: TextStyle(
                                      fontSize: 56,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '  Creators to see them here',
                                  style: TextStyle(
                                      fontSize: 38,
                                      color: AppTheme.pureWhiteColor,
                                      fontWeight: FontWeight.bold),
                                )
                              ])),
                            ],
                          ),
                        ),
                      )));
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder(
                      future: _userInfoStore.getUserInfo(
                          uid: snapshot.data.documents[index].id),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.done) {
                          var _user = UserDataModel.fromDocument(snap.data);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (BuildContext context) =>
                                          SearchProfile(
                                            uid: _user.id,
                                          )));
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 0.8),
                              color: AppTheme.pureBlackColor,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigoAccent,
                                  backgroundImage: _user.photoUrl == null
                                      ? NetworkImage(nullImageUrl)
                                      : NetworkImage(_user.photoUrl),
                                  foregroundColor: Colors.white,
                                ),
                                title: Text(
                                    _user.displayName == null
                                        ? "Wow Talent User"
                                        : _user.displayName,
                                    style: TextStyle(
                                        color: AppTheme.primaryColor)),
                                subtitle: Text(_user.username,
                                    style: TextStyle(
                                        color: AppTheme.primaryColor)),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      });
                },
              );
            }
          }),
    );
  }
}
