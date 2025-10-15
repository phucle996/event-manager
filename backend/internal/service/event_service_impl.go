package service_imple

import (
	"context"
	"errors"
	"fmt"
	"time"

	"event_manager/internal/domain/entity"
	repo "event_manager/internal/domain/repository"
	service_interface "event_manager/internal/domain/service"
	"event_manager/internal/models"
)

// ========================================
// 🧩 EventServiceImpl triển khai EventService
// ========================================
type EventServiceImpl struct {
	eventRepo        repo.EventRepository
	registrationRepo repo.RegistrationRepository
}

// ✅ Khởi tạo service
func NewEventService(
	eventRepo repo.EventRepository,
	registrationRepo repo.RegistrationRepository,
) service_interface.EventService {
	return &EventServiceImpl{
		eventRepo:        eventRepo,
		registrationRepo: registrationRepo,
	}
}

// 🟢 Tạo sự kiện mới
func (s *EventServiceImpl) Create(ctx context.Context, e *entity.Event) error {
	if e == nil {
		return errors.New("event is nil")
	}

	model := &models.EventModel{
		ID:          e.ID,
		Name:        e.Name,
		Description: e.Description,
		Type:        e.Type,
		Status:      getStatusByTime(e.StartDate, e.EndDate),
		Location:    e.Location,
		MaxGuests:   e.MaxGuests,
		StartDate:   e.StartDate,
		EndDate:     e.EndDate,
		ImageURLs:   e.ImageURLs,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	return s.eventRepo.Insert(ctx, model)
}

// 🟡 Cập nhật thông tin sự kiện
func (s *EventServiceImpl) Update(ctx context.Context, e *entity.Event) error {
	if e == nil || e.ID == "" {
		return errors.New("invalid event")
	}

	// 🧩 Lấy event cũ từ DB
	old, err := s.eventRepo.FindByID(ctx, e.ID)
	if err != nil {
		return fmt.Errorf("failed to get existing event: %w", err)
	}

	// ⚙️ Giữ lại nếu client không gửi
	if e.StartDate.IsZero() {
		e.StartDate = old.StartDate
	}
	if e.EndDate.IsZero() {
		e.EndDate = old.EndDate
	}
	if e.Status == "" {
		e.Status = old.Status
	}

	model := &models.EventModel{
		ID:          e.ID,
		Name:        e.Name,
		Description: e.Description,
		Type:        e.Type,
		Status:      getStatusByTime(e.StartDate, e.EndDate),
		Location:    e.Location,
		MaxGuests:   e.MaxGuests,
		StartDate:   e.StartDate,
		EndDate:     e.EndDate,
		ImageURLs:   e.ImageURLs,
		UpdatedAt:   time.Now(),
	}

	return s.eventRepo.Update(ctx, model)
}

// 🔴 Xoá sự kiện
func (s *EventServiceImpl) Delete(ctx context.Context, eventID string) error {
	if eventID == "" {
		return errors.New("missing event ID")
	}
	return s.eventRepo.Delete(ctx, eventID)
}

// 🔍 Lấy thông tin chi tiết sự kiện
func (s *EventServiceImpl) GetByID(ctx context.Context, eventID string) (*entity.Event, error) {
	m, err := s.eventRepo.FindByID(ctx, eventID)
	if err != nil || m == nil {
		return nil, err
	}
	return &entity.Event{
		ID:          m.ID,
		Name:        m.Name,
		Description: m.Description,
		Type:        m.Type,
		Status:      m.Status,
		Location:    m.Location,
		MaxGuests:   m.MaxGuests,
		StartDate:   m.StartDate,
		EndDate:     m.EndDate,
		ImageURLs:   m.ImageURLs,
		CreatedAt:   m.CreatedAt,
		UpdatedAt:   m.UpdatedAt,
	}, nil
}

// 📋 Lấy danh sách sự kiện (lọc theo trạng thái / thời gian)
func (s *EventServiceImpl) List(ctx context.Context, status string, from, to time.Time) ([]*entity.Event, error) {
	all, err := s.eventRepo.FindAll(ctx)
	if err != nil {
		return nil, err
	}

	var result []*entity.Event
	for _, m := range all {
		if !from.IsZero() && m.StartDate.Before(from) {
			continue
		}
		if !to.IsZero() && m.EndDate.After(to) {
			continue
		}
		if status != "" && status != "Tất cả" && m.Status != status {
			continue
		}

		result = append(result, &entity.Event{
			ID:          m.ID,
			Name:        m.Name,
			Description: m.Description,
			Type:        m.Type,
			Status:      m.Status,
			Location:    m.Location,
			MaxGuests:   m.MaxGuests,
			StartDate:   m.StartDate,
			EndDate:     m.EndDate,
			ImageURLs:   m.ImageURLs,
			CreatedAt:   m.CreatedAt,
			UpdatedAt:   m.UpdatedAt,
		})
	}
	return result, nil
}

// 🔄 Tự động cập nhật trạng thái sự kiện
func (s *EventServiceImpl) AutoUpdateStatus(ctx context.Context) error {
	all, err := s.eventRepo.FindAll(ctx)
	if err != nil {
		return err
	}

	for _, m := range all {
		newStatus := getStatusByTime(m.StartDate, m.EndDate)
		if m.Status != newStatus {
			m.Status = newStatus
			m.UpdatedAt = time.Now()
			if err := s.eventRepo.Update(ctx, m); err != nil {
				return err
			}
		}
	}
	return nil
}

// 📊 Tính thống kê số khách tham dự / vắng mặt
func (s *EventServiceImpl) ComputeStatistics(ctx context.Context, eventID string) (*entity.EventStat, error) {
	regs, err := s.registrationRepo.FindByEvent(ctx, eventID)
	if err != nil {
		return nil, err
	}

	var checkedIn, absent int
	for _, r := range regs {
		if r.CheckedIn {
			checkedIn++
		} else {
			absent++
		}
	}

	return &entity.EventStat{
		EventID:     eventID,
		TotalGuests: len(regs),
		CheckedIn:   checkedIn,
		Absent:      absent,
	}, nil
}

// ========================================
// 🧩 Helper
// ========================================

// Xác định trạng thái sự kiện theo StartDate / EndDate
func getStatusByTime(start, end time.Time) string {
	now := time.Now()
	switch {
	case now.Before(start):
		return "Sắp diễn ra"
	case now.After(end):
		return "Đã kết thúc"
	default:
		return "Đang diễn ra"
	}
}
