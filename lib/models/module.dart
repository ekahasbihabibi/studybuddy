class Module {
  final String id;
  final String title;
  final String description;
  final String content;
  final String subject;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.subject,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      subject: json['subject'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'content': content,
    'subject': subject,
  };
}
