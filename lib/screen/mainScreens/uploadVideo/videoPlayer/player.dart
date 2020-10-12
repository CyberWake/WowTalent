import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/auth/userAuth.dart';
import 'package:wowtalent/database/userVideoStore.dart';
import 'package:wowtalent/database/userInfoStore.dart';
import 'package:wowtalent/model/authPageEnums.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/model/userDataModel.dart';
import 'package:wowtalent/model/videoInfoModel.dart';
import 'package:wowtalent/screen/authentication/authenticationWrapper.dart';
import 'package:wowtalent/screen/ios_Screens/uploadVideo/video_player/playerIOS.dart';
import 'package:wowtalent/screen/mainScreens/home/comments.dart';
import 'package:wowtalent/widgets/cupertinosnackbar.dart';

class Player extends StatefulWidget {
  final VideoInfo video;
  final UserDataModel user;
  Player({Key key, @required this.video, this.user}) : super(key: key);
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  UserAuth _userAuth = UserAuth();
  VideoPlayerController _controller;
  double _widthOne;
  double _fontOne;
  double _iconOne;
  double _sliderValue = 0.0;
  Size _size;
  UserVideoStore _userVideoStore = UserVideoStore();
  int likeCount = 0;
  int commentCount = 0;
  bool _isLiked = false;
  bool playing;
  bool loading = true;
  UserDataModel _user = UserDataModel();
  UserInfoStore _userInfoStore = UserInfoStore();
  bool _boolFutureCalled = false;
  bool _following = false;
  bool _processing = false;

  Future<bool> setup() async {
    if (!_boolFutureCalled) {
      try {
        if (_userAuth.user != null) {
          _following = await _userInfoStore.checkIfAlreadyFollowing(
              uid: widget.video.uploaderUid);
        }
        likeCount = widget.video.likes;
        _sliderValue =
            await _userVideoStore.checkRated(videoID: widget.video.videoId);
        print(_sliderValue);
        _isLiked =
            await _userVideoStore.checkLiked(videoID: widget.video.videoId);
        _boolFutureCalled = true;
        setState(() {});
        return true;
      } catch (e) {
        print(e.toString());
        return false;
      }
    } else {
      return true;
    }
  }

  getUserInfo() async {
    DocumentSnapshot user =
        await _userInfoStore.getUserInfo(uid: widget.video.uploaderUid);
    _user = UserDataModel.fromDocument(user);
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
    setup();
    getUserInfo();
    _controller.play();
    playing = true;
  }

  Future<bool> button(bool isLiked) async {
    if (_userAuth.user == null) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Authentication(AuthIndex.REGISTER);
          },
        ),
      );
    } else if (_isLiked == false) {
      _isLiked = await _userVideoStore.likeVideo(
        videoID: widget.video.videoId,
      );
    } else if (_isLiked == true) {
      _isLiked = await _userVideoStore.dislikeVideo(
        videoID: widget.video.videoId,
      );
    }
    return _isLiked;
  }

  String getChoppedUsername(String currentDiscription) {
    String choppedDiscription = '';
    var subDisplayName = currentDiscription.split(' ');
    for (var i in subDisplayName) {
      if (choppedDiscription.length + i.length < 36) {
        choppedDiscription += ' ' + i;
      } else {
        return choppedDiscription + ' ...';
      }
    }
    return choppedDiscription + ' ...';
  }

  Future<bool> _onBackPressed() {
    try {
      Navigator.pop(context);
      return _controller.pause() ?? false;
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _widthOne = _size.width * 0.0008;
    _fontOne = (_size.height * 0.015) / 11;
    _iconOne = (_size.height * 0.066) / 50;
    return Platform.isIOS
        ? PlayerIOS(
            playerBody: playerBody(),
          )
        : WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              body: playerBody(),
            ),
          );
  }

  currPos() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, VideoPlayerValue value, child) {
        return Text(
          value.position == null ? "" : trimDuration(value.position),
          style: TextStyle(color: AppTheme.pureWhiteColor),
        );
      },
    );
  }

  String trimDuration(Duration duration) {
    num min = duration.inMinutes;
    num sec = duration.inSeconds.remainder(60);
    if (sec < 10) {
      return "$min:0$sec";
    } else {
      return "${duration.inMinutes}:${duration.inSeconds.remainder(60)}";
    }
  }

  Widget playerBody() {
    return !loading
        ? Container(
            color: Colors.black,
            child: Stack(children: [
              Builder(
                builder: (context) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: _controller.value.initialized
                                ? Platform.isIOS
                                    ? CupertinoButton(
                                        onPressed: () {
                                          if (playing) {
                                            cupertinoSnackbar(context, "Audio Muted");
                                            playing = false;
                                            _controller.setVolume(0.0);
                                          } else {
                                            cupertinoSnackbar(context, "Audio Unmuted");
                                            print("unmuted");
                                            playing = true;
                                            _controller.setVolume(1.0);
                                          }
                                        },
                                        child: VideoPlayer(_controller))
                                    : InkWell(
                                        onTap: () {
                                          if (playing) {
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                              duration:
                                                  Duration(milliseconds: 500),
                                              content: Text('Audio Muted'),
                                            ));
                                            playing = false;
                                            _controller.setVolume(0.0);
                                          } else {
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                              duration:
                                                  Duration(milliseconds: 500),
                                              content: Text('Audio Unmuted'),
                                            ));
                                            print("unmuted");
                                            playing = true;
                                            _controller.setVolume(1.0);
                                          }
                                        },
                                        child: VideoPlayer(_controller))
                                : SpinKitCircle(
                                    color: AppTheme.primaryColor,
                                    size: 60,
                                  )),
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                              playedColor: AppTheme.primaryColor,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.white),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              currPos(),
                              Text(
                                _controller.value.duration == null
                                    ? ""
                                    : trimDuration(_controller.value.duration),
                                style:
                                    TextStyle(color: AppTheme.pureWhiteColor),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: FloatingActionButton(
                          backgroundColor: AppTheme.primaryColor,
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: AppTheme.backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                ],
              ),
              Builder(builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(_user.photoUrl == null
                                ? "https://via.placeholder.com/150"
                                : _user.photoUrl),
                            radius: 13,
                          ),
                          Text(
                            '  ${_user.username} \u2022',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_userAuth.user == null) {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Authentication(AuthIndex.REGISTER);
                                    },
                                  ),
                                );
                              } else {
                                try {
                                  print(_following);
                                  _following = await _userInfoStore.followUser(
                                      uid: widget.video.uploaderUid);
                                  print(_following);
                                  print('pressed');
                                  setState(() {});
                                } on Exception catch (e) {
                                  print(e.toString());
                                }
                              }
                            },
                            child: Text(
                              _userAuth.user == null
                                  ? "Follow"
                                  : _userAuth.user.uid ==
                                          widget.video.uploaderUid
                                      ? ' '
                                      : !_following
                                          ? ' Follow'
                                          : " Following",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 23, vertical: 4),
                        child: Text(
                          widget.video.videoName != null
                              ? widget.video.videoName.length > 37
                                  ? "Title" +
                                      ' \u2022 ' +
                                      getChoppedUsername(widget.video.videoName)
                                  : "Title" +
                                      ' \u2022 ' +
                                      widget.video.videoName +
                                      ' \u2022 '
                              : "Title" + ' \u2022 ',
                          style: TextStyle(color: Colors.white),
                        )),
                    Padding(
                      padding: EdgeInsets.only(left: 23),
                      child: Row(
                        children: [
                          Icon(
                            Icons.equalizer,
                            color: Colors.white,
                          ),
                          Text(
                            ' \u2022 ' + widget.video.category ?? "Category",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.black12.withOpacity(0.4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Platform.isIOS
                                  ? CupertinoButton(
                                      child: SvgPicture.asset(
                                        _isLiked
                                            ? "assets/images/loved_icon.svg"
                                            : "assets/images/love_icon.svg",
                                        color: AppTheme.primaryColor,
                                        width: 20,
                                      ),
                                      onPressed: () async {
                                        if (_userAuth.user == null) {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return Authentication(
                                                    AuthIndex.REGISTER);
                                              },
                                            ),
                                          );
                                        } else {
                                          if (!_processing) {
                                            _processing = true;
                                            if (!_isLiked) {
                                              _isLiked = await _userVideoStore
                                                  .likeVideo(
                                                videoID: widget.video.videoId,
                                              );
                                              if (_isLiked) {
                                                likeCount += 1;
                                                print("liked");
                                              }
                                            } else {
                                              await _userVideoStore
                                                  .dislikeVideo(
                                                videoID: widget.video.videoId,
                                              )
                                                  .then((value) {
                                                if (value) {
                                                  _isLiked = false;
                                                }
                                              });
                                              if (!_isLiked) {
                                                likeCount -= 1;
                                                print("disliked");
                                              }
                                            }
                                            _processing = false;
                                          }
                                          setState(() {});
                                        }
                                      },
                                    )
                                  : InkWell(
                                      child: SvgPicture.asset(
                                        _isLiked
                                            ? "assets/images/loved_icon.svg"
                                            : "assets/images/love_icon.svg",
                                        color: AppTheme.primaryColor,
                                        width: 20,
                                      ),
                                      onTap: () async {
                                        if (_userAuth.user == null) {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return Authentication(
                                                    AuthIndex.REGISTER);
                                              },
                                            ),
                                          );
                                        } else {
                                          if (!_processing) {
                                            _processing = true;
                                            if (!_isLiked) {
                                              _isLiked = await _userVideoStore
                                                  .likeVideo(
                                                videoID: widget.video.videoId,
                                              );
                                              if (_isLiked) {
                                                likeCount += 1;
                                                print("liked");
                                              }
                                            } else {
                                              await _userVideoStore
                                                  .dislikeVideo(
                                                videoID: widget.video.videoId,
                                              )
                                                  .then((value) {
                                                if (value) {
                                                  _isLiked = false;
                                                }
                                              });
                                              if (!_isLiked) {
                                                likeCount -= 1;
                                                print("disliked");
                                              }
                                            }
                                            _processing = false;
                                          }
                                          setState(() {});
                                        }
                                      }),
                              SizedBox(
                                width: _widthOne * 20,
                              ),
                              Text(
                                likeCount.toString() == "null"
                                    ? "0"
                                    : likeCount.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: _fontOne * 14,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: _widthOne * 30,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Platform.isIOS
                                  ? CupertinoButton(
                                      onPressed: () {
                                        if (_userAuth.user == null) {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return Authentication(
                                                    AuthIndex.REGISTER);
                                              },
                                            ),
                                          );
                                        } else {
                                          print(widget.video.uploaderUid);
                                          _controller.pause();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommentsScreen(
                                                        videoId: widget
                                                            .video.videoId,
                                                      )));
                                        }
                                      },
                                      child: Icon(
                                        Icons.comment,
                                        color: Colors.white,
                                        size: _iconOne * 23,
                                      ))
                                  : IconButton(
                                      onPressed: () {
                                        if (_userAuth.user == null) {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return Authentication(
                                                    AuthIndex.REGISTER);
                                              },
                                            ),
                                          );
                                        } else {
                                          print(widget.video.uploaderUid);
                                          _controller.pause();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommentsScreen(
                                                        videoId: widget
                                                            .video.videoId,
                                                      )));
                                        }
                                      },
                                      icon: Icon(
                                        Icons.comment,
                                        color: Colors.white,
                                        size: _iconOne * 23,
                                      ),
                                    ),
                              SizedBox(
                                width: _widthOne * 20,
                              ),
                              Text(
                                widget.video.comments.toString() == "null"
                                    ? "0"
                                    : widget.video.comments.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: _fontOne * 14,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: _widthOne * 30,
                          ),
                          SizedBox(
                            width: _widthOne * 650,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackShape: RectangularSliderTrackShape(),
                                trackHeight: 2.0,
                                thumbColor: AppTheme.primaryColor,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0),
                                overlayColor: Colors.red.withAlpha(32),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 30.0),
                              ),
                              child: Platform.isIOS
                                  ? CupertinoSlider(
                                      value: _sliderValue,
                                      min: 0,
                                      max: 5,
                                      onChangeEnd: (val) async {
                                        if (_userAuth.user == null) {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) {
                                                return Authentication(
                                                    AuthIndex.REGISTER);
                                              },
                                            ),
                                          );
                                        } else {
                                          bool success =
                                              await _userVideoStore.rateVideo(
                                                  videoID: widget.video.videoId,
                                                  rating: _sliderValue);
                                          if (!success) {
                                            setState(() {
                                              _sliderValue = 0;
                                            });
                                          }
                                        }
                                      },
                                      onChanged: (val) async {
                                        setState(() {
                                          _sliderValue = val;
                                        });
                                      },
                                      activeColor: Colors.grey,
                                    )
                                  : Slider(
                                      value: _sliderValue,
                                      min: 0,
                                      max: 5,
                                      onChangeEnd: (val) async {
                                        if (_userAuth.user == null) {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return Authentication(
                                                    AuthIndex.REGISTER);
                                              },
                                            ),
                                          );
                                        } else {
                                          bool success =
                                              await _userVideoStore.rateVideo(
                                                  videoID: widget.video.videoId,
                                                  rating: _sliderValue);
                                          if (!success) {
                                            setState(() {
                                              _sliderValue = 0;
                                            });
                                          }
                                        }
                                      },
                                      onChanged: (val) async {
                                        setState(() {
                                          _sliderValue = val;
                                        });
                                      },
                                      inactiveColor: Colors.white,
                                      activeColor: AppTheme.primaryColor,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    )
                  ],
                );
              }),
            ]),
          )
        : Center(
            child: Container(
            child: SpinKitCircle(
              color: AppTheme.primaryColor,
              size: 60,
            ),
          ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
