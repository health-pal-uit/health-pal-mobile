import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

typedef OnStreamCallback = void Function(MediaStream stream);
typedef OnPeerDisconnected = void Function();

class WebRTCSignaling {
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  io.Socket? _socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  String? _consultationId;
  String? _userId;
  String? _role;
  String? _targetPeerId; // ID của người đang gọi cùng

  OnStreamCallback? onLocalStream;
  OnStreamCallback? onRemoteStream;
  OnPeerDisconnected? onPeerDisconnected;

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

    _socket = io.io(
      '$serverUrl/video-calls',
      io.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        'Authorization': 'Bearer $token',
      }).build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Signaling Connected');
      _socket!.emit('join-video-call', {
        'consultationId': consultationId,
        'userId': userId,
        'role': role,
      });
    });

    _socket!.on('peer-joined', (data) {
      if (data['userId'] != _userId) {
        debugPrint('Peer joined: ${data['peerId']}');
        _targetPeerId = data['peerId'];
        if (_role == 'expert') {
          _createOffer();
        }
      }
    });

    _socket!.on('webrtc-offer', (data) async {
      _targetPeerId = data['fromPeerId'];
      await _handleReceiveOffer(data['offer']);
    });

    _socket!.on('webrtc-answer', (data) async {
      await _handleReceiveAnswer(data['answer']);
    });

    _socket!.on('ice-candidate', (data) async {
      await _handleReceiveIceCandidate(data['candidate']);
    });

    _socket!.on('call-ended', (_) {
      endCall();
    });
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localRenderer,
    RTCVideoRenderer remoteRenderer,
  ) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      localRenderer.srcObject = _localStream;
      onLocalStream?.call(_localStream!);

      _peerConnection = await createPeerConnection(_iceServers);

      // Add local tracks to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // listen Track from remote peer
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          remoteRenderer.srcObject = event.streams[0];
          onRemoteStream?.call(event.streams[0]);
        }
      };

      // send ICE Candidate to peer
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (_targetPeerId != null) {
          _socket!.emit('ice-candidate', {
            'consultationId': _consultationId,
            'targetPeerId': _targetPeerId,
            'candidate': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          });
        }
      };
    } catch (e) {
      debugPrint("Lỗi khi mở Media: $e");
    }
  }

  Future<void> _createOffer() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socket!.emit('webrtc-offer', {
      'consultationId': _consultationId,
      'targetPeerId': _targetPeerId,
      'offer': {'type': offer.type, 'sdp': offer.sdp},
    });
  }

  Future<void> _handleReceiveOffer(Map<String, dynamic> offerMap) async {
    RTCSessionDescription offer = RTCSessionDescription(
      offerMap['sdp'],
      offerMap['type'],
    );
    await _peerConnection!.setRemoteDescription(offer);

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socket!.emit('webrtc-answer', {
      'consultationId': _consultationId,
      'targetPeerId': _targetPeerId,
      'answer': {'type': answer.type, 'sdp': answer.sdp},
    });
  }

  Future<void> _handleReceiveAnswer(Map<String, dynamic> answerMap) async {
    RTCSessionDescription answer = RTCSessionDescription(
      answerMap['sdp'],
      answerMap['type'],
    );
    await _peerConnection!.setRemoteDescription(answer);
  }

  Future<void> _handleReceiveIceCandidate(
    Map<String, dynamic> candidateMap,
  ) async {
    RTCIceCandidate candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  void toggleMic(bool isMuted) {
    if (_localStream != null) {
      _localStream!.getAudioTracks()[0].enabled = !isMuted;
    }
  }

  void toggleCamera(bool isCameraOn) {
    if (_localStream != null) {
      _localStream!.getVideoTracks()[0].enabled = isCameraOn;
    }
  }

  void endCall() {
    _socket?.emit('end-video-call', {
      'callId': 'TODO_PASS_CALL_ID_HERE',
      'consultationId': _consultationId,
    });

    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    _socket?.disconnect();
    onPeerDisconnected?.call();
  }
}
