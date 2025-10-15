package entity

import "time"

// Đánh giá sau sự kiện
type Review struct {
	ID        string
	EventID   string
	GuestID   string
	Rating    float64
	Comment   string
	CreatedAt time.Time
}
