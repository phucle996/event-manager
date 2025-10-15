package models

import (
	"event_manager/internal/domain/entity"
	"time"
)

// EventGuestAggregation is the persistence-layer representation of event guest stats.
type EventGuestAggregation struct {
	EventID     string `bson:"event_id"`
	EventName   string `bson:"event_name,omitempty"`
	Location    string `bson:"location,omitempty"`
	TotalGuests int    `bson:"total_guests"`
	CheckedIn   int    `bson:"checked_in"`
}

// EventTypeGuestAggregation represents aggregated counts grouped by event type.
type EventTypeGuestAggregation struct {
	EventType   string `bson:"event_type"`
	TotalGuests int    `bson:"total_guests"`
	CheckedIn   int    `bson:"checked_in"`
}

// LocationGuestAggregation represents aggregated counts grouped by location.
type LocationGuestAggregation struct {
	Location    string `bson:"location"`
	TotalGuests int    `bson:"total_guests"`
	CheckedIn   int    `bson:"checked_in"`
}

// ParticipationTrendAggregation represents counts grouped by a time bucket.
type ParticipationTrendAggregation struct {
	Period      time.Time `bson:"period"`
	TotalGuests int       `bson:"total_guests"`
	CheckedIn   int       `bson:"checked_in"`
}

// ToEntity converts EventGuestAggregation to domain entity.
func (a *EventGuestAggregation) ToEntity() *entity.EventGuestStat {
	if a == nil {
		return nil
	}
	return &entity.EventGuestStat{
		EventID:     a.EventID,
		EventName:   a.EventName,
		Location:    a.Location,
		TotalGuests: a.TotalGuests,
		CheckedIn:   a.CheckedIn,
	}
}

// ToEntity converts EventTypeGuestAggregation to domain entity.
func (a *EventTypeGuestAggregation) ToEntity() *entity.EventTypeGuestStat {
	if a == nil {
		return nil
	}
	return &entity.EventTypeGuestStat{
		EventType:   a.EventType,
		TotalGuests: a.TotalGuests,
		CheckedIn:   a.CheckedIn,
	}
}

// ToEntity converts LocationGuestAggregation to domain entity.
func (a *LocationGuestAggregation) ToEntity() *entity.LocationGuestStat {
	if a == nil {
		return nil
	}
	return &entity.LocationGuestStat{
		Location:    a.Location,
		TotalGuests: a.TotalGuests,
		CheckedIn:   a.CheckedIn,
	}
}

// ToEntity converts ParticipationTrendAggregation to domain entity.
func (a *ParticipationTrendAggregation) ToEntity() *entity.ParticipationTrendPoint {
	if a == nil {
		return nil
	}
	return &entity.ParticipationTrendPoint{
		Period:      a.Period,
		TotalGuests: a.TotalGuests,
		CheckedIn:   a.CheckedIn,
	}
}
