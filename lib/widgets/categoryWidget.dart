import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';
import 'package:wowtalent/screen/mainScreens/explore/categories.dart';

class CategoryStoryItem extends StatelessWidget {
  final String name;
  final IconData icon;
  const CategoryStoryItem({
    Key key,
    this.icon,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => Category(
                  categoryName: name,
                )));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        height: MediaQuery.of(context).size.height * 0.05,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppTheme.backgroundColor,
            border: Border.all(color: AppTheme.primaryColor, width: 2)),
        child: Center(
          child: Row(
            children: [
              icon != Icons.face
                  ? Icon(icon)
                  : Container(
                      height: 25,
                      width: 25,
                      child: Image.asset(
                        'assets/images/acting.png',
                        fit: BoxFit.fitWidth,
                      )),
              Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
              Text(
                name,
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
