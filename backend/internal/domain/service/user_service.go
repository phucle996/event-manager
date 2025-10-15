package service_interface

import (
	"context"

	"event_manager/internal/domain/entity"
)

// 🧩 UserService định nghĩa nghiệp vụ cao hơn repository
type UserService interface {
	CreateUser(ctx context.Context, username, email, fullName string) error

	UpdateProfile(ctx context.Context, id string, fullName, email string) error

	DeactivateUser(ctx context.Context, id string) error

	ActivateUser(ctx context.Context, id string) error

	GetUserByID(ctx context.Context, id string) (*entity.User, error)

	ListUsers(ctx context.Context, limit, offset int) ([]*entity.User, error)
}
