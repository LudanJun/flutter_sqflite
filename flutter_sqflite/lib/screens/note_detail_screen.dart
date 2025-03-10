import 'package:flutter/material.dart';
import 'package:flutter_sqflite/database/database_helper.dart';
import 'package:flutter_sqflite/models/note.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isNew = true;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // 编辑现有笔记
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isNew = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 保存笔记
  Future<void> _saveNote() async {
    // 验证输入
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    // 获取当前时间
    final now = DateTime.now().toString();

    if (_isNew) {
      // 创建新笔记
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
        createdAt: now,
      );

      await _databaseHelper.insertNote(newNote.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('笔记已添加')),
        );
      }
    } else {
      // 更新现有笔记
      final updatedNote = Note(
        id: widget.note!.id,
        title: _titleController.text,
        content: _contentController.text,
        createdAt: widget.note!.createdAt,
      );

      await _databaseHelper.updateNote(updatedNote.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('笔记已更新')),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context, true); // 返回true表示数据已更改
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? '添加笔记' : '编辑笔记'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '内容',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        tooltip: '保存',
        child: const Icon(Icons.save),
      ),
    );
  }
}