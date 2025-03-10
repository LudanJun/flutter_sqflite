import 'package:flutter/material.dart';
import 'package:flutter_sqflite/database/database_helper.dart';
import 'package:flutter_sqflite/models/note.dart';
import 'package:flutter_sqflite/screens/note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotesList();
  }

  // 刷新笔记列表
  Future<void> _refreshNotesList() async {
    setState(() {
      _isLoading = true;
    });

    final notesMaps = await _databaseHelper.getNotes();// 获取所有笔记
    setState(() {
      _notes = notesMaps.map((noteMap) => Note.fromMap(noteMap)).toList(); // 将笔记数据转换为Note对象
      _isLoading = false; // 加载完成
    });
  }

  // 删除笔记
  Future<void> _deleteNote(int id) async {
    await _databaseHelper.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('笔记已删除')),
    );
    _refreshNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的笔记'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text('没有笔记，点击 + 按钮添加'))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Dismissible(
                      key: Key(note.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _deleteNote(note.id!);
                      },
                      child: ListTile(
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(note.createdAt.split(' ')[0]),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(note: note),
                            ),
                          );
                          if (result == true) {
                            _refreshNotesList();
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteDetailScreen(),
            ),
          );
          if (result == true) {
            _refreshNotesList();
          }
        },
        tooltip: '添加笔记',
        child: const Icon(Icons.add),
      ),
    );
  }
}