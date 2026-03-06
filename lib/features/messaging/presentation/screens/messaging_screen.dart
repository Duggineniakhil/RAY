import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/services/dummy_data_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Conversations List (Inbox)
// ─────────────────────────────────────────────────────────────────────────────

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    _autoSeed();
  }

  Future<void> _autoSeed() async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return;
    setState(() => _seeding = true);
    await DummyDataService.seedMessaging(me.uid);
    if (mounted) setState(() => _seeding = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showNewMessageSheet(context, me.uid),
          ),
        ],
      ),
      body: _seeding
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text('Loading conversations…'),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .where('participants', arrayContains: me.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error loading messages',
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(snap.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () =>
                                context.push('/home/explore'),
                            child: const Text('Try Exploring Instead'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary),
                  );
                }

                final docs = snap.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _EmptyInbox(myId: me.uid);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(indent: 72, height: 1),
                  itemBuilder: (context, i) {
                    final data =
                        docs[i].data() as Map<String, dynamic>;
                    final convId = docs[i].id;
                    final otherUserId =
                        (data['participants'] as List)
                            .firstWhere((p) => p != me.uid,
                                orElse: () => '');
                    final lastMsg =
                        data['lastMessage'] as String? ?? '';
                    final lastTime =
                        (data['lastMessageTime'] as Timestamp?)
                            ?.toDate();
                    final unreadCount =
                        (data['unread_${me.uid}'] as int?) ?? 0;

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(otherUserId)
                          .snapshots(),
                      builder: (context, userSnap) {
                        final userData = userSnap.data?.data()
                            as Map<String, dynamic>?;
                        final displayName =
                            userData?['displayName'] as String? ??
                                'User';
                        final username =
                            userData?['username'] as String? ?? '';
                        final avatar =
                            userData?['profileImage'] as String? ??
                                '';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          leading: _UserAvatar(
                              name: displayName, avatarUrl: avatar),
                          title: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (username.isNotEmpty)
                                Text(
                                  '@$username',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        Theme.of(context).hintColor,
                                  ),
                                ),
                              Text(
                                lastMsg,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: unreadCount > 0
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              if (lastTime != null)
                                Text(
                                  _formatTime(lastTime),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: unreadCount > 0
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                  ),
                                ),
                              if (unreadCount > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => context.push(
                            '/home/messaging/chat/$convId',
                            extra: {
                              'otherUserId': otherUserId,
                              'otherName': displayName
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  void _showNewMessageSheet(BuildContext context, String myId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _NewMessageSheet(myId: myId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared User Avatar Widget
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final double radius;

  const _UserAvatar({
    required this.name,
    required this.avatarUrl,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      child: avatarUrl.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.65),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Inbox Widget
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyInbox extends StatelessWidget {
  final String myId;
  const _EmptyInbox({required this.myId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text('No messages yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Start a conversation with a creator you follow',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/home/explore'),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Explore Creators'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 44)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Generating sample messages…')),
                );
                await DummyDataService.seedMessaging(myId,
                    forceReseed: true);
              },
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate Sample Messages'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 44)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Message Sheet — search users by username
// ─────────────────────────────────────────────────────────────────────────────

class _NewMessageSheet extends StatefulWidget {
  final String myId;
  const _NewMessageSheet({required this.myId});

  @override
  State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '${query}z')
        .limit(15)
        .get();
    setState(() {
      _results = snap.docs
          .where((d) => d.id != widget.myId)
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
      _loading = false;
    });
  }

  Future<void> _startConversation(Map<String, dynamic> user) async {
    final me = widget.myId;
    final them = user['id'] as String;
    final convId =
        me.compareTo(them) < 0 ? '${me}_$them' : '${them}_$me';

    final ref = FirebaseFirestore.instance
        .collection('conversations')
        .doc(convId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participants': [me, them],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unread_$me': 0,
        'unread_$them': 0,
      });
    }

    if (mounted) {
      Navigator.pop(context);
      context.push(
        '/home/messaging/chat/$convId',
        extra: {
          'otherUserId': them,
          'otherName': user['displayName'] ?? 'User'
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: _search,
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            LinearProgressIndicator(
                color:
                    Theme.of(context).colorScheme.primary),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final u = _results[i];
                final avatar =
                    u['profileImage'] as String? ?? '';
                final name =
                    u['displayName'] as String? ?? 'User';
                final username =
                    u['username'] as String? ?? '';
                return ListTile(
                  leading: _UserAvatar(
                      name: name, avatarUrl: avatar),
                  title: Text(name),
                  subtitle: Text('@$username'),
                  onTap: () => _startConversation(u),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Screen
// ─────────────────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _me = FirebaseAuth.instance.currentUser;

  CollectionReference get _messages => FirebaseFirestore.instance
      .collection('conversations')
      .doc(widget.conversationId)
      .collection('messages');

  DocumentReference get _convo => FirebaseFirestore.instance
      .collection('conversations')
      .doc(widget.conversationId);

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _me == null) return;
    _msgCtrl.clear();

    final batch = FirebaseFirestore.instance.batch();

    final msgRef = _messages.doc();
    batch.set(msgRef, {
      'senderId': _me!.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(_convo, {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unread_${widget.otherUserId}': FieldValue.increment(1),
      'unread_${_me!.uid}': 0,
    });

    await batch.commit();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (_me != null) {
      _convo.update({'unread_${_me!.uid}': 0}).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.otherUserId)
              .snapshots(),
          builder: (_, snap) {
            final data =
                snap.data?.data() as Map<String, dynamic>?;
            final avatar =
                data?['profileImage'] as String? ?? '';
            final username =
                data?['username'] as String? ?? '';
            return Row(
              children: [
                _UserAvatar(
                    name: widget.otherName,
                    avatarUrl: avatar,
                    radius: 18),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.otherName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    if (username.isNotEmpty)
                      Text('@$username',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.normal)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messages
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: Theme.of(context)
                              .colorScheme
                              .primary));
                }
                final docs = snap.data?.docs ?? [];

                // Auto-scroll on new messages
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  if (_scrollCtrl.hasClients &&
                      _scrollCtrl.position.maxScrollExtent > 0) {
                    _scrollCtrl.animateTo(
                      _scrollCtrl.position.maxScrollExtent,
                      duration:
                          const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data()
                        as Map<String, dynamic>;
                    final isMe =
                        data['senderId'] == _me?.uid;
                    final text = data['text'] as String? ?? '';
                    final ts =
                        (data['timestamp'] as Timestamp?)
                            ?.toDate();

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context)
                                    .size
                                    .width *
                                0.72),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surface,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                const Radius.circular(18),
                            topRight:
                                const Radius.circular(18),
                            bottomLeft: Radius.circular(
                                isMe ? 18 : 4),
                            bottomRight: Radius.circular(
                                isMe ? 4 : 18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                fontSize: 14,
                              ),
                            ),
                            if (ts != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white60
                                      : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    maxLines: null,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Message…',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 26,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
