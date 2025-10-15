package repository_interface

import (
	"context"
	"event_manager/internal/models"
)

type EventRepository interface {
	Insert(ctx context.Context, m *models.EventModel) error
	Update(ctx context.Context, m *models.EventModel) error
	Delete(ctx context.Context, id string) error
	FindByID(ctx context.Context, id string) (*models.EventModel, error)
	FindAll(ctx context.Context) ([]*models.EventModel, error)
	FindUpcoming(ctx context.Context) ([]*models.EventModel, error)
}
