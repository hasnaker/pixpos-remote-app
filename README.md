# PixPos Remote App

Professional Remote Desktop Solution - Based on RustDesk

## Features

- 🖥️ Cross-platform support (Windows, macOS, Linux, Android, iOS)
- 🔒 End-to-end encryption
- 🌐 NAT traversal & P2P connection
- 📁 File transfer
- 💬 Text chat
- 🎤 Audio support
- 🖱️ Remote control with low latency
- 🏠 Self-hosted relay server option

## Tech Stack

- **Core:** Rust
- **UI:** Flutter
- **Network:** QUIC, WebRTC
- **Video Codec:** H.264/H.265, VP8/VP9

## Build Instructions

### Prerequisites

- Rust 1.75+
- Flutter 3.1+
- Platform-specific dependencies (see original RustDesk docs)

### Build

```bash
# Desktop (macOS/Linux/Windows)
cd flutter
flutter build macos  # or linux, windows

# Mobile
flutter build apk    # Android
flutter build ios    # iOS
```

## Configuration

Configure your relay server in the app settings or use the default PixPos servers.

## License

AGPL-3.0 (inherited from RustDesk)

## Credits

Based on [RustDesk](https://github.com/rustdesk/rustdesk) - An open-source remote desktop application.
