import 'package:flutter/material.dart';
import '../../../../../generated/colors.gen.dart';

class SelectFriendsPage extends StatefulWidget {
  const SelectFriendsPage({super.key});

  @override
  State<SelectFriendsPage> createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  final List<_Friend> _friends = List.generate(
    20,
    (i) => _Friend(
      name: 'User ${i + 1}',
      avatar: 'https://i.pravatar.cc/150?img=${(i % 70) + 1}',
      friendsCount: 10 + (i * 7) % 80,
    ),
  );

  final Set<int> _selected = {};

  bool get _allSelected => _selected.length == _friends.length;

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selected.clear();
      } else {
        _selected.addAll(List.generate(_friends.length, (i) => i));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.white,
      appBar: AppBar(
        backgroundColor: ColorName.white,
        surfaceTintColor: ColorName.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorName.black87,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        title: const Text(
          'Select friends',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _toggleAll,
            icon: Icon(
              _allSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: ColorName.mint,
            ),
            label: Text(
              _allSelected ? 'Deselect all' : 'Select all',
              style: const TextStyle(color: ColorName.mint),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // search UI (chưa lọc thật)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF5F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _friends.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final f = _friends[index];
                final selected = _selected.contains(index);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(f.avatar),
                    radius: 24,
                  ),
                  title: Text(
                    f.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${f.friendsCount} friends'),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (_) {
                      setState(() => selected
                          ? _selected.remove(index)
                          : _selected.add(index));
                    },
                  ),
                  onTap: () {
                    setState(() => selected
                        ? _selected.remove(index)
                        : _selected.add(index));
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.mint,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(), // demo UI
              child: Text('Done (${_selected.length})'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Friend {
  final String name;
  final String avatar;
  final int friendsCount;
  _Friend({
    required this.name,
    required this.avatar,
    required this.friendsCount,
  });
}
