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
  Timer? _timer;
  late Duration _remaining;
  late String _statusLabel;
  late Color _statusColor;
  late String _timeDisplay;
  late bool _isOngoing;

  late final AnimationController _slideController;
  late final DateFormat _dateFmt;

  bool _isActionPaneOpen = false;
  final double _actionWidth = 90.0;

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
    _updateStatusAndTimeline();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  void _updateStatusAndTimeline() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    String currentStatusKey;
    switch (widget.event.status) {
      case 'Sắp diễn ra':
        currentStatusKey = 'upcoming';
        _statusColor = Colors.indigo;
        break;
      case 'Đang diễn ra':
        currentStatusKey = 'ongoing';
        _statusColor = Colors.green;
        break;
      case 'Đã kết thúc':
        currentStatusKey = 'completed';
        _statusColor = Colors.grey;
        break;
      default:
        currentStatusKey = 'unknown';
        _statusColor = Colors.blueGrey;
    }

    switch (currentStatusKey) {
      case 'upcoming':
        _statusLabel = l10n.upcomingEvents;
        break;
      case 'ongoing':
        _statusLabel = l10n.ongoing;
        break;
      case 'completed':
        _statusLabel = l10n.completed;
        break;
      default:
        _statusLabel = widget.event.status;
    }

    _isOngoing = (currentStatusKey == 'ongoing');

    _timer?.cancel();
    if (_isOngoing) {
      _remaining = widget.event.endDate.difference(now);
      _timeDisplay = _formatRemaining(l10n);
      _startCountdown();
    } else {
      _timeDisplay = _formatStaticTime(l10n);
    }
  }

  String _formatStaticTime(AppLocalizations l10n) {
    final now = DateTime.now();
    if (_statusLabel == l10n.upcomingEvents) {
      final start = widget.event.startDate;
      return (start.year != now.year)
          ? DateFormat('dd/MM/yyyy').format(start)
          : _dateFmt.format(start);
    } else {
      final end = widget.event.endDate;
      final formattedDate = (end.year != now.year)
          ? DateFormat('dd/MM/yyyy').format(end)
          : _dateFmt.format(end);
      return l10n.completedOn(formattedDate);
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }

      final now = DateTime.now();
      final diff = widget.event.endDate.difference(now);

      if (diff.isNegative) {
        _timer?.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isOngoing = false;
              _updateStatusAndTimeline();
            });
          }
        });
      } else {
        setState(() {
          _remaining = diff;
          _timeDisplay = _formatRemaining(AppLocalizations.of(context)!);
        });
      }
    });
  }

  String _formatRemaining(AppLocalizations l10n) {
    if (!_isOngoing || _remaining.isNegative) return l10n.completed;
    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (d > 0) return l10n.remainingDays(d);
    if (h > 0) return l10n.remainingHours(h);
    if (m > 0) return l10n.remainingMinutes(m);
    return l10n.remainingSeconds(s);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.isDeleting) return;
    final delta = details.primaryDelta! / (_actionWidth * 1.5);
    _slideController.value -= delta;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.isDeleting) return;
    if (_slideController.isDismissed || _slideController.isCompleted) return;
    if (details.velocity.pixelsPerSecond.dx < -500) {
      _openActionPane();
    } else if (details.velocity.pixelsPerSecond.dx > 500) {
      _closeActionPane();
    } else {
      _slideController.value > 0.5 ? _openActionPane() : _closeActionPane();
    }
  }

  void _openActionPane() {
    _slideController.fling(velocity: 1.0).then((_) {
      if (mounted) setState(() => _isActionPaneOpen = true);
    });
  }

  void _closeActionPane() {
    _slideController.fling(velocity: -1.0).then((_) {
      if (mounted) setState(() => _isActionPaneOpen = false);
    });
  }

  void _handleContentTap() {
    if (widget.isDeleting) return;
    if (!_isActionPaneOpen) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a1, a2) => EventDetailPage(event: widget.event),
          transitionsBuilder: (_, a1, a2, child) => SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(a1),
            child: child,
          ),
        ),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isDeleting || !_isActionPaneOpen) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 0;
    final localDx = details.localPosition.dx;
    if (width > 0 && localDx >= width - _actionWidth) {
      _closeActionPane();
      widget.onDelete();
    } else {
      _closeActionPane();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final itemContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _statusColor.withValues(alpha: 0.15),
            child: Icon(Icons.event, color: _statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.event.location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: _statusLabel, color: _statusColor),
              const SizedBox(height: 4),
              Text(
                _timeDisplay,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isDeleting
                      ? null
                      : () {
                          _closeActionPane();
                          widget.onDelete();
                        },
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Container(
                    width: _actionWidth,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 8),
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
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          behavior: HitTestBehavior.translucent,
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-_slideController.value * _actionWidth, 0),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _handleContentTap,
              onTapUp: _handleTapUp,
              child: itemContent,
            ),
          ),
        ),
        if (widget.isDeleting)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
