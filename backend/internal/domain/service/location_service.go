package service_interface

import (
	"context"

	"event_manager/internal/domain/entity"
)

// LocationService quản lý Địa điểm tổ chức
type LocationService interface {
	Create(ctx context.Context, l *entity.Location) error

	Update(ctx context.Context, l *entity.Location) error

	Delete(ctx context.Context, locationID string) error

	GetByID(ctx context.Context, locationID string) (*entity.Location, error)

	List(ctx context.Context) ([]*entity.Location, error)

	// Kiểm tra sức chứa khi thêm khách
	CheckCapacity(ctx context.Context, locationID string, expected int) (bool, error)
}
