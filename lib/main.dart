import 'dart:async';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  bool _isLogin = false;
  String _message = 'Log in/out by pressing the buttons below.';
  Map userProfile;

  Future<Null> _login() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;

//keytool -exportcert -alias androiddebugkey -keystore "C:\Users\Nivelle Mendiola\.android\debug.keystore" | "C:\OpenSSL\bin\openssl" sha1 -binary | "C:\OpenSSL\bin\openssl" base64
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,first_name,last_name,email&access_token=${accessToken.token}');

        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);

        setState(() {
          _isLogin = true;
          userProfile = profile;
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  Future<Null> _logOut() async {
    await facebookSignIn.logOut();
    _showMessage('Logged out.');
    _isLogin = false;
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
            child: _isLogin
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(
                        userProfile['picture']['data']['url'],
                        height: 50,
                        width: 50,
                      ),
                      Text(userProfile['name']),
                      RaisedButton(
                        child: Text('Logout'),
                        onPressed: _logOut,
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Login'),
                        onPressed: _login,
                      )
                    ],
                  )),
      ),
    );
  }
}
