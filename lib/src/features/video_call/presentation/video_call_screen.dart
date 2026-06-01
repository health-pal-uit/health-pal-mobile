import 'package:da1/src/features/video_call/data/webrtc_signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String consultationId;
  final String userId;
  final String role;
  final String token;

  const VideoCallScreen({
    super.key,
    required this.consultationId,
    required this.userId,
    required this.role,
    required this.token,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _signaling = WebRTCSignaling();

  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    // 1. Xin quyền Camera và Mic trước khi làm bất cứ việc gì
    await [Permission.camera, Permission.microphone].request();

    // 2. Khởi tạo UI khung hình
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // 3. Setup các hàm callback từ WebRTCSignaling
    _signaling.onLocalStream = (stream) {
      if (mounted) setState(() => _isConnecting = false);
    };

    _signaling.onRemoteStream = (stream) {
      if (mounted) setState(() {});
    };

    _signaling.onPeerDisconnected = () {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cuộc gọi đã kết thúc')));
        context.pop(); // Thoát màn hình
      }
    };

    // 4. Kết nối tới Socket.IO (Thay IP Backend của bạn vào đây)
    _signaling.connectSignaling(
      serverUrl: 'http://192.168.1.15:3001', // Đổi thành BaseURL thực tế
      token: widget.token,
      consultationId: widget.consultationId,
      userId: widget.userId,
      role: widget.role,
    );

    // 5. Bật Camera/Mic
    await _signaling.openUserMedia(_localRenderer, _remoteRenderer);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.endCall(); // Dọn dẹp kết nối khi thoát
    super.dispose();
  }

  void _toggleMic() {
    setState(() => _isMicMuted = !_isMicMuted);
    _signaling.toggleMic(_isMicMuted);
  }

  void _toggleCamera() {
    setState(() => _isCameraOff = !_isCameraOff);
    _signaling.toggleCamera(!_isCameraOff);
  }

  void _endCall() {
    _signaling.endCall();
    context.pop(); // Trở về màn hình trước
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // KHUNG HÌNH LỚN: REMOTE VIDEO (Người đối diện)
            Positioned.fill(
              child:
                  _remoteRenderer.renderVideo
                      ? RTCVideoView(
                        _remoteRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                      : const Center(
                        child: Text(
                          'Đang đợi đối tác kết nối...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
            ),

            // KHUNG HÌNH NHỎ: LOCAL VIDEO (Camera của mình)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      _isCameraOff
                          ? const Center(
                            child: Icon(
                              Icons.videocam_off,
                              color: Colors.white,
                            ),
                          )
                          : RTCVideoView(
                            _localRenderer,
                            mirror: true, // Lật gương camera trước
                            objectFit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          ),
                ),
              ),
            ),

            // LOADING OVERLAY
            if (_isConnecting)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // THANH CÔNG CỤ (BOTTOM CONTROLS)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Nút Tắt/Mở Mic
                  _buildControlButton(
                    icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                    color: _isMicMuted ? Colors.white : Colors.white24,
                    iconColor: _isMicMuted ? Colors.black : Colors.white,
                    onTap: _toggleMic,
                  ),

                  // Nút Cúp máy
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconColor: Colors.white,
                    size: 64,
                    onTap: _endCall,
                  ),

                  // Nút Tắt/Mở Camera
                  _buildControlButton(
                    icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    color: _isCameraOff ? Colors.white : Colors.white24,
                    iconColor: _isCameraOff ? Colors.black : Colors.white,
                    onTap: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}
