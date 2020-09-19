import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wowtalent/database/firebase_provider.dart';
import 'package:wowtalent/model/video_info.dart';
import 'package:wowtalent/screen/mainScreens/uploadVideo/video_uploader_widget/player.dart';
import 'package:wowtalent/widgets/search_category_widget.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {

  final thumbWidth = 100;
  final thumbHeight = 150;
  double staggeredHeight = 200.0;
  double heightIndex1;
  double heightIndex2;
  double heightIndex3;


  List<VideoInfo> _videos = <VideoInfo>[];
  List searchCategories = [
    "Vocals",
    "Precussions",
    "Performing Arts",
    "Instrumental",
    "Videography",
    "Stand up Comedy",
    "DIY",
  ];

  @override
  void initState() {
    super.initState();
    UserVideoStore.listenToAllVideos((newVideos) {
      if(this.mounted){
        setState(() {
          _videos = newVideos;
        });
      }
    });
  }
  storeAspectRatio(int index){
    if(index % 3 == 0){
      heightIndex1 = _videos[index].aspectRatio;
    }else if(index % 3 == 1){
      heightIndex2 = _videos[index].aspectRatio;
    }else if(index % 3 == 2){
      heightIndex3 = _videos[index].aspectRatio;
    }
  }
  increaseHeight(){
    if(heightIndex1 > heightIndex2 && heightIndex1 > heightIndex3){
      staggeredHeight += heightIndex1;
    }else if(heightIndex2 > heightIndex1 && heightIndex2 > heightIndex3){
      staggeredHeight += heightIndex2;
    }else if(heightIndex3 > heightIndex1 && heightIndex3 > heightIndex2){
      staggeredHeight += heightIndex3;
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width,
              height: size.height * 0.05,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      children: List.generate(searchCategories.length, (index) {
                        return CategoryStoryItem(
                          name: searchCategories[index],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "TRENDING",
                style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Container(
              width: size.width,
              height: size.height * 0.21,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: List.generate(_videos.length, (index) {
                  final video = _videos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (context) {
                          return Player(
                            video: video,
                          );
                        },
                      ),);
                    },
                    child: Container(
                      width: size.width * 0.2,
                      height: size.height * 0.2,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                            image: NetworkImage(video.thumbUrl),
                            fit: BoxFit.fitWidth
                        ),
                        borderRadius: BorderRadius.circular(10.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: Offset(0.0, 10.0), //(x,y)
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "STAFF PICKS",
                style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Container(
              width: size.width,
              height: size.height * 0.21,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: List.generate(_videos.length, (index) {
                  final video = _videos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (context) {
                          return Player(
                            video: video,
                          );
                        },
                      ),);
                    },
                    child: Container(
                      width: size.width * 0.2,
                      height: size.height * 0.2,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                            image: NetworkImage(video.thumbUrl),
                            fit: BoxFit.fitWidth
                        ),
                        borderRadius: BorderRadius.circular(10.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: Offset(0.0, 10.0), //(x,y)
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "LATEST VIDEOS",
                style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Container(
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: StaggeredGridView.countBuilder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                itemCount: _videos.length,
                itemBuilder: (BuildContext context, int index){
                  dynamic video = _videos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Player(
                            video: video,
                          );
                        },
                      ),);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(video.thumbUrl),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  );
                },
                staggeredTileBuilder: (int index) {
                  return StaggeredTile.count(1, 1 / _videos[index].aspectRatio);
                },
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}