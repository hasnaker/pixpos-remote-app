import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/widgets/animated_rotation_widget.dart';
import 'package:flutter_hbb/common/widgets/custom_password.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/desktop/pages/connection_page.dart';
import 'package:flutter_hbb/desktop/pages/desktop_setting_page.dart';
import 'package:flutter_hbb/desktop/pages/desktop_tab_page.dart';
import 'package:flutter_hbb/desktop/widgets/update_progress.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:flutter_hbb/plugin/ui_manager.dart';
import 'package:flutter_hbb/utils/multi_window_manager.dart';
import 'package:flutter_hbb/utils/platform_channel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

import '../widgets/button.dart';

// TeamViewer-style colors
class TVColors {
  static const primary = Color(0xFF0E72ED);
  static const primaryDark = Color(0xFF0052CC);
  static const background = Color(0xFFF5F5F5);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const border = Color(0xFFE0E0E0);
  static const success = Color(0xFF4CAF50);
}

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({Key? key}) : super(key: key);

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

const borderColor = Color(0xFF2F65BA);

final RxBool _idCopied = false.obs;
final RxBool _passwordCopied = false.obs;

class _DesktopHomePageState extends State<DesktopHomePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final _leftPaneScrollController = ScrollController();
  final _partnerIdController = TextEditingController();
  final _partnerIdFocusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;
  var systemError = '';
  StreamSubscription? _uniLinksSubscription;
  var svcStopped = false.obs;
  var watchIsCanScreenRecording = false;
  var watchIsProcessTrust = false;
  var watchIsInputMonitoring = false;
  var watchIsCanRecordAudio = false;
  Timer? _updateTimer;
  bool isCardClosed = false;

  final RxBool _editHover = false.obs;
  final RxBool _block = false.obs;
  final GlobalKey _childKey = GlobalKey();

  @override
  void dispose() {
    _partnerIdController.dispose();
    _partnerIdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildBlock(
      child: Container(
        color: TVColors.background,
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left panel - Allow Remote Control
                    Expanded(child: _buildAllowControlPanel()),
                    const SizedBox(width: 24),
                    // Right panel - Connect to Partner
                    Expanded(child: _buildConnectPanel()),
                  ],
                ),
              ),
            ),
            // Status bar
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: TVColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          // Logo
          Image.asset(
            'assets/logo.png',
            height: 32,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.desktop_windows,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'PixPos Remote',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => DesktopTabPage.onAddSetting(),
            tooltip: translate('Settings'),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildAllowControlPanel() {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Consumer<ServerModel>(
        builder: (context, model, child) {
          return Container(
            decoration: BoxDecoration(
              color: TVColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TVColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: TVColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TVColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.screen_share,
                          color: TVColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Uzaktan Kontrol İzni Ver',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TVColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bu bilgisayara bağlanmak için aşağıdaki bilgileri paylaşın:',
                          style: TextStyle(
                            fontSize: 13,
                            color: TVColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Your ID
                        _buildInfoRow(
                          label: 'Sizin ID\'niz',
                          value: model.serverId.text.isEmpty 
                              ? 'Bağlanıyor...' 
                              : model.serverId.text,
                          isLoading: model.serverId.text.isEmpty,
                          onCopy: () {
                            if (model.serverId.text.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: model.serverId.text));
                              showToast(translate("Copied"));
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password
                        _buildInfoRow(
                          label: 'Şifre',
                          value: model.serverPasswd.text.isEmpty 
                              ? '------' 
                              : model.serverPasswd.text,
                          isPassword: true,
                          onCopy: () {
                            if (model.serverPasswd.text.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: model.serverPasswd.text));
                              showToast(translate("Copied"));
                            }
                          },
                          onRefresh: () => bind.mainUpdateTemporaryPassword(),
                        ),
                        const Spacer(),
                        // Connection status
                        _buildConnectionStatus(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isLoading = false,
    bool isPassword = false,
    VoidCallback? onCopy,
    VoidCallback? onRefresh,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: TVColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: TVColors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: TVColors.border),
          ),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(TVColors.primary),
                  ),
                )
              else
                Expanded(
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: TVColors.textPrimary,
                      fontFamily: 'monospace',
                      letterSpacing: isPassword ? 2 : 1,
                    ),
                  ),
                ),
              if (onRefresh != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: TVColors.textSecondary,
                  onPressed: onRefresh,
                  tooltip: 'Yenile',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
              if (onCopy != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  color: TVColors.textSecondary,
                  onPressed: onCopy,
                  tooltip: 'Kopyala',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectPanel() {
    return Container(
      decoration: BoxDecoration(
        color: TVColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TVColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TVColors.border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TVColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.link,
                    color: TVColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Bilgisayara Bağlan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TVColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bağlanmak istediğiniz bilgisayarın ID\'sini girin:',
                    style: TextStyle(
                      fontSize: 13,
                      color: TVColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Partner ID input
                  const Text(
                    'Partner ID',
                    style: TextStyle(
                      fontSize: 12,
                      color: TVColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _partnerIdController,
                    focusNode: _partnerIdFocusNode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ID girin',
                      hintStyle: TextStyle(
                        color: TVColors.textSecondary.withOpacity(0.5),
                        fontWeight: FontWeight.normal,
                      ),
                      filled: true,
                      fillColor: TVColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: TVColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: TVColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: TVColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _connect(),
                  ),
                  const SizedBox(height: 24),
                  // Connect button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TVColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Bağlan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Additional options
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _connect(isFileTransfer: true),
                          icon: const Icon(Icons.folder, size: 18),
                          label: const Text('Dosya Transferi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TVColors.textPrimary,
                            side: const BorderSide(color: TVColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Recent connections placeholder
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TVColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: TVColors.textSecondary.withOpacity(0.5),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Son bağlantılar burada görünecek',
                          style: TextStyle(
                            fontSize: 13,
                            color: TVColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Obx(() {
      final isConnecting = stateGlobal.svcStatus.value == SvcStatus.connecting;
      final isReady = stateGlobal.svcStatus.value == SvcStatus.ready;
      
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isReady 
              ? TVColors.success.withOpacity(0.1)
              : isConnecting 
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isReady 
                    ? TVColors.success
                    : isConnecting 
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isReady 
                  ? 'Bağlantıya hazır'
                  : isConnecting 
                      ? 'Sunucuya bağlanıyor...'
                      : 'Bağlantı yok',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isReady 
                    ? TVColors.success
                    : isConnecting 
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: TVColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            'PixPos Remote v1.0.0',
            style: TextStyle(
              fontSize: 11,
              color: TVColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            'Sunucu: 54.198.58.229',
            style: TextStyle(
              fontSize: 11,
              color: TVColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _connect({bool isFileTransfer = false}) {
    final id = _partnerIdController.text.trim();
    if (id.isEmpty) {
      showToast('Lütfen bir ID girin');
      return;
    }
    connect(context, id, isFileTransfer: isFileTransfer);
  }

  Widget _buildBlock({required Widget child}) {
    return buildRemoteBlock(
        block: _block, mask: true, use: canBeBlocked, child: child);
  }


  @override
  void initState() {
    super.initState();
    _updateTimer = periodic_immediate(const Duration(seconds: 1), () async {
      await gFFI.serverModel.fetchID();
      final error = await bind.mainGetError();
      if (systemError != error) {
        systemError = error;
        setState(() {});
      }
      final v = await mainGetBoolOption(kOptionStopService);
      if (v != svcStopped.value) {
        svcStopped.value = v;
        setState(() {});
      }
      if (watchIsCanScreenRecording) {
        if (bind.mainIsCanScreenRecording(prompt: false)) {
          watchIsCanScreenRecording = false;
          setState(() {});
        }
      }
      if (watchIsProcessTrust) {
        if (bind.mainIsProcessTrusted(prompt: false)) {
          watchIsProcessTrust = false;
          setState(() {});
        }
      }
      if (watchIsInputMonitoring) {
        if (bind.mainIsCanInputMonitoring(prompt: false)) {
          watchIsInputMonitoring = false;
          setState(() {});
        }
      }
      if (watchIsCanRecordAudio) {
        if (isMacOS) {
          Future.microtask(() async {
            if ((await osxCanRecordAudio() ==
                PermissionAuthorizeType.authorized)) {
              watchIsCanRecordAudio = false;
              setState(() {});
            }
          });
        } else {
          watchIsCanRecordAudio = false;
          setState(() {});
        }
      }
    });
    Get.put<RxBool>(svcStopped, tag: 'stop-service');
    rustDeskWinManager.registerActiveWindowListener(() async {
      onActiveWindowChanged();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lastRemoteId = await bind.mainGetLastRemoteId();
      if (lastRemoteId.isNotEmpty) {
        _partnerIdController.text = lastRemoteId;
      }
    });
  }

  void onActiveWindowChanged() {
    if (!isWindows) return;
    if (rustDeskWinManager.getActiveWindows().isEmpty) {
      windowManager.blur();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (isMacOS) {
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) setState(() {});
        });
      }
    }
  }
}

// Helper functions that were in the original file
Widget loadLogo() {
  return Image.asset(
    'assets/logo.png',
    height: 50,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(Icons.desktop_windows, size: 50);
    },
  );
}

Widget loadPowered(BuildContext context) {
  final text = translate('powered_by_me');
  if (text.isEmpty) return const SizedBox();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
    ),
  );
}

Widget buildPresetPasswordWarning() {
  return const SizedBox();
}
