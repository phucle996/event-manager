package service_interface

import (
	"context"
	"event_manager/internal/domain/entity"
	"time"
)

type AggregateService interface {

	// GuestStatsByEvent returns aggregated guest statistics grouped by event.
	GuestStatsByEvent(ctx context.Context) ([]*entity.EventGuestStat, error)

	// GuestStatsByEventType returns aggregated guest statistics grouped by event type.
	GuestStatsByEventType(ctx context.Context) ([]*entity.EventTypeGuestStat, error)

	// GuestStatsByLocation returns aggregated guest statistics grouped by location.
	GuestStatsByLocation(ctx context.Context) ([]*entity.LocationGuestStat, error)

	// ParticipationTrend returns attendance trend grouped by granularity between the provided time range.
	ParticipationTrend(ctx context.Context, from, to time.Time, granularity string) ([]*entity.ParticipationTrendPoint, error)

	// TopEventsByGuestCount returns the top events by guest volume, limited by the provided value.
	TopEventsByGuestCount(ctx context.Context, limit int) ([]*entity.EventGuestStat, error)

	// CountGuestsByEvent returns total registrations for the specified event.
	CountGuestsByEvent(ctx context.Context, eventID string) (int, error)

	// GuestStatsSummaryByEvent returns attendance statistics for the specified event.
	GuestStatsSummaryByEvent(ctx context.Context, eventID string) (*entity.EventStat, error)
}
