package dto

import (
	"time"
)

// ======================================
// 📥 EventCreateRequest
// ======================================
type EventCreateRequest struct {
	Name        string    `form:"name" binding:"required"`
	Location    string    `form:"location" binding:"required"`
	Type        string    `form:"type" binding:"required"` // "Sự kiện mở" | "Sự kiện giới hạn"
	Status      string    `form:"status"`                  // mặc định: "Sắp diễn ra"
	Description string    `form:"description"`             // mô tả sự kiện (tùy chọn)
	MaxGuests   uint      `form:"max_guests"`              // chỉ cần nếu Type = "Sự kiện giới hạn"
	StartDate   time.Time `form:"start_date" time_format:"2006-01-02T15:04:05Z07:00" binding:"required"`
	EndDate     time.Time `form:"end_date"   time_format:"2006-01-02T15:04:05Z07:00" binding:"required"`
}

// ======================================
// 📥 EventUpdateRequest
// ======================================
type EventUpdateRequest struct {
	Name        string     `form:"name" binding:"required"`
	Description string     `form:"description"`
	Type        string     `form:"type" binding:"required"`
	Status      string     `form:"status"`
	Location    string     `form:"location" binding:"required"`
	MaxGuests   uint       `form:"max_guests"`
	StartDate   *time.Time `form:"start_date" time_format:"2006-01-02T15:04:05Z07:00"`
	EndDate     *time.Time `form:"end_date"   time_format:"2006-01-02T15:04:05Z07:00"`
	ImageURLs   []string   `form:"images_url"`
}

// ======================================
// 📤 EventResponse
// ======================================
type EventResponse struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Status    string    `json:"status"`
	StartDate time.Time `json:"start_date"`
	EndDate   time.Time `json:"end_date"`
	Location  string    `json:"location"`
}

// EventDetailResponse - dùng cho GET /events/:id
type EventDetailResponse struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Type        string    `json:"type"`
	Status      string    `json:"status"`
	Location    string    `json:"location"`
	MaxGuests   int       `json:"max_guests"`
	StartDate   time.Time `json:"start_date"`
	EndDate     time.Time `json:"end_date"`
	ImageURLs   []string  `json:"image_urls"`
}

// ======================================
// 📊 EventStatisticResponse
// ======================================
type EventStatisticResponse struct {
	EventID     string `json:"event_id"`
	TotalGuests int    `json:"total_guests"`
	CheckedIn   int    `json:"checked_in"`
	Absent      int    `json:"absent"`
}
