import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import 'rating_stars.dart';
import 'review_item.dart';

class EventReviews extends StatefulWidget {
  final String status;
  final Color eventColor;

  const EventReviews({
    super.key,
    required this.status,
    required this.eventColor,
  });

  @override
  State<EventReviews> createState() => _EventReviewsState();
}

class _EventReviewsState extends State<EventReviews> {
  final TextEditingController _commentController = TextEditingController();
  double _newRating = 0;
  bool _showAllReviews = false;

  // Mock data - in a real app, this would come from an API and be localized
  final List<Map<String, dynamic>> _reviews = [
    {
      "name": "Nguyễn Văn A",
      "rating": 4.5,
      "comment": "Không gian tổ chức chuyên nghiệp, rất ấn tượng!",
      "date": DateTime(2025, 10, 12),
    },
    {
      "name": "Trần Thị B",
      "rating": 5.0,
      "comment": "Mọi thứ tuyệt vời, mong có thêm nhiều sự kiện như thế này.",
      "date": DateTime(2025, 10, 13),
    },
    {
      "name": "Lê Văn C",
      "rating": 3.5,
      "comment": "Ổn nhưng phần âm thanh hơi nhỏ.",
      "date": DateTime(2025, 10, 11),
    },
    {
      "name": "Phạm Duy",
      "rating": 4.0,
      "comment": "Rất vui và ý nghĩa!",
      "date": DateTime(2025, 10, 10),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final avg = _reviews.isNotEmpty
        ? _reviews.map((r) => r["rating"]).reduce((a, b) => a + b) /
            _reviews.length
        : 0.0;
    final visible = _showAllReviews ? _reviews : _reviews.take(3).toList();

    final isReviewFormVisible = widget.status == l10n.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewsAndRatings,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    avg.toStringAsFixed(1),
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.xReviews(_reviews.length),
                    style: text.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ...visible.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReviewItem(review: r),
                ),
              ),
              if (!_showAllReviews && _reviews.length > 3)
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => setState(() => _showAllReviews = true),
                    child: Text(l10n.showMoreReviews),
                  ),
                ),
              if (isReviewFormVisible) ...[
                const Divider(height: 32),
                Text(
                  l10n.writeYourReview,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                RatingStars(
                  rating: _newRating,
                  onRate: (r) => setState(() => _newRating = r),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l10n.shareYourThoughts,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {},
                    child: Text(l10n.submitReview),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
