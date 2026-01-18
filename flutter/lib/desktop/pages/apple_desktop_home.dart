import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/desktop/pages/desktop_setting_page.dart';
import 'package:flutter_hbb/desktop/pages/desktop_tab_page.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:flutter_hbb/utils/multi_window_manager.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

/// Elite, Zarif PixPos Remote Desktop Home
class AppleDesktopHome extends StatefulWidget {
  const AppleDesktopHome({Key? key}) : super(key: key);

  @override
  State<AppleDesktopHome> createState() => _AppleDesktopHomeState();
}

class _AppleDesktopHomeState extends State<AppleDesktopHome>
    with TickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();
  
  final RxBool _idCopied = false.obs;
  final RxBool _passwordCopied = false.obs;
  final RxBool _isConnecting = false.obs;
  
  Timer? _updateTimer;
  String systemError = '';
  var svcStopped = false.obs;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startUpdateTimer();
  }

  void _startUpdateTimer() {
    _updateTimer = periodic_immediate(const Duration(seconds: 1), () async {
      await gFFI.serverModel.fetchID();
      final error = await bind.mainGetError();
      if (systemError != error) {
        systemError = error;
        if (mounted) setState(() {});
      }
      final v = await mainGetBoolOption(kOptionStopService);
      if (v != svcStopped.value) {
        svcStopped.value = v;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    _idController.dispose();
    _idFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image with blur
        Positioned.fill(
          child: Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        
        // Dark overlay for readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        
        // Main Content
        Positioned.fill(
          child: Row(
            children: [
              // Left Panel - Your Device Info
              _buildLeftPanel(context),
              
              // Right Panel - Connect to Remote
              Expanded(child: _buildRightPanel(context)),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildLeftPanel(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            border: Border(
              right: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Device Info
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildDeviceCard(),
                      const SizedBox(height: 16),
                      _buildPasswordCard(),
                      const SizedBox(height: 16),
                      _buildStatusIndicator(),
                    ],
                  ),
                ),
              ),
              
              // Bottom Actions
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Animated Logo
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(_glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.desktop_mac_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PixPos Remote',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  translate('Your Desktop'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Settings
          _buildGlassIconButton(
            Icons.settings_outlined,
            onTap: () => DesktopTabPage.onAddSetting(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard() {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Consumer<ServerModel>(
        builder: (context, model, child) {
          final id = model.serverId.text;
          final isReady = id.isNotEmpty;
          
          return _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      translate('ID'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Status indicator
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isReady
                                  ? [const Color(0xFF10B981), const Color(0xFF10B981).withOpacity(0.4)]
                                  : [const Color(0xFFF59E0B), const Color(0xFFF59E0B).withOpacity(0.4)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: (isReady ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                                    .withOpacity(0.5 * _pulseAnimation.value),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _copyId(id),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isReady ? _formatId(id) : translate('Generating...'),
                                style: TextStyle(
                                  fontFamily: 'SF Mono',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                  color: isReady ? Colors.white : Colors.white.withOpacity(0.4),
                                ),
                              ),
                              if (isReady)
                                Text(
                                  translate('Tap to copy'),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _idCopied.value
                          ? Container(
                              key: const ValueKey('check'),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF10B981),
                                size: 18,
                              ),
                            )
                          : _buildGlassIconButton(
                              Icons.copy_rounded,
                              key: const ValueKey('copy'),
                              onTap: () => _copyId(id),
                              size: 36,
                            ),
                    )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordCard() {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Consumer<ServerModel>(
        builder: (context, model, child) {
          final password = model.serverPasswd.text;
          final showPassword = model.approveMode != 'click' &&
              model.verificationMethod != kUsePermanentPassword;
          
          return _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.key_rounded,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      translate('One-time Password'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          showPassword 
                              ? (password.isEmpty ? '------' : password)
                              : '••••••',
                          style: const TextStyle(
                            fontFamily: 'SF Mono',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (showPassword) ...[
                      Obx(() => _passwordCopied.value
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF10B981),
                                size: 16,
                              ),
                            )
                          : _buildGlassIconButton(
                              Icons.copy_rounded,
                              onTap: () => _copyPassword(password),
                              size: 32,
                            )),
                      const SizedBox(width: 4),
                      _buildGlassIconButton(
                        Icons.refresh_rounded,
                        onTap: () => bind.mainUpdateTemporaryPassword(),
                        size: 32,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Obx(() {
      final isRunning = !svcStopped.value;
      
      return _buildGlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRunning ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    boxShadow: [
                      BoxShadow(
                        color: (isRunning ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                            .withOpacity(0.6 * _pulseAnimation.value),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRunning ? translate('Ready') : translate('Service Stopped'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isRunning
                        ? translate('Waiting for connection')
                        : translate('Start service to connect'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGlassButton(
              icon: Icons.settings_outlined,
              label: translate('Settings'),
              onTap: () => DesktopTabPage.onAddSetting(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildGlassButton(
              icon: Icons.help_outline_rounded,
              label: translate('Help'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRightPanel(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              translate('Connect to Remote'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translate('Enter the remote device ID to connect'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 48),
            
            // ID Input Card
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // ID Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _idController,
                          focusNode: _idFocusNode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '000 000 000',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Icon(
                                Icons.desktop_windows_rounded,
                                color: Colors.white.withOpacity(0.3),
                                size: 24,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _IdInputFormatter(),
                          ],
                          onSubmitted: (_) => _connect(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Connect Button
                      Obx(() => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isConnecting.value ? null : _connect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isConnecting.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.link_rounded, size: 22),
                                    const SizedBox(width: 10),
                                    Text(
                                      translate('Connect'),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )),
                      
                      const SizedBox(height: 20),
                      
                      // Quick Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickAction(
                            Icons.folder_outlined,
                            translate('File Transfer'),
                            onTap: () => _connectFileTransfer(),
                          ),
                          const SizedBox(width: 32),
                          _buildQuickAction(
                            Icons.videocam_outlined,
                            translate('View Camera'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Recent connections hint
            Text(
              translate('Recent connections will appear here'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.6),
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, {VoidCallback? onTap, double size = 40, Key? key}) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.6),
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Actions
  String _formatId(String id) {
    if (id.length <= 3) return id;
    final buffer = StringBuffer();
    for (int i = 0; i < id.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(id[i]);
    }
    return buffer.toString();
  }

  void _copyId(String id) {
    if (id.isEmpty) return;
    Clipboard.setData(ClipboardData(text: id));
    showToast(translate('Copied'));
    _idCopied.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      _idCopied.value = false;
    });
  }

  void _copyPassword(String password) {
    if (password.isEmpty) return;
    Clipboard.setData(ClipboardData(text: password));
    showToast(translate('Copied'));
    _passwordCopied.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      _passwordCopied.value = false;
    });
  }

  void _connect() {
    final id = _idController.text.replaceAll(' ', '');
    if (id.isEmpty) {
      showToast(translate('Please enter remote ID'));
      return;
    }
    
    _isConnecting.value = true;
    
    // Connect to remote desktop
    Future.delayed(const Duration(milliseconds: 500), () {
      _isConnecting.value = false;
      rustDeskWinManager.newRemoteDesktop(id);
    });
  }

  void _connectFileTransfer() {
    final id = _idController.text.replaceAll(' ', '');
    if (id.isEmpty) {
      showToast(translate('Please enter remote ID'));
      return;
    }
    rustDeskWinManager.newFileTransfer(id);
  }
}

// ID Input Formatter - adds spaces for readability
class _IdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 9) {
      return oldValue;
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
