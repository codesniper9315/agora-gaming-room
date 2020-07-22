import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:isco_custom_widgets/isco_custom_widgets.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class GameRoom extends StatefulWidget {
  @override
  _GameRoomState createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  final Color primaryColor = Color(0xFF3502AC);
  final Color backgroundColor = Color(0xFF087F43);
  final Color backgroundColorLight = Color(0xFF1F8754);
  final Color backgroundColorDark = Color(0xFF20B067);
  final Color floatingActionColor = Color(0xFFFF4D00);
  final String appID = 'baa3dcaf38e0412aa1f580cea34dbb99';
  static final _users = <int>[];
  PageStyle _style;
  Widget topWidget;
  Widget leftWidget;
  Widget rightWidget;
  Widget bottomWidget;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() async {
    await _initAgoraRTCEngine();
    _addAgoraEventHandlers();
    await _joinChannel();
    _viewRows();
  }

  Future<void> _initAgoraRTCEngine() async {
    await AgoraRtcEngine.create(appID);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.enableAudio();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.dimensions = Size(3750, 2500);
    await AgoraRtcEngine.setVideoEncoderConfiguration(config);
  }

  Future<void> _joinChannel() async {
    await AgoraRtcEngine.joinChannel(null, 'gaming-room-1', null, 0);
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      setState(() {
        print('onJoinChannel: ' + channel + ', uid: ' + uid.toString());
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      print('onLeaveChannel');
      setState(() {
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        String info = 'userJoined: ' + uid.toString();
        print(info);
        _users.add(uid);
        _viewRows();
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        String info = 'userOffline: ' + uid.toString();
        print(info);
        _users.remove(uid);
        _viewRows();
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame =
        (int uid, int width, int height, int elapsed) {
      String info = 'firstRemoteVideo: ' +
          uid.toString() +
          ' ' +
          width.toString() +
          'x' +
          height.toString();
      print(info);
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    list.add(AgoraRenderWidget(0, local: true, preview: true));
    _users.forEach((int uid) =>
        list.add(AgoraRenderWidget(uid, local: false, preview: true)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video layout wrapper
  void _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        setState(() {
          bottomWidget = _videoView(views[0]);
          topWidget = null;
          leftWidget = null;
          rightWidget = null;
        });
        break;
      case 2:
        setState(() {
          bottomWidget = _videoView(views[0]);
          leftWidget = _videoView(views[1]);
          topWidget = null;
          rightWidget = null;
        });
        break;
      case 3:
        setState(() {
          bottomWidget = _videoView(views[0]);
          leftWidget = _videoView(views[1]);
          rightWidget = _videoView(views[2]);
          topWidget = null;
        });
        break;
      case 4:
        setState(() {
          bottomWidget = _videoView(views[0]);
          leftWidget = _videoView(views[1]);
          rightWidget = _videoView(views[2]);
          topWidget = _videoView(views[3]);
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    _style = new PageStyle(context, 414, 896);
    _style.initializePageStyles();
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            // _viewRows()
            _buildAppBar(),
            _buildStatusBar(),
            _buildGamePanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: _style.deviceWidth,
      height: _style.unitWidth * 70,
      color: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: _style.deviceWidth * 0.2,
            alignment: Alignment.center,
            child: Text(
              'Logo',
              style: TextStyle(
                color: Colors.white,
                fontSize: _style.unitFontSize * 20,
              ),
            ),
          ),
          Container(
            width: _style.deviceWidth * 0.8,
            height: _style.appBarHeight,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: IconButton(
              icon: Container(
                width: _style.unitWidth * 30,
                height: _style.unitWidth * 25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/images/menu.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              onPressed: () => null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: _style.deviceWidth,
      padding: EdgeInsets.symmetric(
        horizontal: _style.unitWidth * 10,
        vertical: _style.unitWidth * 10,
      ),
      color: backgroundColor.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              RoundText(
                radius: 30,
                color: primaryColor,
                borderColor: primaryColor,
                borderWidth: 0,
                text: 'N',
                textSize: _style.unitFontSize * 14,
                textColor: Colors.white,
                width: _style.unitWidth * 30,
                height: _style.unitWidth * 30,
              ),
              SizedBox(width: _style.unitWidth * 6),
              Text(
                '120',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: _style.unitFontSize * 12,
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              RoundText(
                radius: 30,
                color: primaryColor,
                borderColor: Colors.orange,
                borderWidth: 2,
                text: 'E',
                textSize: _style.unitFontSize * 14,
                textColor: Colors.white,
                width: _style.unitWidth * 30,
                height: _style.unitWidth * 30,
              ),
              SizedBox(width: _style.unitWidth * 6),
              Text(
                '260',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: _style.unitFontSize * 12,
                ),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                width: _style.unitWidth * 30,
                height: _style.unitWidth * 40,
                child: Image.asset(
                  'lib/assets/images/card.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: _style.unitWidth * 6),
              Text(
                '230',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: _style.unitFontSize * 30,
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              RoundText(
                radius: 30,
                color: primaryColor,
                borderColor: primaryColor,
                borderWidth: 0,
                text: 'S',
                textSize: _style.unitFontSize * 14,
                textColor: Colors.white,
                width: _style.unitWidth * 30,
                height: _style.unitWidth * 30,
              ),
              SizedBox(width: _style.unitWidth * 6),
              Text(
                '120',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: _style.unitFontSize * 12,
                ),
              )
            ],
          ),
          RoundImageButton(
            radius: 30,
            color: Colors.white,
            child: Container(
              width: _style.unitWidth * 20,
              height: _style.unitWidth * 20,
              child: Image.asset(
                'lib/assets/images/earphone.png',
                fit: BoxFit.cover,
              ),
            ),
            width: _style.unitWidth * 30,
            height: _style.unitWidth * 30,
          ),
          Container(
            width: _style.unitWidth * 25,
            height: _style.unitWidth * 25,
            child: Image.asset(
              'lib/assets/images/settings.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePanel() {
    return Container(
      width: _style.deviceWidth,
      height: _style.deviceHeight - _style.statusBarHeight - 130,
      color: backgroundColor.withOpacity(0.9),
      padding: EdgeInsets.symmetric(
        horizontal: _style.unitWidth * 6,
        vertical: _style.unitWidth * 15,
      ),
      child: Stack(
        children: <Widget>[
          _buildPlayerTop(),
          _buildPlayerLeft(),
          _buildPlayerRight(),
          _buildPlayerBottom(),
          _buildDernierPli(),
          _buildFloatingActionBar(),
        ],
      ),
    );
  }

  Widget _buildDernierPli() {
    return Positioned(
      top: _style.unitWidth * 20,
      right: _style.unitWidth * 20,
      child: Column(
        children: <Widget>[
          Text(
            'Dernier Pli',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: _style.unitWidth * 18,
            ),
          ),
          SizedBox(height: _style.unitWidth * 10),
          Container(
            width: _style.unitWidth * 60,
            height: _style.unitWidth * 80,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              children: List.generate(
                4,
                (index) => Container(
                  width: _style.unitWidth * 20,
                  height: _style.unitWidth * 30,
                  child: Image.asset(
                    'lib/assets/images/card.png',
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingActionBar() {
    return Positioned(
      bottom: _style.deviceHeight * 0.13,
      right: 0,
      child: Container(
        width: _style.unitWidth * 55,
        height: _style.unitWidth * 220,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              bottom: _style.unitWidth * 20,
              child: Container(
                width: _style.unitWidth * 45,
                height: _style.unitWidth * 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                padding: EdgeInsets.all(_style.unitWidth * 2),
                child: GridView.count(
                  crossAxisCount: 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: _style.unitWidth * 30,
                      height: _style.unitWidth * 45,
                      child: Image.asset(
                        'lib/assets/images/card.png',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CircularStepProgressIndicator(
                totalSteps: 60,
                currentStep: 15,
                selectedColor: backgroundColor.withOpacity(0.9),
                unselectedColor: Colors.orange[200],
                padding: 0,
                width: _style.unitWidth * 55,
                height: _style.unitWidth * 55,
                child: Center(
                  child: RoundImageButton(
                    radius: 30,
                    color: Colors.deepOrange,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('lib/assets/images/micro.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    width: _style.unitWidth * 50,
                    height: _style.unitWidth * 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTop() {
    return Container(
      width: _style.deviceWidth,
      height: _style.deviceHeight * 0.28,
      // color: Colors.grey.withOpacity(0.4),
      child: Column(
        children: <Widget>[
          Container(
            width: _style.unitWidth * 30,
            height: _style.unitWidth * 50,
            alignment: Alignment.center,
            child: _buildDummyCasino(),
          ),
          SizedBox(height: 10),
          Container(
            width: _style.deviceWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildCardList(align: MainAxisAlignment.start, dummy: true),
                Container(
                  width: _style.unitWidth * 60,
                  height: _style.unitWidth * 70,
                  alignment: Alignment.center,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: _style.unitWidth * 60,
                          height: _style.unitWidth * 60,
                          child: topWidget ??
                              Image.asset(
                                'lib/assets/images/boy-13.png',
                              ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: topWidget != null
                            ? _buildUncheckedCamera()
                            : _buildCheckedCamera(),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: topWidget != null
                            ? _buildOnline()
                            : _buildOffline(),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: RoundImageButton(
                          child: Container(
                            width: _style.unitWidth * 10,
                            height: _style.unitWidth * 10,
                            child: Image.asset(
                              'lib/assets/images/symbol.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          color: primaryColor,
                          radius: 30,
                          width: _style.unitWidth * 20,
                          height: _style.unitWidth * 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _style.deviceWidth * 0.41,
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'lib/assets/images/casino.png',
                    width: _style.unitWidth * 20,
                    height: _style.unitHeight * 30,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: _style.deviceWidth,
            alignment: Alignment.center,
            child: Text(
              'Taher',
              style: TextStyle(
                color: Colors.white70,
                fontSize: _style.unitWidth * 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: _style.unitWidth * 30,
            height: _style.unitWidth * 50,
            child: Image.asset('lib/assets/images/card.png', fit: BoxFit.cover),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerLeft() {
    return Positioned(
      top: _style.deviceHeight * 0.2,
      left: 0,
      child: Container(
        width: _style.deviceWidth * 0.4,
        height: _style.deviceHeight * 0.28,
        // color: Colors.red.withOpacity(0.4),
        alignment: Alignment.centerLeft,
        child: Column(
          children: <Widget>[
            Container(
              width: _style.unitWidth * 30,
              height: _style.unitWidth * 50,
              margin: EdgeInsets.only(right: _style.unitWidth * 20),
              alignment: Alignment.center,
              child: _buildDummyCasino(),
            ),
            SizedBox(height: 10),
            Container(
              width: _style.deviceWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: _style.unitWidth * 20,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'lib/assets/images/casino.png',
                      width: _style.unitWidth * 20,
                      height: _style.unitHeight * 30,
                    ),
                  ),
                  Container(
                    width: _style.unitWidth * 70,
                    height: _style.unitWidth * 70,
                    alignment: Alignment.center,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: _style.unitWidth * 60,
                            height: _style.unitWidth * 60,
                            child: leftWidget ??
                                Image.asset(
                                  'lib/assets/images/boy-13.png',
                                ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: leftWidget != null
                              ? _buildUncheckedCamera()
                              : _buildCheckedCamera(),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: leftWidget != null
                              ? _buildOnline()
                              : _buildOffline(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: _style.unitWidth * 30,
                    height: _style.unitWidth * 50,
                    child: Image.asset(
                      'lib/assets/images/card.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: _style.deviceWidth,
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: _style.unitWidth * 30),
              child: Text(
                'Zineb',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: _style.unitWidth * 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildCardList(align: MainAxisAlignment.start, dummy: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRight() {
    return Positioned(
      top: _style.deviceHeight * 0.2,
      right: 0,
      child: Container(
        width: _style.deviceWidth * 0.4,
        height: _style.deviceHeight * 0.28,
        // color: Colors.yellow.withOpacity(0.4),
        alignment: Alignment.centerRight,
        child: Column(
          children: <Widget>[
            Container(
              width: _style.unitWidth * 30,
              height: _style.unitWidth * 50,
              margin: EdgeInsets.only(left: _style.unitWidth * 20),
              alignment: Alignment.center,
              child: _buildDummyCasino(),
            ),
            SizedBox(height: 10),
            Container(
              width: _style.deviceWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircularStepProgressIndicator(
                    totalSteps: 60,
                    currentStep: 15,
                    selectedColor: backgroundColor.withOpacity(0.9),
                    unselectedColor: Colors.yellow.withOpacity(0.9),
                    padding: 0,
                    width: _style.unitWidth * 50,
                    height: _style.unitWidth * 50,
                    child: Center(
                      child: Text(
                        '45',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: _style.unitFontSize * 22,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: _style.unitWidth * 60,
                    height: _style.unitWidth * 70,
                    alignment: Alignment.center,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: _style.unitWidth * 60,
                            height: _style.unitWidth * 60,
                            child: rightWidget ??
                                Image.asset(
                                  'lib/assets/images/boy-18.png',
                                ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: rightWidget != null
                              ? _buildUncheckedCamera()
                              : _buildCheckedCamera(),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: rightWidget != null
                              ? _buildOnline()
                              : _buildOffline(),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: RoundImageButton(
                            child: Container(
                              width: _style.unitWidth * 10,
                              height: _style.unitWidth * 10,
                              child: Image.asset(
                                'lib/assets/images/symbol.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            color: primaryColor,
                            radius: 30,
                            width: _style.unitWidth * 20,
                            height: _style.unitWidth * 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: _style.unitWidth * 20,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'lib/assets/images/casino.png',
                      width: _style.unitWidth * 20,
                      height: _style.unitHeight * 30,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: _style.deviceWidth,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: _style.unitWidth * 30),
              child: Text(
                'Youssef',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: _style.unitWidth * 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildCardList(align: MainAxisAlignment.end, dummy: false),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBottom() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: _style.deviceWidth,
        height: _style.deviceHeight * 0.32,
        // color: Colors.white38,
        child: Column(
          children: <Widget>[
            Container(
              width: _style.unitWidth * 30,
              height: _style.unitWidth * 50,
              child: Image.asset(
                'lib/assets/images/card.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 2),
            Expanded(
              child: GridView.count(
                crossAxisCount: 5,
                mainAxisSpacing: 2,
                padding: EdgeInsets.symmetric(
                  horizontal: _style.unitWidth * 90,
                ),
                children: List.generate(
                  10,
                  (index) => Container(
                    width: _style.unitWidth * 30,
                    height: _style.unitWidth * 50,
                    child: Image.asset(
                      'lib/assets/images/card.png',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: _style.deviceWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: _style.deviceWidth * 0.4,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'lib/assets/images/casino.png',
                      width: _style.unitWidth * 20,
                      height: _style.unitHeight * 30,
                    ),
                  ),
                  Container(
                    width: _style.unitWidth * 70,
                    height: _style.unitWidth * 70,
                    alignment: Alignment.center,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: _style.unitWidth * 60,
                            height: _style.unitWidth * 60,
                            child: bottomWidget ??
                                Image.asset(
                                  'lib/assets/images/boy-13.png',
                                  fit: BoxFit.cover,
                                ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: bottomWidget != null
                              ? _buildUncheckedCamera()
                              : _buildCheckedCamera(),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: bottomWidget != null
                              ? _buildOnline()
                              : _buildOffline(),
                        ),
                      ],
                    ),
                  ),
                  _buildCardList(align: MainAxisAlignment.end, dummy: false),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: _style.deviceWidth,
              alignment: Alignment.center,
              child: Text(
                'Othmane',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: _style.unitWidth * 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyCasino() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: _style.unitWidth * 20,
            height: _style.unitWidth * 40,
            child: Image.asset(
              'lib/assets/images/casino.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: _style.unitWidth * 4,
          left: _style.unitWidth * 4,
          child: Container(
            width: _style.unitWidth * 20,
            height: _style.unitWidth * 40,
            child: Image.asset(
              'lib/assets/images/casino.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: _style.unitWidth * 8,
          left: _style.unitWidth * 8,
          child: Container(
            width: _style.unitWidth * 20,
            height: _style.unitWidth * 40,
            child: Image.asset(
              'lib/assets/images/casino.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardList({MainAxisAlignment align, bool dummy}) {
    return Container(
      width: _style.deviceWidth * 0.4,
      child: Row(
        mainAxisAlignment: align,
        children: List.generate(
          5,
          (index) => Column(
            children: <Widget>[
              index == 0
                  ? Container(
                      padding: EdgeInsets.only(
                        top: _style.unitWidth * 2,
                        left: _style.unitWidth * 2,
                        right: _style.unitWidth * 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        '230',
                        style: TextStyle(
                          fontSize: _style.unitFontSize * 10,
                        ),
                      ),
                    )
                  : Text(
                      '+20',
                      style: TextStyle(
                        fontSize: _style.unitFontSize * 12,
                        color: Colors.yellow.withOpacity(0.9),
                      ),
                    ),
              dummy && index > 0
                  ? Container(
                      width: _style.unitWidth * 24,
                      height: _style.unitWidth * 40,
                      child: _buildDummyCard(),
                    )
                  : Container(
                      width: _style.unitWidth * 20,
                      height: _style.unitWidth * 30,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: Image.asset(
                        'lib/assets/images/card.png',
                        fit: BoxFit.cover,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDummyCard() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: _style.unitWidth * 2,
          child: Container(
            width: _style.unitWidth * 20,
            height: _style.unitWidth * 30,
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: Image.asset(
              'lib/assets/images/card.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: _style.unitWidth * 10,
          left: 0,
          child: Container(
            width: _style.unitWidth * 20,
            height: _style.unitWidth * 30,
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: Image.asset(
              'lib/assets/images/card.png',
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCheckedCamera() {
    return RoundImageButton(
      child: Container(
        width: _style.unitWidth * 10,
        height: _style.unitWidth * 10,
        child: Image.asset(
          'lib/assets/images/cinema-check.png',
          fit: BoxFit.cover,
        ),
      ),
      color: primaryColor,
      radius: 30,
      width: _style.unitWidth * 20,
      height: _style.unitWidth * 20,
    );
  }

  Widget _buildUncheckedCamera() {
    return RoundImageButton(
      child: Container(
        width: _style.unitWidth * 10,
        height: _style.unitWidth * 10,
        child: Image.asset(
          'lib/assets/images/cinema-cancel.png',
          fit: BoxFit.cover,
        ),
      ),
      color: primaryColor,
      radius: 30,
      width: _style.unitWidth * 20,
      height: _style.unitWidth * 20,
    );
  }

  Widget _buildOffline() {
    return Container(
      width: _style.unitWidth * 15,
      height: _style.unitHeight * 15,
      alignment: Alignment.bottomLeft,
      child: Image.asset(
        'lib/assets/images/offline.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildOnline() {
    return Container(
      width: _style.unitWidth * 10,
      height: _style.unitHeight * 10,
      alignment: Alignment.bottomLeft,
      child: Image.asset(
        'lib/assets/images/online.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
