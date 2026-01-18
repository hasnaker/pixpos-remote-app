import 'package:flutter/material.dart';
import 'package:flutter_hbb/models/peer_model.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/formatter/id_formatter.dart';
import '../apple_theme.dart';
import 'apple_peer_card.dart';
import 'apple_peers_view.dart';

/// Wrapper to convert existing Peer model to Apple-styled peer card
/// 
/// This bridges the existing peer system with the new Apple design components.
class ApplePeerCardWrapper extends StatelessWidget {
  final Peer peer;
  final bool isSelected;
  final bool showCheckbox;
  final ApplePeerViewType viewType;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMorePressed;
  final bool showSeparator;

  const ApplePeerCardWrapper({
    Key? key,
    required this.peer,
    this.isSelected = false,
    this.showCheckbox = false,
    this.viewType = ApplePeerViewType.grid,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMorePressed,
    this.showSeparator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (viewType) {
      case ApplePeerViewType.grid:
        return ApplePeerCard(
          id: peer.id,
          alias: peer.alias,
          hostname: peer.hostname,
          username: peer.username,
          platform: peer.platform,
          isOnline: peer.online,
          tags: peer.tags.cast<String>(),
          note: peer.note,
          isSelected: isSelected,
          showCheckbox: showCheckbox,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onMorePressed: onMorePressed,
          platformIcon: _buildPlatformIcon(peer.platform),
        );
      case ApplePeerViewType.list:
        return ApplePeerListItem(
          id: peer.id,
          alias: peer.alias,
          hostname: peer.hostname,
          username: peer.username,
          platform: peer.platform,
          isOnline: peer.online,
          tags: peer.tags.cast<String>(),
          note: peer.note,
          isSelected: isSelected,
          showCheckbox: showCheckbox,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onMorePressed: onMorePressed,
          platformIcon: _buildPlatformIcon(peer.platform),
          showSeparator: showSeparator,
        );
      case ApplePeerViewType.tile:
        return ApplePeerTile(
          id: peer.id,
          alias: peer.alias,
          hostname: peer.hostname,
          username: peer.username,
          platform: peer.platform,
          isOnline: peer.online,
          tags: peer.tags.cast<String>(),
          isSelected: isSelected,
          showCheckbox: showCheckbox,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onMorePressed: onMorePressed,
          platformIcon: _buildPlatformIcon(peer.platform),
        );
    }
  }

  Widget? _buildPlatformIcon(String platform) {
    // Use the existing getPlatformImage function if available
    try {
      return getPlatformImage(platform, size: viewType == ApplePeerViewType.grid ? 48 : 24);
    } catch (e) {
      return null;
    }
  }
}

/// Helper extension to convert PeerUiType to ApplePeerViewType
extension PeerUiTypeExtension on int {
  ApplePeerViewType toApplePeerViewType() {
    switch (this) {
      case 0:
        return ApplePeerViewType.grid;
      case 1:
        return ApplePeerViewType.tile;
      case 2:
        return ApplePeerViewType.list;
      default:
        return ApplePeerViewType.grid;
    }
  }
}

/// Helper to convert ApplePeerViewType to int for storage
extension ApplePeerViewTypeExtension on ApplePeerViewType {
  int toInt() {
    switch (this) {
      case ApplePeerViewType.grid:
        return 0;
      case ApplePeerViewType.tile:
        return 1;
      case ApplePeerViewType.list:
        return 2;
    }
  }
}

/// Apple-styled connection list with responsive grid
/// 
/// A complete connection list component that uses the Apple design system.
class AppleConnectionList extends StatefulWidget {
  final List<Peer> peers;
  final ApplePeerViewType initialViewType;
  final bool showViewSelector;
  final Function(Peer peer)? onPeerTap;
  final Function(Peer peer)? onPeerDoubleTap;
  final Function(Peer peer)? onPeerLongPress;
  final Function(Peer peer)? onPeerMorePressed;
  final Set<String>? selectedPeerIds;
  final bool multiSelectMode;
  final String emptyMessage;
  final ScrollController? scrollController;

  const AppleConnectionList({
    Key? key,
    required this.peers,
    this.initialViewType = ApplePeerViewType.grid,
    this.showViewSelector = true,
    this.onPeerTap,
    this.onPeerDoubleTap,
    this.onPeerLongPress,
    this.onPeerMorePressed,
    this.selectedPeerIds,
    this.multiSelectMode = false,
    this.emptyMessage = 'No connections found',
    this.scrollController,
  }) : super(key: key);

  @override
  State<AppleConnectionList> createState() => _AppleConnectionListState();
}

class _AppleConnectionListState extends State<AppleConnectionList> {
  late ApplePeerViewType _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = widget.initialViewType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showViewSelector && widget.peers.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppleTheme.spacing16,
              vertical: AppleTheme.spacing8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ApplePeerViewSelector(
                  selectedType: _viewType,
                  onChanged: (type) => setState(() => _viewType = type),
                ),
              ],
            ),
          ),
        Expanded(
          child: _buildPeersList(),
        ),
      ],
    );
  }

  Widget _buildPeersList() {
    if (widget.peers.isEmpty) {
      return _buildEmptyState();
    }

    final children = widget.peers.asMap().entries.map((entry) {
      final index = entry.key;
      final peer = entry.value;
      final isSelected = widget.selectedPeerIds?.contains(peer.id) ?? false;
      
      return ApplePeerCardWrapper(
        peer: peer,
        viewType: _viewType,
        isSelected: isSelected,
        showCheckbox: widget.multiSelectMode,
        showSeparator: _viewType == ApplePeerViewType.list && 
                       index < widget.peers.length - 1,
        onTap: widget.onPeerTap != null ? () => widget.onPeerTap!(peer) : null,
        onDoubleTap: widget.onPeerDoubleTap != null 
            ? () => widget.onPeerDoubleTap!(peer) 
            : null,
        onLongPress: widget.onPeerLongPress != null 
            ? () => widget.onPeerLongPress!(peer) 
            : null,
        onMorePressed: widget.onPeerMorePressed != null 
            ? () => widget.onPeerMorePressed!(peer) 
            : null,
      );
    }).toList();

    return ApplePeersView(
      viewType: _viewType,
      children: children,
      scrollController: widget.scrollController,
      gridColumns: _getGridColumns(),
      showEmptyState: false,
    );
  }

  int _getGridColumns() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: AppleTheme.secondaryTextColor(context).withOpacity(0.5),
          ),
          SizedBox(height: AppleTheme.spacing16),
          Text(
            widget.emptyMessage,
            style: TextStyle(
              fontSize: 16,
              color: AppleTheme.secondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
