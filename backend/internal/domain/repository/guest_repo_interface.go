package repository_interface

import (
	"context"
	"event_manager/internal/models"
)

type GuestRepository interface {
	// Insert stores a new guest model.
	Insert(ctx context.Context, model *models.GuestModel) error

	// Update persists guest changes.
	Update(ctx context.Context, model *models.GuestModel) error

	// Delete removes a guest by identifier.
	Delete(ctx context.Context, guestID string) error

	// FindByID fetches a guest model by identifier.
	FindByID(ctx context.Context, guestID string) (*models.GuestModel, error)

	// FindAll lists all guest models.
	FindAll(ctx context.Context) ([]*models.GuestModel, error)

	// FindByEmail locates a guest by email address.
	FindByEmail(ctx context.Context, email string) (*models.GuestModel, error)
}
