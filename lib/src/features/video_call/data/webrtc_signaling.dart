import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class WebRTCSignaling {
  io.Socket? _socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  String? _consultationId;
  String? _userId;
  String? _role;
  String? _targetPeerId;
  String? _callId;

  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onRemoteStream;
  Function()? onPeerDisconnected;
  RTCDataChannel? _dataChannel;
  Function(bool isCameraOn)? onRemoteCameraToggled;

  bool _isDisposed = false;

  void connectSignaling({
    required String serverUrl,
    required String token,
    required String consultationId,
    required String userId,
    required String role,
  }) {
    _consultationId = consultationId;
    _userId = userId;
    _role = role;

    String safeUrl = serverUrl;
    if (safeUrl.endsWith('/')) {
      safeUrl = safeUrl.substring(0, safeUrl.length - 1);
    }
    _socket = io.io(
      '$safeUrl/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('🟢 [SOCKET] Đã kết nối tới Server thành công!');
      _socket!.emit('join-video-call', {'consultationId': _consultationId});
    });

    _socket!.on('error', (data) {
      debugPrint('🔴 [BACKEND BÁO LỖI]: ${data['message']}');
    });

    _socket!.on('call-room-joined', (data) {
      debugPrint('🟢 [SOCKET] Đã join Call Room. Call ID: ${data['callId']}');
      _callId = data['callId'];
    });

    _socket!.on('peer-joined', (data) {
      debugPrint('🟢 [SOCKET] PEER-JOINED: $data');
      if (data['peerId'] != _userId) {
        _targetPeerId = data['peerId'];
        if (_role == 'expert') {
          debugPrint('🟢 [WEBRTC] Tôi là Expert, tiến hành tạo Offer...');
          _createOffer();
        }
      }
    });

    _socket!.on('webrtc-offer', (data) async {
      debugPrint('🟢 [SOCKET] Nhận được Offer!');
      if (data['from'] != null) _targetPeerId = data['from'];
      await _handleReceiveOffer(data['offer']);
    });

    _socket!.on('webrtc-answer', (data) async {
      debugPrint('🟢 [SOCKET] Nhận được Answer!');
      await _handleReceiveAnswer(data['answer']);
    });

    _socket!.on('ice-candidate', (data) async {
      debugPrint('🟢 [SOCKET] Nhận được ICE Candidate');
      await _handleReceiveIceCandidate(data['candidate']);
    });

    _socket!.on('call-ended', (data) {
      debugPrint('🟢 [SOCKET] Cuộc gọi đã bị kết thúc bởi đối tác');
      endCall();
    });

    _socket!.onConnectError(
      (err) => debugPrint('🔴 [SOCKET] LỖI KẾT NỐI: $err'),
    );
    _socket!.onError((err) => debugPrint('🔴 [SOCKET] LỖI CHUNG: $err'));
    _socket!.onDisconnect((_) => debugPrint('🔴 [SOCKET] ĐÃ NGẮT KẾT NỐI'));
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    final mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localVideo.srcObject = _localStream;
    onLocalStream?.call(_localStream!);

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection?.onDataChannel = (RTCDataChannel channel) {
      _dataChannel = channel;
      _dataChannel?.onMessage = (RTCDataChannelMessage message) {
        if (message.text == 'camera_off') {
          onRemoteCameraToggled?.call(false);
        } else if (message.text == 'camera_on') {
          onRemoteCameraToggled?.call(true);
        }
      };
    };

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      if (_targetPeerId != null && _callId != null) {
        _socket!.emit('ice-candidate', {
          'to': _targetPeerId,
          'callId': _callId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteVideo.srcObject = _remoteStream;
        onRemoteStream?.call(_remoteStream!);
      }
    };
  }

  Future<void> _createOffer() async {
    _dataChannel = await _peerConnection!.createDataChannel(
      'cam-signal',
      RTCDataChannelInit(),
    );
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      if (message.text == 'camera_off') onRemoteCameraToggled?.call(false);
      if (message.text == 'camera_on') onRemoteCameraToggled?.call(true);
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socket!.emit('webrtc-offer', {
      'to': _targetPeerId,
      'callId': _callId,
      'offer': {'type': offer.type, 'sdp': offer.sdp},
    });
  }

  Future<void> _handleReceiveOffer(Map<String, dynamic> offerData) async {
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(offerData['sdp'], offerData['type']),
    );
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socket!.emit('webrtc-answer', {
      'to': _targetPeerId,
      'callId': _callId,
      'answer': {'type': answer.type, 'sdp': answer.sdp},
    });
  }

  Future<void> _handleReceiveAnswer(Map<String, dynamic> answerData) async {
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(answerData['sdp'], answerData['type']),
    );
  }

  Future<void> _handleReceiveIceCandidate(
    Map<String, dynamic> candidateData,
  ) async {
    await _peerConnection?.addCandidate(
      RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      ),
    );
  }

  void toggleMic(bool isMuted) {
    if (_localStream != null) {
      _localStream!.getAudioTracks()[0].enabled = !isMuted;
    }
  }

  void toggleCamera(bool isCameraOn) {
    if (_localStream != null) {
      _localStream!.getVideoTracks()[0].enabled = isCameraOn;

      if (_dataChannel != null) {
        _dataChannel!.send(
          RTCDataChannelMessage(isCameraOn ? 'camera_on' : 'camera_off'),
        );
      }
    }
  }

  void endCall() {
    if (_isDisposed) return;
    _isDisposed = true;

    if (_callId != null) {
      _socket?.emit('end-video-call', {'callId': _callId});
    }

    onPeerDisconnected?.call();

    Future.delayed(const Duration(milliseconds: 500), () {
      _localStream?.dispose();
      _remoteStream?.dispose();
      _peerConnection?.close();
      _socket?.disconnect();
    });
  }
}
