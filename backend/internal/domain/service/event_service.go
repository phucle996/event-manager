package service_interface

import (
	"context"
	"time"

	"event_manager/internal/domain/entity"
)

// EventService quản lý nghiệp vụ liên quan đến Sự kiện
type EventService interface {
	// Thêm mới 1 sự kiện
	Create(ctx context.Context, e *entity.Event) error

	// Cập nhật thông tin sự kiện
	Update(ctx context.Context, e *entity.Event) error

	// Xoá sự kiện
	Delete(ctx context.Context, eventID string) error

	// Lấy thông tin 1 sự kiện
	GetByID(ctx context.Context, eventID string) (*entity.Event, error)

	// Lấy danh sách sự kiện (có thể filter theo trạng thái / ngày)
	List(ctx context.Context, status string, from, to time.Time) ([]*entity.Event, error)

	// Cập nhật trạng thái sự kiện dựa vào thời gian
	AutoUpdateStatus(ctx context.Context) error

	// Tính thống kê số khách tham dự / vắng mặt
	ComputeStatistics(ctx context.Context, eventID string) (*entity.EventStat, error)
}
