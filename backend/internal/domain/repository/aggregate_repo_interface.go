package repository_interface

import (
	"context"
	"event_manager/internal/models"
	"time"
)

type AggregateRepo interface {

	// CountByEvent returns how many registrations belong to the given event.
	CountByEvent(ctx context.Context, eventID string) (int, error)

	// AggregateGuestCountByEvent returns guest and attendance counts grouped by event.
	AggregateGuestCountByEvent(ctx context.Context) ([]*models.EventGuestAggregation, error)

	// AggregateGuestCountByEventType returns guest counts grouped by event type.
	AggregateGuestCountByEventType(ctx context.Context) ([]*models.EventTypeGuestAggregation, error)

	// AggregateTopEventsByGuestCount returns top events by guest count with optional limit (<=0 means no limit).
	AggregateTopEventsByGuestCount(ctx context.Context, limit int) ([]*models.EventGuestAggregation, error)

	// AggregateGuestCountByLocation returns guest counts grouped by event location.
	AggregateGuestCountByLocation(ctx context.Context) ([]*models.LocationGuestAggregation, error)

	// AggregateParticipationTrend returns guest counts per time bucket between from/to with specified granularity.
	AggregateParticipationTrend(ctx context.Context, from, to time.Time, granularity string) ([]*models.ParticipationTrendAggregation, error)

	// AggregateGuestStatsByEvent returns attendance statistics for a single event.
	AggregateGuestStatsByEvent(ctx context.Context, eventID string) (*models.EventStatModel, error)
}
