class Note {
  int? id;
  String title;
  String content;
  String createdAt;

  Note({
    this.id,
    required this.title, // 标题
    required this.content, // 内容
    required this.createdAt,// 创建时间
  });

  // 从Map创建Note对象（用于从数据库读取数据）
  factory Note.fromMap(Map<String, dynamic> map) { 
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['createdAt'],
    );
  }

  // 将Note对象转换为Map（用于向数据库写入数据）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }

  // 复制Note对象并修改部分属性
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}