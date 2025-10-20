import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/event_model.dart';
import '../../event_detail/event_detail_page.dart';
import 'status_badge.dart';

class EventItem extends StatefulWidget {
  final EventModel event;
  final int index;
  final VoidCallback onDelete;
  final bool isDeleting;

  const EventItem({
    super.key,
    required this.event,
    required this.index,
    required this.onDelete,
    this.isDeleting = false,
  });

  @override
  State<EventItem> createState() => _EventItemState();
}

class _EventItemState extends State<EventItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final DateFormat _dateFmt;
  late String _statusLabel;
  late Color _statusColor;
  late bool _isOngoing;
  late String _timeDisplay;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  bool _isActionPaneOpen = false;
  final double _actionWidth = 90;

  @override
  void initState() {
    super.initState();
    _dateFmt = DateFormat('dd/MM');
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  // 🧭 Cập nhật trạng thái + đếm ngược
  void _updateStatus() {
    final l10n = AppLocalizations.of(context)!;
    final e = widget.event;
    final now = DateTime.now();

    switch (e.status) {
      case 'Sắp diễn ra':
        _statusColor = Colors.indigo;
        _statusLabel = l10n.upcomingEvents;
        _isOngoing = false;
        _timeDisplay = DateFormat('dd/MM').format(e.startDate);
        break;
      case 'Đang diễn ra':
        _statusColor = Colors.green;
        _statusLabel = l10n.ongoing;
        _isOngoing = true;
        _remaining = e.endDate.difference(now);
        _timeDisplay = _formatRemaining(l10n);
        _startCountdown();
        break;
      case 'Đã kết thúc':
        _statusColor = Colors.grey;
        _statusLabel = l10n.completed;
        _isOngoing = false;
        _timeDisplay = l10n.completedOn(_dateFmt.format(e.endDate));
        break;
      default:
        _statusColor = Colors.blueGrey;
        _statusLabel = e.status;
        _isOngoing = false;
        _timeDisplay = "";
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      final diff = widget.event.endDate.difference(now);
      if (diff.isNegative) {
        _timer?.cancel();
        setState(() => _updateStatus());
      } else {
        setState(() {
          _remaining = diff;
          _timeDisplay = _formatRemaining(AppLocalizations.of(context)!);
        });
      }
    });
  }

  String _formatRemaining(AppLocalizations l10n) {
    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60);
    if (d > 0) return l10n.remainingDays(d);
    if (h > 0) return l10n.remainingHours(h);
    if (m > 0) return l10n.remainingMinutes(m);
    return l10n.remainingSeconds(_remaining.inSeconds.remainder(60));
  }

  // 🧩 Swipe handlers
  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.isDeleting) return;
    final delta = details.primaryDelta! / (_actionWidth * 1.5);
    _slideController.value -= delta;
  }

  void _onDragEnd(DragEndDetails details) {
    if (widget.isDeleting) return;
    if (details.velocity.pixelsPerSecond.dx < -400) {
      _openPane();
    } else if (details.velocity.pixelsPerSecond.dx > 400) {
      _closePane();
    } else {
      _slideController.value > 0.5 ? _openPane() : _closePane();
    }
  }

  void _openPane() {
    _slideController.fling(velocity: 1).then((_) {
      if (mounted) setState(() => _isActionPaneOpen = true);
    });
  }

  void _closePane() {
    _slideController.fling(velocity: -1).then((_) {
      if (mounted) setState(() => _isActionPaneOpen = false);
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isActionPaneOpen) return;
    final dx = details.localPosition.dx;
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 0;
    if (dx >= width - _actionWidth) {
      _closePane();
      widget.onDelete();
    } else {
      _closePane();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        _DeleteBackground(
          width: _actionWidth,
          onTap: widget.isDeleting ? null : widget.onDelete,
        ),
        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          behavior: HitTestBehavior.translucent,
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (_, child) {
              return Transform.translate(
                offset: Offset(-_slideController.value * _actionWidth, 0),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                if (_isActionPaneOpen) {
                  _closePane();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailPage(event: widget.event),
                    ),
                  );
                }
              },
              onTapUp: _handleTapUp,
              child: _EventCard(
                event: widget.event,
                statusLabel: _statusLabel,
                statusColor: _statusColor,
                timeDisplay: _timeDisplay,
              ),
            ),
          ),
        ),
        if (widget.isDeleting)
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Center(
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 🧱 Card layout của Event
class _EventCard extends StatelessWidget {
  final EventModel event;
  final String statusLabel;
  final Color statusColor;
  final String timeDisplay;

  const _EventCard({
    required this.event,
    required this.statusLabel,
    required this.statusColor,
    required this.timeDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: statusColor.withValues(alpha: 0.12),
            child: Icon(Icons.event_rounded, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: statusLabel, color: statusColor),
              const SizedBox(height: 4),
              Text(
                timeDisplay,
                style: text.bodySmall?.copyWith(
                  color: color.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🗑️ Nền xóa bên phải khi swipe
class _DeleteBackground extends StatelessWidget {
  final double width;
  final VoidCallback? onTap;

  const _DeleteBackground({required this.width, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: SizedBox(
              width: width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_rounded, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    l10n.delete,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
