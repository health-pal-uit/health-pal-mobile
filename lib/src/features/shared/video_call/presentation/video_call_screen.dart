import 'package:da1/src/config/env.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/features/shared/video_call/data/consultation_repository.dart';
import 'package:da1/src/features/shared/video_call/data/webrtc_signaling.dart';
import 'package:da1/src/features/shared/video_call/presentation/widget/expert_end_call_dialog.dart';
import 'package:da1/src/features/shared/video_call/presentation/widget/user_post_call_dialog.dart';
import 'package:da1/src/features/user/advisor/data/rating_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  bool _isRemoteCameraOn = true;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    await [Permission.camera, Permission.microphone].request();
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

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
        ).showSnackBar(const SnackBar(content: Text('The call has ended')));
        context.pop();
      }
    };

    _signaling.connectSignaling(
      serverUrl: Env.backendApiUrl,
      token: widget.token,
      consultationId: widget.consultationId,
      userId: widget.userId,
      role: widget.role,
    );

    _signaling.onRemoteCameraToggled = (isCameraOn) {
      if (mounted) {
        setState(() {
          _isRemoteCameraOn = isCameraOn;
        });
      }
    };

    await _signaling.openUserMedia(_localRenderer, _remoteRenderer);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.endCall();
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

  void _endCall() async {
    _signaling.endCall();
    final int durationMinutes = 45;
    final int tokenPerMin = 6;
    final int totalTokens = durationMinutes * tokenPerMin;

    if (widget.role == 'expert') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => ExpertEndCallDialog(
              durationMinutes: durationMinutes,
              estimatedTokens: totalTokens,
              onSubmit: (resultText) async {
                try {
                  final localDataSource = AuthLocalDataSourceImpl(
                    storage: const FlutterSecureStorage(),
                  );
                  final repo = ConsultationRepository(
                    localDataSource: localDataSource,
                  );

                  await repo.endConsultation(
                    consultationId: widget.consultationId,
                    durationMinutes: durationMinutes,
                    tokensCharged: totalTokens,
                    resultText: resultText,
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);

                  if (!mounted) return;
                  context.pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Consultation completed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => UserPostCallDialog(
              durationMinutes: durationMinutes,
              tokensCharged: totalTokens,
              onSubmit: (rating, review) async {
                try {
                  final ratingRepo = RatingRepository();
                  await ratingRepo.submitReview(
                    consultationId: widget.consultationId,
                    score: rating,
                    comment: review,
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  context.pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to submit review. Please try again.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  _remoteRenderer.renderVideo
                      ? Stack(
                        fit: StackFit.expand,
                        children: [
                          RTCVideoView(
                            _remoteRenderer,
                            objectFit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          ),

                          if (!_isRemoteCameraOn)
                            Container(
                              color: const Color(0xFF1E1E1E),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[800],
                                    child: const Icon(
                                      Icons.videocam_off,
                                      size: 50,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'The other party has turned off their camera',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                      : const Center(
                        child: Text(
                          'Waiting for the other party to join...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
            ),

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
                            mirror: true,
                            objectFit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          ),
                ),
              ),
            ),

            if (_isConnecting)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                    color: _isMicMuted ? Colors.white : Colors.white24,
                    iconColor: _isMicMuted ? Colors.black : Colors.white,
                    onTap: _toggleMic,
                  ),

                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconColor: Colors.white,
                    size: 64,
                    onTap: _endCall,
                  ),

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
