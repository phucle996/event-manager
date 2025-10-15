package repository_interface

import (
	"context"
	"event_manager/internal/models"
)

type ReviewRepository interface {
	Insert(ctx context.Context, m *models.ReviewModel) error
	Update(ctx context.Context, m *models.ReviewModel) error
	Delete(ctx context.Context, id string) error
	FindByID(ctx context.Context, id string) (*models.ReviewModel, error)
	FindByEvent(ctx context.Context, eventID string) ([]*models.ReviewModel, error)
	FindByGuest(ctx context.Context, guestID string) ([]*models.ReviewModel, error)
	AverageRating(ctx context.Context, eventID string) (float64, error)
}
