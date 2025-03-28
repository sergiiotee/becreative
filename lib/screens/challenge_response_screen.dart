return ListTile(
  leading: completed == total && total > 0
      ? Icon(Icons.emoji_events, color: Colors.amber)
      : null,
  title: Text(interest),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        color: Colors.indigo,
        minHeight: 6,
      ),
      SizedBox(height: 4),
      Text('$completed de $total completados'),
    ],
  ),
);