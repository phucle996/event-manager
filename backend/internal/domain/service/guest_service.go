package service_interface

import (
	"context"

	"event_manager/internal/domain/entity"
)

// GuestService defines business operations for guest entities.
type GuestService interface {
	// Create persists a new guest in the domain.
	Create(ctx context.Context, guest *entity.Guest, eventID string) error

	// Update modifies an existing guest.
	Update(ctx context.Context, guest *entity.Guest, eventID string) error

	// Delete removes a guest by identifier.
	Delete(ctx context.Context, guestID string) error

	// GetByID returns a guest by identifier.
	GetByID(ctx context.Context, guestID string) (*entity.Guest, error)

	// List returns guests matching the optional keyword.
	List(ctx context.Context, keyword string) ([]*entity.Guest, error)

	// FindByContact locates a guest using email and/or phone.
	FindByContact(ctx context.Context, email, phone string) (*entity.Guest, error)
}
