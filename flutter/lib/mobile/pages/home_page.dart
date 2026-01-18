import 'package:flutter/material.dart';
import 'package:flutter_hbb/mobile/pages/server_page.dart';
import 'package:flutter_hbb/mobile/pages/settings_page.dart';
import 'package:flutter_hbb/web/settings_page.dart';
import 'package:flutter_hbb/design_system/design_system.dart';
import 'package:get/get.dart';
import '../../common.dart';
import '../../common/widgets/chat_page.dart';
import '../../models/platform_model.dart';
import '../../models/state_model.dart';
import 'connection_page.dart';

abstract class PageShape extends Widget {
  final String title = "";
  final Widget icon = Icon(null);
  final List<Widget> appBarActions = [];
}

class HomePage extends StatefulWidget {
  static final homeKey = GlobalKey<HomePageState>();

  HomePage() : super(key: homeKey);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  final List<PageShape> _pages = [];
  int _chatPageTabIndex = -1;
  bool get isChatPageCurrentTab => isAndroid
      ? _selectedIndex == _chatPageTabIndex
      : false; // change this when ios have chat page

  void refreshPages() {
    setState(() {
      initPages();
    });
  }

  @override
  void initState() {
    super.initState();
    initPages();
  }

  void initPages() {
    _pages.clear();
    if (!bind.isIncomingOnly()) {
      _pages.add(ConnectionPage(
        appBarActions: [],
      ));
    }
    if (isAndroid && !bind.isOutgoingOnly()) {
      _chatPageTabIndex = _pages.length;
      _pages.addAll([ChatPage(type: ChatPageType.mobileMain), ServerPage()]);
    }
    _pages.add(SettingsPage());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
        onWillPop: () async {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
          } else {
            return true;
          }
          return false;
        },
        child: Scaffold(
          backgroundColor: isDark ? AppleTheme.darkBackground : AppleTheme.lightBackground,
          appBar: AppBar(
            centerTitle: true,
            title: appTitle(),
            actions: _pages.elementAt(_selectedIndex).appBarActions,
            backgroundColor: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
            elevation: 0,
            toolbarHeight: AppleTheme.touchTargetMin + AppleTheme.spacing16,
          ),
          bottomNavigationBar: _buildAppleBottomNav(isDark),
          body: AnimatedSwitcher(
            duration: AppleTheme.durationNormal,
            child: _pages.elementAt(_selectedIndex),
          ),
        ));
  }

  Widget _buildAppleBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56 + AppleTheme.spacing8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _pages.asMap().entries.map((entry) {
              final index = entry.key;
              final page = entry.value;
              final isSelected = index == _selectedIndex;
              
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() {
                    if (_selectedIndex != index) {
                      _selectedIndex = index;
                      if (isChatPageCurrentTab) {
                        gFFI.chatModel.hideChatIconOverlay();
                        gFFI.chatModel.hideChatWindowOverlay();
                        gFFI.chatModel.mobileClearClientUnread(
                            gFFI.chatModel.currentKey.connId);
                      }
                    }
                  }),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: AppleTheme.touchTargetMin,
                      minWidth: AppleTheme.touchTargetMin,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: AppleTheme.durationNormal,
                          child: IconTheme(
                            data: IconThemeData(
                              size: 24,
                              color: isSelected 
                                ? AppleTheme.primaryBlue
                                : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                            ),
                            child: page.icon,
                          ),
                        ),
                        SizedBox(height: AppleTheme.spacing4),
                        AnimatedDefaultTextStyle(
                          duration: AppleTheme.durationNormal,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected 
                              ? AppleTheme.primaryBlue
                              : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                          ),
                          child: Text(page.title),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget appTitle() {
    final currentUser = gFFI.chatModel.currentUser;
    final currentKey = gFFI.chatModel.currentKey;
    if (isChatPageCurrentTab &&
        currentUser != null &&
        currentKey.peerId.isNotEmpty) {
      final connected =
          gFFI.serverModel.clients.any((e) => e.id == currentKey.connId);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: currentKey.isOut
                ? translate('Outgoing connection')
                : translate('Incoming connection'),
            child: Icon(
              currentKey.isOut
                  ? Icons.call_made_rounded
                  : Icons.call_received_rounded,
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${currentUser.firstName}   ${currentUser.id}",
                  ),
                  if (connected)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 133, 246, 199)),
                    ).marginSymmetric(horizontal: 2),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Text(bind.mainGetAppNameSync());
  }
}

class WebHomePage extends StatelessWidget {
  final connectionPage =
      ConnectionPage(appBarActions: <Widget>[const WebSettingsPage()]);

  @override
  Widget build(BuildContext context) {
    stateGlobal.isInMainPage = true;
    handleUnilink(context);
    return Scaffold(
      // backgroundColor: MyTheme.grayBg,
      appBar: AppBar(
        centerTitle: true,
        title: Text("${bind.mainGetAppNameSync()} (Preview)"),
        actions: connectionPage.appBarActions,
      ),
      body: connectionPage,
    );
  }

  handleUnilink(BuildContext context) {
    if (webInitialLink.isEmpty) {
      return;
    }
    final link = webInitialLink;
    webInitialLink = '';
    final splitter = ["/#/", "/#", "#/", "#"];
    var fakelink = '';
    for (var s in splitter) {
      if (link.contains(s)) {
        var list = link.split(s);
        if (list.length < 2 || list[1].isEmpty) {
          return;
        }
        list.removeAt(0);
        fakelink = "rustdesk://${list.join(s)}";
        break;
      }
    }
    if (fakelink.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(fakelink);
    if (uri == null) {
      return;
    }
    final args = urlLinkToCmdArgs(uri);
    if (args == null || args.isEmpty) {
      return;
    }
    bool isFileTransfer = false;
    bool isViewCamera = false;
    bool isTerminal = false;
    String? id;
    String? password;
    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--connect':
        case '--play':
          id = args[i + 1];
          i++;
          break;
        case '--file-transfer':
          isFileTransfer = true;
          id = args[i + 1];
          i++;
          break;
        case '--view-camera':
          isViewCamera = true;
          id = args[i + 1];
          i++;
          break;
        case '--terminal':
          isTerminal = true;
          id = args[i + 1];
          i++;
          break;
        case '--terminal-admin':
          setEnvTerminalAdmin();
          isTerminal = true;
          id = args[i + 1];
          i++;
          break;
        case '--password':
          password = args[i + 1];
          i++;
          break;
        default:
          break;
      }
    }
    if (id != null) {
      connect(context, id, 
        isFileTransfer: isFileTransfer, 
        isViewCamera: isViewCamera, 
        isTerminal: isTerminal,
        password: password);
    }
  }
}
