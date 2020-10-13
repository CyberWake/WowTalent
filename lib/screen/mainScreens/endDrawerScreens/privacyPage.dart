import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';

class PrivacyPage extends StatefulWidget {
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final GlobalKey<ScaffoldState> _scaffoldGlobalKey =
      GlobalKey<ScaffoldState>();
  UserDataModel user;
  UserAuth _userAuth = UserAuth();
  UserInfoStore _userInfoStore = UserInfoStore();
  DocumentSnapshot _currentUserInfo;

  setup() async {
    _currentUserInfo =
        await _userInfoStore.getUserInfo(uid: _userAuth.user.uid);
    user = UserDataModel.fromDocument(_currentUserInfo);
    setState(() {});
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldGlobalKey,
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Privacy'),
        ),
        body: ListView(
          padding: EdgeInsets.only(top: 20),
          children: [
            ListTile(
              leading: Icon(Icons.security, color: AppTheme.primaryColor),
              title: Text('Make account private',
                  style: TextStyle(color: AppTheme.pureWhiteColor)),
              subtitle: Text('Enable this to make your account private',
                  style: TextStyle(color: AppTheme.pureWhiteColor)),
              trailing: Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: AspectRatio(
                  aspectRatio: 0.3,
                  child: CupertinoSwitch(
                    value: user == null ? false : user.private,
                    activeColor: Colors.orange,
                    onChanged: (bool value) async {
                      print("user.private" + user.private.toString());
                      user.private = value;
                      bool updated = await _userInfoStore.updatePrivacy(
                          uid: user.id, privacy: user.private);
                      setState(() {});
                      if (updated) {
                        _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
                            duration: Duration(milliseconds: 500),
                            content: Text('Privacy Updated')));
                      } else {
                        _scaffoldGlobalKey.currentState.showSnackBar(SnackBar(
                            content: Text('Something went wrong try again')));
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}