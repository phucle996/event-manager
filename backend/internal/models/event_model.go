package models

import (
	"event_manager/internal/domain/entity"
	"time"
)

// Model lưu trong DB hoặc trả về API
type EventModel struct {
	ID          string    `bson:"_id,omitempty" json:"id"`
	Name        string    `bson:"name" json:"name"`
	Description string    `bson:"description" json:"description"`
	Type        string    `bson:"type" json:"type"` // "Sự kiện mở", "Sự kiện giới hạn", ...
	Status      string    `bson:"status" json:"status"`
	Location    string    `bson:"location" json:"location"`
	MaxGuests   uint      `bson:"max_guests" json:"max_guests"`
	StartDate   time.Time `bson:"start_date" json:"start_date"`
	EndDate     time.Time `bson:"end_date" json:"end_date"`
	ImageURLs   []string  `bson:"image_urls" json:"image_urls"` // Danh sách ảnh sự kiện
	CreatedAt   time.Time `bson:"created_at" json:"created_at"`
	UpdatedAt   time.Time `bson:"updated_at" json:"updated_at"`
}

// Convert từ domain entity sang DB model
func EventModelToEntity(e entity.Event) EventModel {
	return EventModel{
		ID:          e.ID,
		Name:        e.Name,
		Description: e.Description,
		Type:        e.Type,
		Status:      e.Status,
		Location:    e.Location,
		MaxGuests:   e.MaxGuests,
		StartDate:   e.StartDate,
		EndDate:     e.EndDate,
		ImageURLs:   e.ImageURLs,
		CreatedAt:   e.CreatedAt,
		UpdatedAt:   e.UpdatedAt,
	}
}

// Convert từ DB model sang domain entity
func (m EventModel) EventEntityToModel() entity.Event {
	return entity.Event{
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
	}
}
