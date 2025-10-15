package repository_interface

import (
	"context"

	"event_manager/internal/models"
)

type RegistrationRepository interface {
	// Insert stores a new registration model.
	Insert(ctx context.Context, model *models.RegistrationModel) error

	// Update persists registration changes.
	Update(ctx context.Context, model *models.RegistrationModel) error

	// Delete removes a registration by identifier.
	Delete(ctx context.Context, registrationID string) error

	// FindByID fetches a registration model by identifier.
	FindByID(ctx context.Context, registrationID string) (*models.RegistrationModel, error)

	// FindByEvent lists registration models by event identifier.
	FindByEvent(ctx context.Context, eventID string) ([]*models.RegistrationModel, error)

	// FindByGuest lists registration models by guest identifier.
	FindByGuest(ctx context.Context, guestID string) ([]*models.RegistrationModel, error)
}
