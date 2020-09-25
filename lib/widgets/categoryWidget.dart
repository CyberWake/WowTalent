import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/screen/mainScreens/explore/categories.dart';

class CategoryStoryItem extends StatelessWidget {
  final String name;
  const CategoryStoryItem({
    Key key,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => Category(categoryName: name,)));
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: Colors.orange.shade400)),
            child: Text(
              name,
              style: TextStyle(
                  color: Colors.orange.shade400,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}