package entity

import "time"

// EventGuestStat represents aggregated guest counts for an event.
type EventGuestStat struct {
	EventID     string
	EventName   string
	Location    string
	TotalGuests int
	CheckedIn   int
}

// EventTypeGuestStat represents aggregated guest counts grouped by event type.
type EventTypeGuestStat struct {
	EventType   string
	TotalGuests int
	CheckedIn   int
}

// LocationGuestStat represents guest counts grouped by event location.
type LocationGuestStat struct {
	Location    string
	TotalGuests int
	CheckedIn   int
}

// ParticipationTrendPoint represents guest and attendance counts per time bucket.
type ParticipationTrendPoint struct {
	Period      time.Time
	TotalGuests int
	CheckedIn   int
}
