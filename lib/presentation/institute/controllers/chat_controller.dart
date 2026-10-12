import 'dart:async';
import 'package:tuoora/core/constants/app_strings.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/chat_socket_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/data/models/chat_model.dart';
import 'package:tuoora/data/repositories_impl/chat_repository_impl.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository;

  ChatController(this._chatRepository);

  final isLoading = false.obs;
  final isSending = false.obs;
  final chatsList = <Chat>[].obs;
  final filteredChats = <Chat>[].obs;
  final searchQuery = ''.obs;

  final messages = <Message>[].obs;
  final selectedChat = Rxn<Chat>();
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  static const int _messagesPerPage = 20;
  int _messagesPage = 1;

  /// True while an older page is being fetched (drives the top spinner).
  final isLoadingMore = false.obs;

  /// False once the server returns a short page — no more history to load.
  final hasMoreMessages = true.obs;

  /// True when the user has scrolled up far enough that the latest message
  /// is off-screen — drives the floating "scroll to bottom" button.
  final showScrollToBottom = false.obs;

  // ----------------------------------------------------- voice recording
  final AudioRecorder _recorder = AudioRecorder();
  final isRecording = false.obs;
  final recordSeconds = 0.obs;
  Timer? _recordTimer;
  String? _recordPath;

  // -------------------------------------------------- upload progress
  /// Local file path of the attachment currently being uploaded. The
  /// optimistic bubble matches its [Message.attachment] against this and
  /// shows the progress ring while non-empty. Reset to '' on done/error.
  final uploadingPath = ''.obs;

  /// 0..100 — bytes uploaded as reported by GetConnect's `uploadProgress`.
  final uploadProgress = 0.0.obs;

  final availableParticipants = <ChatParticipant>[].obs;
  final filteredParticipants = <ChatParticipant>[].obs;
  final participantSearchQuery = ''.obs;

  /// Logged-in user identity in the chat domain. Sourced from the chat list
  /// response (which carries my_id/my_type) and falls back to AuthService
  /// for first-time users with no existing chats.
  String? _myUserId;
  String? _myUserType;

  StreamSubscription<Message>? _onMessageSentSub;
  StreamSubscription<MessageAck>? _onMessageReceivedSub;
  StreamSubscription<MessageAck>? _onMessageReadSub;
  StreamSubscription<ChatDeleted>? _onChatDeletedSub;

  final _pendingAcks = <String, _PendingAck>{};

  @override
  void onInit() {
    super.onInit();
    _subscribeToSocketStreams();
    fetchChats();
    scrollController.addListener(_onScroll);

    debounce(
      searchQuery,
      (_) => _filterChats(),
      time: const Duration(milliseconds: 300),
    );
    debounce(
      participantSearchQuery,
      (_) => _filterParticipants(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _onMessageSentSub?.cancel();
    _onMessageReceivedSub?.cancel();
    _onMessageReadSub?.cancel();
    _onChatDeletedSub?.cancel();
    messageController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    super.onClose();
  }

  String get recordTimeLabel {
    final s = recordSeconds.value;
    final m = s ~/ 60;
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    final distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    final shouldShow = distanceFromBottom > 300;
    if (shouldShow != showScrollToBottom.value) {
      showScrollToBottom.value = shouldShow;
    }

    if (pos.pixels <= 200 && !isLoadingMore.value && hasMoreMessages.value) {
      loadOlderMessages();
    }
  }

  void scrollToBottom() => _scrollToExtent(animate: true);

  Future<void> fetchChats() async {
    try {
      isLoading.value = true;
      final chats = await _chatRepository.getChats();
      chatsList.assignAll(chats);
      _filterChats();

      if (chats.isNotEmpty &&
          chats.first.myId != null &&
          chats.first.myRole != null) {
        _myUserId = chats.first.myId;
        _myUserType = chats.first.myRole;
      } else {
        _deriveMyIdentityFromAuth();
      }

      _ensureSocketConnected();
    } catch (e) {
      AppSnackBar.error('Failed to load chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _deriveMyIdentityFromAuth() {
    if (!Get.isRegistered<AuthService>()) return;
    final user = Get.find<AuthService>().currentUser;
    if (user == null) return;
    _myUserId = user.id.toString();
    _myUserType = _mapAuthRoleToChatType(user.role);
  }

  String _mapAuthRoleToChatType(String role) {
    switch (role.toUpperCase()) {
      case 'INSTITUTE':
        return 'Institute';
      // case 'STAFF':
      //   return 'Staff';
      case 'STUDENT':
        return 'Student';
      default:
        return role;
    }
  }

  void _filterChats() {
    if (searchQuery.value.isEmpty) {
      filteredChats.assignAll(chatsList);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredChats.assignAll(
        chatsList.where(
          (chat) =>
              chat.participantName.toLowerCase().contains(query) ||
              chat.lastMessage.toLowerCase().contains(query),
        ),
      );
    }
  }

  Future<void> fetchMessages(String chatId) async {
    try {
      isLoading.value = true;
      _messagesPage = 1;
      isLoadingMore.value = false;
      hasMoreMessages.value = true;
      final chatMessages = await _chatRepository.getChatMessages(
        chatId,
        myUserId: _myUserId ?? '',
        myUserType: _myUserType ?? '',
        page: _messagesPage,
        perPage: _messagesPerPage,
      );
      messages.assignAll(chatMessages);
      hasMoreMessages.value = chatMessages.length >= _messagesPerPage;
      if (kDebugMode) {
        final mine = chatMessages.where((m) => m.isMe).toList();
        final invariantBreaks = mine
            .where((m) => m.readAt != null && m.receivedAt == null)
            .map((m) => m.id)
            .toList();
        debugPrint(
          '[ChatController] /chat/messages — ${chatMessages.length} total, '
          '${mine.length} mine. Mine read-without-received '
          '(impossible state from backend): $invariantBreaks',
        );
      }
      _scrollToBottom(animate: false);
    } catch (e) {
      AppSnackBar.error(
        'Failed to load messages: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOlderMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value) return;
    final chat = selectedChat.value;
    if (chat == null) return;

    isLoadingMore.value = true;
    try {
      final nextPage = _messagesPage + 1;
      final older = await _chatRepository.getChatMessages(
        chat.id,
        myUserId: _myUserId ?? '',
        myUserType: _myUserType ?? '',
        page: nextPage,
        perPage: _messagesPerPage,
      );

      _messagesPage = nextPage;
      hasMoreMessages.value = older.length >= _messagesPerPage;
      if (older.isEmpty) return;

      final existingIds = messages
          .where((m) => m.id.isNotEmpty)
          .map((m) => m.id)
          .toSet();
      final fresh = older
          .where((m) => m.id.isEmpty || !existingIds.contains(m.id))
          .toList();
      if (fresh.isEmpty) return;

      final hasClients = scrollController.hasClients;
      final beforeMax = hasClients
          ? scrollController.position.maxScrollExtent
          : 0.0;
      final beforePixels = hasClients ? scrollController.position.pixels : 0.0;

      messages.assignAll([...fresh, ...messages]);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final afterMax = scrollController.position.maxScrollExtent;
        final delta = afterMax - beforeMax;
        if (delta > 0) {
          scrollController.jumpTo(
            (beforePixels + delta).clamp(0.0, afterMax).toDouble(),
          );
        }
      });
    } catch (e) {
      AppSnackBar.error(
        'Failed to load older messages: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    final chat = selectedChat.value;
    if (content.isEmpty || chat == null || isSending.value) return;

    final receiverId = int.tryParse(chat.participantId);
    if (receiverId == null) {
      AppSnackBar.error(AppStrings.invalidRecipient);
      return;
    }

    final now = DateTime.now();
    final optimistic = Message(
      id: '',
      chatId: chat.id,
      senderId: _myUserId ?? '',
      senderType: _myUserType ?? '',
      receiverId: chat.participantId,
      receiverType: chat.participantRole,
      content: content,
      messageType: 'text',
      createdAt: now,
      isMe: true,
      timestamp: DateFormat('h:mm a').format(now),
    );
    messages.add(optimistic);
    messageController.clear();
    _scrollToBottom();

    try {
      isSending.value = true;
      final sent = await _chatRepository.sendMessage(
        receiverId: receiverId,
        receiverType: chat.participantRole,
        message: content,
        myUserId: _myUserId ?? '',
        myUserType: _myUserType ?? '',
      );
      if (kDebugMode) {
        debugPrint(
          '[ChatController] /chat/send response — id=${sent.id} '
          'readAt=${sent.readAt} receivedAt=${sent.receivedAt} '
          'status=${sent.status}',
        );
      }
      _replaceOptimisticWithCanonical(optimistic, sent);
      // Refresh the chat list so the latest preview + ordering reflects it.
      _bumpChatPreview(sent);
    } catch (e) {
      _markOptimisticFailed(optimistic);
      AppSnackBar.error(
        'Failed to send: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> retrySend(Message failed) async {
    if (!failed.failed) return;
    final chat = selectedChat.value;
    if (chat == null) return;

    final attachmentPath = failed.attachment;
    final hasLocalAttachment =
        attachmentPath != null && !attachmentPath.startsWith('http');

    messages.remove(failed);

    if (hasLocalAttachment) {
      final file = File(attachmentPath);
      if (!await file.exists()) {
        AppSnackBar.error(
          'Cannot retry — the original file is no longer on this device. '
          'Pick it again from the attachment menu.',
        );
        // Keep the failed bubble visible so user knows it didn't go.
        messages.add(failed);
        return;
      }
      await sendAttachment(
        file: file,
        type: failed.messageType,
        caption: failed.content,
      );
    } else {
      // Text retry — reuse sendMessage by feeding the controller.
      messageController.text = failed.content;
      await sendMessage();
    }
  }

  /// Sends a file attachment (image/video/audio/document). The bubble shows
  /// the local file immediately (optimistic), then swaps to the server's
  /// URL once the upload returns.
  Future<void> sendAttachment({
    required File file,
    required String type, // 'image' | 'video' | 'audio' | 'document'
    String caption = '',
  }) async {
    final chat = selectedChat.value;
    if (chat == null || isSending.value) return;

    final receiverId = int.tryParse(chat.participantId);
    if (receiverId == null) {
      AppSnackBar.error(AppStrings.invalidRecipient);
      return;
    }

    // Enforce per-type upload size limits before we optimistically add the
    // bubble or hit the network.
    final limitMb = _attachmentLimitMb(type);
    if (limitMb != null) {
      final sizeMb = await file.length() / (1024 * 1024);
      if (sizeMb > limitMb) {
        AppSnackBar.error(
          '${_attachmentTypeLabel(type)} files must be under '
          '${limitMb.toStringAsFixed(0)} MB. Selected file is '
          '${sizeMb.toStringAsFixed(2)} MB.',
          title: AppStrings.maximumSizeLimit,
        );
        return;
      }
    }

    final now = DateTime.now();
    final optimistic = Message(
      id: '',
      chatId: chat.id,
      senderId: _myUserId ?? '',
      senderType: _myUserType ?? '',
      receiverId: chat.participantId,
      receiverType: chat.participantRole,
      content: caption,
      messageType: type,
      attachment: file.path,
      createdAt: now,
      isMe: true,
      timestamp: DateFormat('h:mm a').format(now),
    );
    messages.add(optimistic);
    _scrollToBottom();

    try {
      isSending.value = true;
      uploadingPath.value = file.path;
      uploadProgress.value = 0.0;
      final sent = await _chatRepository.sendMessage(
        receiverId: receiverId,
        receiverType: chat.participantRole,
        message: caption,
        type: type,
        attachment: file,
        myUserId: _myUserId ?? '',
        myUserType: _myUserType ?? '',
        onSendProgress: (percent) {
          uploadProgress.value = percent.clamp(0.0, 100.0);
        },
      );
      if (kDebugMode) {
        debugPrint(
          '[ChatController] /chat/send (attachment) response — id=${sent.id} '
          'type=${sent.messageType} attachment=${sent.attachment}',
        );
      }
      _replaceOptimisticWithCanonical(optimistic, sent);
      _bumpChatPreview(sent);
    } catch (e) {
      _markOptimisticFailed(optimistic);
      AppSnackBar.error(
        'Failed to send: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      isSending.value = false;
      uploadingPath.value = '';
      uploadProgress.value = 0.0;
    }
  }

  Future<void> startRecording() async {
    if (isRecording.value) return;

    final granted = await _ensureMicPermission();
    if (!granted) return;

    try {
      final dir = Directory('${Directory.systemTemp.path}/tuoora_voice');
      if (!await dir.exists()) await dir.create(recursive: true);
      _recordPath =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordPath!,
      );
      isRecording.value = true;
      recordSeconds.value = 0;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordSeconds.value++;
      });
    } catch (e) {
      isRecording.value = false;
      AppSnackBar.error(AppStrings.couldNotStartRecording);
    }
  }

  Future<bool> _ensureMicPermission() async {
    PermissionStatus status;
    try {
      status = await Permission.microphone.status;
    } catch (_) {
      status = PermissionStatus.denied;
    }

    if (status.isGranted || status.isLimited) return true;

    PermissionStatus result;
    try {
      result = await Permission.microphone.request();
    } catch (_) {
      result = PermissionStatus.denied;
    }

    if (result.isGranted || result.isLimited) return true;

    if (result.isPermanentlyDenied || result.isRestricted) {
      _showOpenSettingsDialog();
    } else {
      AppSnackBar.warning(AppStrings.microphonePermissionNeeded);
    }
    return false;
  }

  void _showOpenSettingsDialog() {
    CommonDialog.show(
      title: AppStrings.enableMicrophone,
      description: AppStrings.microphoneAccessIsOffForThis,
      icon: Icons.mic_off_rounded,
      confirmText: AppStrings.openSettings,
      cancelText: AppStrings.labelNotNow,
      onConfirm: () async {
        try {
          await openAppSettings();
        } catch (_) {
          AppSnackBar.error(AppStrings.couldNotOpenSettings);
        }
      },
    );
  }

  /// Discards the in-progress recording without sending.
  Future<void> cancelRecording() async {
    if (!isRecording.value) return;
    _recordTimer?.cancel();
    isRecording.value = false;
    recordSeconds.value = 0;
    try {
      await _recorder.stop();
    } catch (_) {}
    final path = _recordPath;
    _recordPath = null;
    if (path != null) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }

  /// Stops recording and sends the captured clip as an audio attachment.
  Future<void> stopAndSendRecording() async {
    if (!isRecording.value) return;
    _recordTimer?.cancel();
    final seconds = recordSeconds.value;
    isRecording.value = false;
    recordSeconds.value = 0;

    String? path;
    try {
      path = await _recorder.stop();
    } catch (e) {
      AppSnackBar.error(AppStrings.couldNotFinishRecording);
      return;
    }
    path ??= _recordPath;
    _recordPath = null;

    // Ignore accidental ultra-short taps.
    if (path == null || seconds < 1) {
      if (path != null) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      return;
    }
    await sendAttachment(file: File(path), type: 'audio');
  }

  // Per-type upload caps (MB). Document is intentionally uncapped here.
  double? _attachmentLimitMb(String type) {
    switch (type) {
      case 'image':
        return 5;
      case 'audio':
        return 10;
      case 'video':
        return 20;
      default:
        return null;
    }
  }

  String _attachmentTypeLabel(String type) {
    switch (type) {
      case 'image':
        return 'Image';
      case 'audio':
        return 'Audio';
      case 'video':
        return 'Video';
      case 'document':
        return 'Document';
      default:
        return 'File';
    }
  }

  void _replaceOptimisticWithCanonical(Message optimistic, Message canonical) {
    final folded = _applyPendingAcks(canonical);

    final idx = messages.indexOf(optimistic);
    if (idx == -1) {
      if (!messages.any((m) => m.id == folded.id && folded.id.isNotEmpty)) {
        messages.add(folded);
      }
      return;
    }
    messages[idx] = folded;
  }

  /// Merges any buffered ack timestamps for [msg]'s id into a fresh copy.
  /// Removes the buffer entry on hit so it isn't applied twice.
  Message _applyPendingAcks(Message msg) {
    if (msg.id.isEmpty) return msg;
    final pending = _pendingAcks.remove(msg.id);
    if (pending == null) return msg;
    if (kDebugMode) {
      debugPrint(
        '[ChatController] applying buffered ack to id=${msg.id}: '
        'received=${pending.receivedAt}, read=${pending.readAt}',
      );
    }
    return msg.copyWith(
      receivedAt: pending.receivedAt ?? msg.receivedAt,
      readAt: pending.readAt ?? msg.readAt,
    );
  }

  void _markOptimisticFailed(Message optimistic) {
    final idx = messages.indexOf(optimistic);
    if (idx == -1) return;
    messages[idx] = optimistic.copyWith(failed: true);
  }

  void _subscribeToSocketStreams() {
    if (!Get.isRegistered<ChatSocketService>()) {
      if (kDebugMode) {
        debugPrint(
          '[ChatController] ChatSocketService not registered — no '
          'realtime events will arrive. Check InstituteBinding.',
        );
      }
      return;
    }
    final socket = Get.find<ChatSocketService>();
    _onMessageSentSub = socket.onMessageSent.listen(_onIncomingMessage);
    _onMessageReceivedSub = socket.onMessageReceived.listen(
      _onMessageReceivedAck,
    );
    _onMessageReadSub = socket.onMessageRead.listen(_onMessageReadAck);
    _onChatDeletedSub = socket.onChatDeleted.listen(_onChatDeletedRemote);
    if (kDebugMode) {
      debugPrint('[ChatController] subscribed to socket streams');
    }
  }

  Future<void> _ensureSocketConnected() async {
    if (_myUserId == null || _myUserType == null) return;
    if (!Get.isRegistered<AuthService>() ||
        !Get.isRegistered<ChatSocketService>()) {
      return;
    }
    final auth = Get.find<AuthService>();
    if (!auth.isAuthenticated) return;
    await Get.find<ChatSocketService>().connect(
      myUserId: _myUserId!,
      myUserType: _myUserType!,
      authToken: auth.token,
    );
  }

  void _onIncomingMessage(Message msg) {
    if (kDebugMode) {
      final openId = selectedChat.value?.id;
      debugPrint(
        '[ChatController] incoming message id=${msg.id} chatId=${msg.chatId} '
        'isMe=${msg.isMe} openChat=$openId',
      );
    }
    if (msg.id.isNotEmpty && messages.any((m) => m.id == msg.id)) return;

    if (msg.isMe) {
      final expectedOpenId = selectedChat.value?.id == '_'
          ? '${selectedChat.value?.participantRole}_${selectedChat.value?.participantId}'
                .toLowerCase()
          : selectedChat.value?.id.toLowerCase();

      if (expectedOpenId == msg.chatId.toLowerCase()) {
        if (selectedChat.value?.id == '_') {
          selectedChat.value = selectedChat.value?.copyWith(id: msg.chatId);
        }
        messages.add(_applyPendingAcks(msg));
        _scrollToBottom();
      }
      return;
    }

    final mid = int.tryParse(msg.id);
    if (mid != null) {
      _chatRepository.markReceived(mid).catchError((_) => null);
    }

    final openChat = selectedChat.value;
    final expectedOpenId = openChat?.id == '_'
        ? '${openChat?.participantRole}_${openChat?.participantId}'
              .toLowerCase()
        : openChat?.id.toLowerCase();

    if (expectedOpenId == msg.chatId.toLowerCase()) {
      if (openChat?.id == '_') {
        selectedChat.value = openChat?.copyWith(id: msg.chatId);
      }

      messages.add(msg);
      _scrollToBottom();
      _bumpChatPreview(msg);
      if (mid != null) {
        _chatRepository.markRead(mid).catchError((_) => null);
      }
    } else {
      _bumpUnreadFor(msg);
    }
  }

  void _onMessageReceivedAck(MessageAck ack) {
    if (kDebugMode) {
      debugPrint(
        '[ChatController] MessageReceived ack id=${ack.messageId} '
        'at=${ack.timestamp}',
      );
    }
    _updateMessageStatus(ack.messageId, receivedAt: ack.timestamp);
  }

  void _onMessageReadAck(MessageAck ack) {
    if (kDebugMode) {
      debugPrint(
        '[ChatController] MessageRead ack id=${ack.messageId} '
        'at=${ack.timestamp}',
      );
    }
    _updateMessageStatus(ack.messageId, readAt: ack.timestamp);
  }

  void _updateMessageStatus(
    String messageId, {
    DateTime? receivedAt,
    DateTime? readAt,
  }) {
    final idx = messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) {
      final existing = _pendingAcks[messageId];
      _pendingAcks[messageId] = _PendingAck(
        receivedAt: receivedAt ?? existing?.receivedAt,
        readAt: readAt ?? existing?.readAt,
      );
      if (kDebugMode) {
        debugPrint(
          '[ChatController] _updateMessageStatus: id=$messageId not in '
          'open conversation (size=${messages.length}) — buffered ack '
          '(received=${_pendingAcks[messageId]!.receivedAt}, '
          'read=${_pendingAcks[messageId]!.readAt})',
        );
      }
      return;
    }
    final before = messages[idx];
    final after = before.copyWith(receivedAt: receivedAt, readAt: readAt);
    messages[idx] = after;
    if (kDebugMode) {
      debugPrint(
        '[ChatController] status update id=$messageId: '
        'received "${before.receivedAt}"→"${after.receivedAt}", '
        'read "${before.readAt}"→"${after.readAt}", '
        'status ${before.status}→${after.status}',
      );
    }
  }

  void _bumpUnreadFor(Message msg) {
    final idx = chatsList.indexWhere(
      (c) => c.id.toLowerCase() == msg.chatId.toLowerCase(),
    );
    if (idx == -1) {
      // Brand-new conversation we didn't know about — pull the list fresh.
      fetchChats();
      return;
    }
    final old = chatsList[idx];
    final updated = old.copyWith(
      lastMessage: msg.content,
      lastMessageType: msg.messageType,
      lastMessageAt: msg.createdAt,
      lastMessageTime: msg.createdAt == null
          ? old.lastMessageTime
          : msg.timestamp,
      unreadCount: old.unreadCount + 1,
    );
    _moveToTop(idx, updated);
  }

  void _bumpChatPreview(Message msg) {
    final idx = chatsList.indexWhere(
      (c) => c.id.toLowerCase() == msg.chatId.toLowerCase(),
    );
    if (idx == -1) return;
    final old = chatsList[idx];
    final updated = old.copyWith(
      lastMessage: msg.content,
      lastMessageType: msg.messageType,
      lastMessageAt: msg.createdAt,
      lastMessageTime: msg.timestamp,
    );
    _moveToTop(idx, updated);
  }

  /// Replaces the chat at [oldIndex] with [updated] and moves it to the top
  /// of the list. Matches WhatsApp-style ordering: the most recent
  /// conversation always sits at index 0.
  void _moveToTop(int oldIndex, Chat updated) {
    chatsList.removeAt(oldIndex);
    chatsList.insert(0, updated);
    _filterChats();
  }

  // ----------------------------------------------------- participants

  Future<void> fetchParticipants() async {
    try {
      isLoading.value = true;
      final participants = await _chatRepository.getAvailableParticipants();
      availableParticipants.assignAll(participants);
      _filterParticipants();
    } catch (e) {
      AppSnackBar.error('Failed to load members: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _filterParticipants() {
    if (participantSearchQuery.value.isEmpty) {
      filteredParticipants.assignAll(availableParticipants);
    } else {
      final query = participantSearchQuery.value.toLowerCase();
      filteredParticipants.assignAll(
        availableParticipants.where(
          (p) => p.name.toLowerCase().contains(query),
        ),
      );
    }
  }

  void startChatWithParticipant(ChatParticipant participant) {
    final composedId = '${participant.role}_${participant.id}';
    final existing = chatsList.firstWhereOrNull(
      (c) => c.id.toLowerCase() == composedId.toLowerCase(),
    );
    if (existing != null) {
      openChat(existing);
      return;
    }
    final newChat = Chat(
      id: composedId,
      participantName: participant.name,
      participantId: participant.id,
      participantImage: participant.image,
      lastMessage: '',
      lastMessageTime: '',
      participantRole: participant.role,
      myId: _myUserId,
      myRole: _myUserType,
    );
    openChat(newChat);
  }

  void openChat(Chat chat) {
    selectedChat.value = chat;
    messages.clear();
    fetchMessages(chat.id);

    // Clear local unread badge as soon as the chat opens. The history
    // endpoint server-side appears to already bulk-mark messages as read.
    final idx = chatsList.indexWhere(
      (c) => c.id.toLowerCase() == chat.id.toLowerCase(),
    );
    if (idx != -1 && chatsList[idx].unreadCount > 0) {
      chatsList[idx] = chatsList[idx].copyWith(unreadCount: 0);
      _filterChats();
    }

    final isStudent = Get.currentRoute.startsWith('/student');
    Get.toNamed(
      isStudent ? AppRoutes.studentChat : AppRoutes.instituteChatMessages,
    );
  }

  /// Called when the user leaves the chat messages screen (via system back,
  /// gesture, or the app bar). Clears the "currently open" state so that
  /// subsequent incoming messages route through the unread/preview path
  /// instead of being silently appended and auto-marked-as-read.
  void closeChat() {
    selectedChat.value = null;
    messages.clear();
  }

  /// Deletes the current conversation (or [chat] if provided) on the server,
  /// then removes it from the local chat list. When the chat is currently
  /// open, pops the messages screen back to the chat list.
  Future<void> deleteConversation([Chat? chat]) async {
    final target = chat ?? selectedChat.value;
    if (target == null) return;
    final receiverId = int.tryParse(target.participantId);
    if (receiverId == null) {
      AppSnackBar.error(AppStrings.invalidConversation);
      return;
    }

    try {
      isLoading.value = true;
      await _chatRepository.deleteConversation(
        userId: receiverId,
        userType: target.participantRole,
      );
      _removeChatLocally(target.id);
      // If we're sitting on the chat-messages route, pop back to the list.
      if (Get.currentRoute == AppRoutes.instituteChatMessages ||
          Get.currentRoute == AppRoutes.studentChat) {
        Get.until(
          (route) =>
              route.settings.name != AppRoutes.instituteChatMessages &&
              route.settings.name != AppRoutes.studentChat,
        );
      }
      closeChat();
      AppSnackBar.success(AppStrings.conversationDeleted);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles a `ChatDeleted` event fired from the server (because the OTHER
  /// participant — or one of our own other devices — deleted the
  /// conversation).
  void _onChatDeletedRemote(ChatDeleted event) {
    final id = event.chatId;
    if (kDebugMode) {
      debugPrint('[ChatController] remote ChatDeleted chatId=$id');
    }
    if (id == null) {
      // No usable identifier — refresh the whole list as a fallback.
      fetchChats();
      return;
    }
    _removeChatLocally(id);
    if (selectedChat.value?.id.toLowerCase() == id.toLowerCase()) {
      if (Get.currentRoute == AppRoutes.instituteChatMessages ||
          Get.currentRoute == AppRoutes.studentChat) {
        Get.until(
          (route) =>
              route.settings.name != AppRoutes.instituteChatMessages &&
              route.settings.name != AppRoutes.studentChat,
        );
      }
      closeChat();
      AppSnackBar.success(AppStrings.thisConversationWasDeleted);
    }
  }

  void _removeChatLocally(String chatId) {
    chatsList.removeWhere((c) => c.id.toLowerCase() == chatId.toLowerCase());
    _filterChats();
  }

  /// Scrolls the message list to the very bottom.
  ///
  /// We schedule the jump for AFTER the current frame is laid out, then do a
  /// second pass on a short delay. The second pass is what fixes the
  /// "stuck a few messages above the last one" bug: attachment bubbles
  /// (images/videos) and multi-line text expand their height asynchronously,
  /// so the first `maxScrollExtent` is an underestimate. Re-reading it after
  /// layout settles lands us on the real bottom.
  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToExtent(animate: animate);
      // Extra passes: lazy ListView.builder extents and late-loading
      // attachments keep growing the list height after the first layout.
      for (final ms in const [120, 300, 600]) {
        Future.delayed(Duration(milliseconds: ms), () {
          _scrollToExtent(animate: animate);
        });
      }
    });
  }

  void _scrollToExtent({required bool animate}) {
    if (!scrollController.hasClients) return;
    final target = scrollController.position.maxScrollExtent;
    if (animate) {
      scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.jumpTo(target);
    }
  }
}

/// Stashed delivery/read timestamps for a message whose canonical id wasn't
/// known when the broadcast arrived. See [ChatController._pendingAcks].
class _PendingAck {
  final DateTime? receivedAt;
  final DateTime? readAt;
  const _PendingAck({this.receivedAt, this.readAt});
}
