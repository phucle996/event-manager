package service_interface

import (
	"context"

	"event_manager/internal/domain/entity"
)

// RegistrationService defines business operations for registration entities.
type RegistrationService interface {
	// Register records a guest registration for an event.
	Register(ctx context.Context, registration *entity.Registration) error

	// CheckIn marks a registration as attended and returns the updated entity.
	CheckIn(ctx context.Context, registrationID string) (*entity.Registration, error)

	// Cancel revokes a registration and returns the updated entity.
	Cancel(ctx context.Context, registrationID string) (*entity.Registration, error)

	// GetByID fetches a registration by identifier.
	GetByID(ctx context.Context, registrationID string) (*entity.Registration, error)

	// ListByEvent returns registrations associated with the given event.
	ListByEvent(ctx context.Context, eventID string) ([]*entity.Registration, error)

	// ListByGuest returns registrations created by the given guest.
	ListByGuest(ctx context.Context, guestID string) ([]*entity.Registration, error)
}
