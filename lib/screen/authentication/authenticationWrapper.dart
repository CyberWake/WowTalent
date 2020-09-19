import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wowtalent/screen/authentication/methods/loginForm.dart';
import 'package:wowtalent/screen/authentication/methods/registerForm.dart';

class Authentication extends StatefulWidget {
  bool _isLogin = true;
  Authentication(this._isLogin);
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  double _heightOne;
  double _fontOne;
  Size _size;

  void _changeMethod(bool value){
    setState(() {
      widget._isLogin = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _heightOne = (_size.height * 0.007) / 5;
    _fontOne = (_size.height * 0.015) / 11;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: _size.width,
            height: _size.height * 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange[300],
                  Colors.orange[500],
                  Colors.orange[800],
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50)
              )
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: _heightOne * 50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${widget._isLogin ? "LOGIN" : "REGISTER"}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _fontOne * 50,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  Text(
                    "${widget._isLogin ? "Welcome Back." : "We'll be glad if you join us."}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontOne * 20,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(
                top: _size.height * 0.3,
              ),
              height: _size.height * 0.7,
              width: _size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(
                  color: Colors.purple[300].withOpacity(0.4),
                  offset: Offset(0.0, -10.0), //(x,y)
                  blurRadius: 15.0,
                ),],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)
                )
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: widget._isLogin ? LoginForm(
                    changeMethod: _changeMethod,
                  ) : RegisterForm(
                    changeMethod: _changeMethod,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
