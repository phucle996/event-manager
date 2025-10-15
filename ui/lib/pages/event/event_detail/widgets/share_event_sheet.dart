import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void shareEvent(BuildContext context, Map<String, dynamic> event) {
  final link = event["shareLink"] ?? "https://example.com";
  final name = event["name"] ?? "Sự kiện Aurora";

  SharePlus.instance.share(
    ShareParams(
      text: "🎉 $name\n$link",
      subject: "Mời bạn tham dự sự kiện này!",
    ),
  );
}
