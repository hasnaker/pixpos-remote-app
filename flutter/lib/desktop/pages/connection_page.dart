// main window right pane

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common/widgets/connection_page_title.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/desktop/widgets/popup_menu.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_hbb/models/peer_model.dart';

import '../../common.dart';
import '../../common/formatter/id_formatter.dart';
import '../../common/widgets/peer_tab_page.dart';
import '../../common/widgets/autocomplete.dart';
import '../../models/platform_model.dart';
import '../../desktop/widgets/material_mod_popup_menu.dart' as mod_menu;

// Import Apple Design System
import 'package:flutter_hbb/design_system/apple_theme.dart';
import 'package:flutter_hbb/design_system/apple_typography.dart';
import 'package:flutter_hbb/design_system/components/apple_card.dart';
import 'package:flutter_hbb/design_system/components/apple_button.dart';
import 'package:flutter_hbb/design_system/components/apple_text_field.dart';
import 'package:flutter_hbb/design_system/components/status_indicator.dart';

class OnlineStatusWidget extends StatefulWidget {
  const OnlineStatusWidget({Key? key, this.onSvcStatusChanged})
      : super(key: key);

  final VoidCallback? onSvcStatusChanged;

  @override
  State<OnlineStatusWidget> createState() => _OnlineStatusWidgetState();
}

/// State for the connection page.
class _OnlineStatusWidgetState extends State<OnlineStatusWidget> {
  final _svcStopped = Get.find<RxBool>(tag: 'stop-service');
  final _svcIsUsingPublicServer = true.obs;
  Timer? _updateTimer;

  double get em => 14.0;
  double? get height => bind.isIncomingOnly() ? null : em * 3;

  void onUsePublicServerGuide() {
    const url = "https://rustdesk.com/pricing";
    canLaunchUrlString(url).then((can) {
      if (can) {
        launchUrlString(url);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = periodic_immediate(Duration(seconds: 1), () async {
      updateStatus();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncomingOnly = bind.isIncomingOnly();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    startServiceWidget() => Offstage(
          offstage: !_svcStopped.value,
          child: GestureDetector(
            onTap: () async {
              await start_service(true);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                translate("Start service"),
                style: AppleTypography.subheadline(context).copyWith(
                  color: AppleTheme.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ).marginOnly(left: AppleTheme.spacing12),
        );

    setupServerWidget() => Flexible(
          child: Offstage(
            offstage: !(!_svcStopped.value &&
                stateGlobal.svcStatus.value == SvcStatus.ready &&
                _svcIsUsingPublicServer.value),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(', ', style: AppleTypography.subheadline(context)),
                Flexible(
                  child: GestureDetector(
                    onTap: onUsePublicServerGuide,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        translate('setup_server_tip'),
                        style: AppleTypography.subheadline(context).copyWith(
                          color: AppleTheme.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );

    // Get status color and connection status
    ConnectionStatus connectionStatus;
    if (_svcStopped.value || stateGlobal.svcStatus.value == SvcStatus.connecting) {
      connectionStatus = ConnectionStatus.connecting;
    } else if (stateGlobal.svcStatus.value == SvcStatus.ready) {
      connectionStatus = ConnectionStatus.connected;
    } else {
      connectionStatus = ConnectionStatus.error;
    }

    basicWidget() => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StatusIndicator(
              status: connectionStatus,
              size: AppleTheme.statusIndicatorSize,
            ).marginSymmetric(horizontal: AppleTheme.spacing12),
            Container(
              width: isIncomingOnly ? 226 : null,
              child: _buildConnStatusMsg(),
            ),
            // stop
            if (!isIncomingOnly) startServiceWidget(),
            // ready && public
            // No need to show the guide if is custom client.
            if (!isIncomingOnly) setupServerWidget(),
          ],
        );

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(vertical: AppleTheme.spacing8),
      child: Obx(() => isIncomingOnly
          ? Column(
              children: [
                basicWidget(),
                Align(
                        child: startServiceWidget(),
                        alignment: Alignment.centerLeft)
                    .marginOnly(top: AppleTheme.spacing4, left: AppleTheme.spacing24),
              ],
            )
          : basicWidget()),
    ).paddingOnly(right: isIncomingOnly ? AppleTheme.spacing8 : 0);
  }

  _buildConnStatusMsg() {
    widget.onSvcStatusChanged?.call();
    return Text(
      _svcStopped.value
          ? translate("Service is not running")
          : stateGlobal.svcStatus.value == SvcStatus.connecting
              ? translate("connecting_status")
              : stateGlobal.svcStatus.value == SvcStatus.notReady
                  ? translate("not_ready_status")
                  : translate('Ready'),
      style: AppleTypography.subheadline(context),
    );
  }

  updateStatus() async {
    final status =
        jsonDecode(await bind.mainGetConnectStatus()) as Map<String, dynamic>;
    final statusNum = status['status_num'] as int;
    if (statusNum == 0) {
      stateGlobal.svcStatus.value = SvcStatus.connecting;
    } else if (statusNum == -1) {
      stateGlobal.svcStatus.value = SvcStatus.notReady;
    } else if (statusNum == 1) {
      stateGlobal.svcStatus.value = SvcStatus.ready;
    } else {
      stateGlobal.svcStatus.value = SvcStatus.notReady;
    }
    _svcIsUsingPublicServer.value = await bind.mainIsUsingPublicServer();
    try {
      stateGlobal.videoConnCount.value = status['video_conn_count'] as int;
    } catch (_) {}
  }
}

/// Connection page for connecting to a remote peer.
class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

/// State for the connection page.
class _ConnectionPageState extends State<ConnectionPage>
    with SingleTickerProviderStateMixin, WindowListener {
  /// Controller for the id input bar.
  final _idController = IDTextEditingController();

  final RxBool _idInputFocused = false.obs;
  final FocusNode _idFocusNode = FocusNode();
  final TextEditingController _idEditingController = TextEditingController();

  String selectedConnectionType = 'Connect';

  bool isWindowMinimized = false;

  final AllPeersLoader _allPeersLoader = AllPeersLoader();

  // https://github.com/flutter/flutter/issues/157244
  Iterable<Peer> _autocompleteOpts = [];

  final _menuOpen = false.obs;

  @override
  void initState() {
    super.initState();
    _allPeersLoader.init(setState);
    _idFocusNode.addListener(onFocusChanged);
    if (_idController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final lastRemoteId = await bind.mainGetLastRemoteId();
        if (lastRemoteId != _idController.id) {
          setState(() {
            _idController.id = lastRemoteId;
          });
        }
      });
    }
    Get.put<TextEditingController>(_idEditingController);
    Get.put<IDTextEditingController>(_idController);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    _idController.dispose();
    windowManager.removeListener(this);
    _allPeersLoader.clear();
    _idFocusNode.removeListener(onFocusChanged);
    _idFocusNode.dispose();
    _idEditingController.dispose();
    if (Get.isRegistered<IDTextEditingController>()) {
      Get.delete<IDTextEditingController>();
    }
    if (Get.isRegistered<TextEditingController>()) {
      Get.delete<TextEditingController>();
    }
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    super.onWindowEvent(eventName);
    if (eventName == 'minimize') {
      isWindowMinimized = true;
    } else if (eventName == 'maximize' || eventName == 'restore') {
      if (isWindowMinimized && isWindows) {
        // windows can't update when minimized.
        Get.forceAppUpdate();
      }
      isWindowMinimized = false;
    }
  }

  @override
  void onWindowEnterFullScreen() {
    // Remove edge border by setting the value to zero.
    stateGlobal.resizeEdgeSize.value = 0;
  }

  @override
  void onWindowLeaveFullScreen() {
    // Restore edge border to default edge size.
    stateGlobal.resizeEdgeSize.value = stateGlobal.isMaximized.isTrue
        ? kMaximizeEdgeSize
        : windowResizeEdgeSize;
  }

  @override
  void onWindowClose() {
    super.onWindowClose();
    bind.mainOnMainWindowClose();
  }

  void onFocusChanged() {
    _idInputFocused.value = _idFocusNode.hasFocus;
    if (_idFocusNode.hasFocus) {
      if (_allPeersLoader.needLoad) {
        _allPeersLoader.getAllPeers();
      }

      final textLength = _idEditingController.value.text.length;
      // Select all to facilitate removing text, just following the behavior of address input of chrome.
      _idEditingController.selection =
          TextSelection(baseOffset: 0, extentOffset: textLength);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutgoingOnly = bind.isOutgoingOnly();
    return Column(
      children: [
        Expanded(
            child: Column(
          children: [
            Row(
              children: [
                Flexible(child: _buildRemoteIDTextField(context)),
              ],
            ).marginOnly(top: AppleTheme.spacing24),
            SizedBox(height: AppleTheme.spacing12),
            Divider(
              height: 1,
              color: AppleTheme.separatorColor(context),
            ).paddingOnly(right: AppleTheme.spacing12),
            Expanded(child: PeerTabPage()),
          ],
        ).paddingOnly(left: AppleTheme.spacing12)),
        if (!isOutgoingOnly) Divider(height: 1, color: AppleTheme.separatorColor(context)),
        if (!isOutgoingOnly) OnlineStatusWidget()
      ],
    );
  }

  /// Callback for the connect button.
  /// Connects to the selected peer.
  void onConnect(
      {bool isFileTransfer = false,
      bool isViewCamera = false,
      bool isTerminal = false}) {
    var id = _idController.id;
    connect(context, id,
        isFileTransfer: isFileTransfer,
        isViewCamera: isViewCamera,
        isTerminal: isTerminal);
  }

  /// UI for the remote ID TextField.
  /// Search for a peer.
  Widget _buildRemoteIDTextField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    var w = AppleCard(
      padding: EdgeInsets.all(AppleTheme.spacing20),
      child: Column(
        children: [
          getConnectionPageTitle(context, false).marginOnly(bottom: AppleTheme.spacing16),
          Row(
            children: [
              Expanded(
                  child: RawAutocomplete<Peer>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    _autocompleteOpts = const Iterable<Peer>.empty();
                  } else if (_allPeersLoader.peers.isEmpty &&
                      !_allPeersLoader.isPeersLoaded) {
                    Peer emptyPeer = Peer(
                      id: '',
                      username: '',
                      hostname: '',
                      alias: '',
                      platform: '',
                      tags: [],
                      hash: '',
                      password: '',
                      forceAlwaysRelay: false,
                      rdpPort: '',
                      rdpUsername: '',
                      loginName: '',
                      device_group_name: '',
                      note: '',
                    );
                    _autocompleteOpts = [emptyPeer];
                  } else {
                    String textWithoutSpaces =
                        textEditingValue.text.replaceAll(" ", "");
                    if (int.tryParse(textWithoutSpaces) != null) {
                      textEditingValue = TextEditingValue(
                        text: textWithoutSpaces,
                        selection: textEditingValue.selection,
                      );
                    }
                    String textToFind = textEditingValue.text.toLowerCase();
                    _autocompleteOpts = _allPeersLoader.peers
                        .where((peer) =>
                            peer.id.toLowerCase().contains(textToFind) ||
                            peer.username
                                .toLowerCase()
                                .contains(textToFind) ||
                            peer.hostname
                                .toLowerCase()
                                .contains(textToFind) ||
                            peer.alias.toLowerCase().contains(textToFind))
                        .toList();
                  }
                  return _autocompleteOpts;
                },
                focusNode: _idFocusNode,
                textEditingController: _idEditingController,
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  updateTextAndPreserveSelection(
                      fieldTextEditingController, _idController.text);
                  return Obx(() => AnimatedContainer(
                    duration: AppleTheme.durationNormal,
                    decoration: BoxDecoration(
                      color: isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground,
                      borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                      border: Border.all(
                        color: _idInputFocused.value 
                            ? AppleTheme.primaryBlue 
                            : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightSecondary),
                        width: _idInputFocused.value ? 2 : 1,
                      ),
                    ),
                    child: TextField(
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.visiblePassword,
                          focusNode: fieldFocusNode,
                          style: AppleTypography.title3(context).copyWith(
                            fontFamily: 'WorkSans',
                            height: 1.4,
                          ),
                          maxLines: 1,
                          cursorColor: AppleTheme.primaryBlue,
                          decoration: InputDecoration(
                              filled: false,
                              counterText: '',
                              hintText: _idInputFocused.value
                                  ? null
                                  : translate('Enter Remote ID'),
                              hintStyle: AppleTypography.title3(context).copyWith(
                                color: AppleTheme.secondaryTextColor(context),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppleTheme.spacing16, 
                                  vertical: AppleTheme.spacing12),
                              border: InputBorder.none),
                          controller: fieldTextEditingController,
                          inputFormatters: [IDTextInputFormatter()],
                          onChanged: (v) {
                            _idController.id = v;
                          },
                          onSubmitted: (_) {
                            onConnect();
                          },
                        ).workaroundFreezeLinuxMint(),
                  ));
                },
                onSelected: (option) {
                  setState(() {
                    _idController.id = option.id;
                    FocusScope.of(context).unfocus();
                  });
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<Peer> onSelected,
                    Iterable<Peer> options) {
                  options = _autocompleteOpts;
                  double maxHeight = options.length * 50;
                  if (options.length == 1) {
                    maxHeight = 52;
                  } else if (options.length == 3) {
                    maxHeight = 146;
                  } else if (options.length == 4) {
                    maxHeight = 193;
                  }
                  maxHeight = maxHeight.clamp(0, 200);

                  return Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        decoration: BoxDecoration(
                          boxShadow: AppleTheme.shadow(context),
                          borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                            child: Material(
                              color: AppleTheme.surfaceColor(context),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxHeight,
                                  maxWidth: 319,
                                ),
                                child: _allPeersLoader.peers.isEmpty &&
                                        !_allPeersLoader.isPeersLoaded
                                    ? Container(
                                        height: 80,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(AppleTheme.primaryBlue),
                                          ),
                                        ))
                                    : Padding(
                                        padding: EdgeInsets.only(top: AppleTheme.spacing8),
                                        child: ListView(
                                          children: options
                                              .map((peer) =>
                                                  AutocompletePeerTile(
                                                      onSelect: () =>
                                                          onSelected(peer),
                                                      peer: peer))
                                              .toList(),
                                        ),
                                      ),
                              ),
                            ))),
                  );
                },
              )),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: AppleTheme.spacing16),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              AppleButton.primary(
                text: translate("Connect"),
                onPressed: () => onConnect(),
                size: AppleButtonSize.small,
              ),
              SizedBox(width: AppleTheme.spacing8),
              Container(
                height: AppleTheme.buttonHeightSmall,
                width: AppleTheme.buttonHeightSmall,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppleTheme.darkTertiary : AppleTheme.lightSecondary,
                  ),
                  borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
                ),
                child: Center(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      var offset = Offset(0, 0);
                      return Obx(() => InkWell(
                            borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
                            child: _menuOpen.value
                                ? Transform.rotate(
                                    angle: pi,
                                    child: Icon(IconFont.more, size: 14, color: AppleTheme.primaryBlue),
                                  )
                                : Icon(IconFont.more, size: 14, color: AppleTheme.secondaryTextColor(context)),
                            onTapDown: (e) {
                              offset = e.globalPosition;
                            },
                            onTap: () async {
                              _menuOpen.value = true;
                              final x = offset.dx;
                              final y = offset.dy;
                              await mod_menu
                                  .showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(x, y, x, y),
                                items: [
                                  (
                                    'Transfer file',
                                    () => onConnect(isFileTransfer: true)
                                  ),
                                  (
                                    'View camera',
                                    () => onConnect(isViewCamera: true)
                                  ),
                                  (
                                    '${translate('Terminal')} (beta)',
                                    () => onConnect(isTerminal: true)
                                  ),
                                ]
                                    .map((e) => MenuEntryButton<String>(
                                          childBuilder: (TextStyle? style) =>
                                              Text(
                                            translate(e.$1),
                                            style: style,
                                          ),
                                          proc: () => e.$2(),
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  kDesktopMenuPadding.left),
                                          dismissOnClicked: true,
                                        ))
                                    .map((e) => e.build(
                                        context,
                                        const MenuConfig(
                                            commonColor: CustomPopupMenuTheme
                                                .commonColor,
                                            height:
                                                CustomPopupMenuTheme.height,
                                            dividerHeight:
                                                CustomPopupMenuTheme
                                                    .dividerHeight)))
                                    .expand((i) => i)
                                    .toList(),
                                elevation: 8,
                              )
                                  .then((_) {
                                _menuOpen.value = false;
                              });
                            },
                          ));
                    },
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
    return Container(
        constraints: const BoxConstraints(maxWidth: 600), child: w);
  }
}
