package repository_interface

import (
	"context"

	"event_manager/internal/models"
)

type UserRepository interface {
	Insert(ctx context.Context, user *models.UserModel) error

	Update(ctx context.Context, user *models.UserModel) error

	Delete(ctx context.Context, id string) error

	FindByID(ctx context.Context, id string) (*models.UserModel, error)

	FindByUsername(ctx context.Context, username string) (*models.UserModel, error)

	List(ctx context.Context, limit, offset int) ([]*models.UserModel, error)
}
