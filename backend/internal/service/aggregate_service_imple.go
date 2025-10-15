package service_imple

import (
	"context"
	"errors"
	"event_manager/internal/domain/entity"
	repository_interface "event_manager/internal/domain/repository"
	service_interface "event_manager/internal/domain/service"
	"event_manager/internal/models"
	"fmt"
	"strings"
	"time"
)

// RegistrationServiceImpl coordinates registration domain operations.
type AggregateServiceImpl struct {
	repo repository_interface.AggregateRepo
}

// NewRegistrationService constructs a RegistrationService backed by the repository.
func NewAggregateServiceImpl(repo repository_interface.AggregateRepo) service_interface.AggregateService {
	return &AggregateServiceImpl{repo: repo}
}

// GuestStatsByEvent returns aggregated guest statistics grouped by event.
func (s *AggregateServiceImpl) GuestStatsByEvent(ctx context.Context) ([]*entity.EventGuestStat, error) {
	aggs, err := s.repo.AggregateGuestCountByEvent(ctx)
	if err != nil {
		return nil, fmt.Errorf("aggregate guest stats by event failed: %w", err)
	}
	result := make([]*entity.EventGuestStat, 0, len(aggs))
	for _, agg := range aggs {
		if agg == nil {
			continue
		}
		result = append(result, agg.ToEntity())
	}
	return result, nil
}

// GuestStatsByEventType returns aggregated guest statistics grouped by event type.
func (s *AggregateServiceImpl) GuestStatsByEventType(ctx context.Context) ([]*entity.EventTypeGuestStat, error) {
	aggs, err := s.repo.AggregateGuestCountByEventType(ctx)
	if err != nil {
		return nil, fmt.Errorf("aggregate guest stats by event type failed: %w", err)
	}
	result := make([]*entity.EventTypeGuestStat, 0, len(aggs))
	for _, agg := range aggs {
		if agg == nil {
			continue
		}
		result = append(result, agg.ToEntity())
	}
	return result, nil
}

// GuestStatsByLocation returns aggregated guest statistics grouped by location.
func (s *AggregateServiceImpl) GuestStatsByLocation(ctx context.Context) ([]*entity.LocationGuestStat, error) {
	aggs, err := s.repo.AggregateGuestCountByLocation(ctx)
	if err != nil {
		return nil, fmt.Errorf("aggregate guest stats by location failed: %w", err)
	}
	result := make([]*entity.LocationGuestStat, 0, len(aggs))
	for _, agg := range aggs {
		if agg == nil {
			continue
		}
		result = append(result, agg.ToEntity())
	}
	return result, nil
}

// ParticipationTrend returns attendance trend grouped by granularity.
func (s *AggregateServiceImpl) ParticipationTrend(ctx context.Context, from, to time.Time, granularity string) ([]*entity.ParticipationTrendPoint, error) {
	granularity = strings.ToLower(strings.TrimSpace(granularity))
	if granularity == "" {
		granularity = "day"
	}
	aggs, err := s.repo.AggregateParticipationTrend(ctx, from, to, granularity)
	if err != nil {
		return nil, fmt.Errorf("aggregate participation trend failed: %w", err)
	}
	result := make([]*entity.ParticipationTrendPoint, 0, len(aggs))
	for _, agg := range aggs {
		if agg == nil {
			continue
		}
		result = append(result, agg.ToEntity())
	}
	return result, nil
}

// TopEventsByGuestCount returns the top events by registrations.
func (s *AggregateServiceImpl) TopEventsByGuestCount(ctx context.Context, limit int) ([]*entity.EventGuestStat, error) {
	if limit < 0 {
		return nil, errors.New("limit must be non-negative")
	}
	aggs, err := s.repo.AggregateTopEventsByGuestCount(ctx, limit)
	if err != nil {
		return nil, fmt.Errorf("aggregate top events failed: %w", err)
	}
	result := make([]*entity.EventGuestStat, 0, len(aggs))
	for _, agg := range aggs {
		if agg == nil {
			continue
		}
		result = append(result, agg.ToEntity())
	}
	return result, nil
}

func mapRegistrationModels(modelsList []*models.RegistrationModel) []*entity.Registration {
	result := make([]*entity.Registration, 0, len(modelsList))
	for _, m := range modelsList {
		if m == nil {
			continue
		}
		result = append(result, m.RegistrationModelToEntity())
	}
	return result
}

// CountGuestsByEvent returns total registrations for the specified event.
func (s *AggregateServiceImpl) CountGuestsByEvent(ctx context.Context, eventID string) (int, error) {
	if strings.TrimSpace(eventID) == "" {
		return 0, errors.New("event id is required")
	}
	count, err := s.repo.CountByEvent(ctx, eventID)
	if err != nil {
		return 0, fmt.Errorf("count registrations by event failed: %w", err)
	}
	return count, nil
}
