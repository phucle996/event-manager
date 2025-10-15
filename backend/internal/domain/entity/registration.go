package entity

import "time"

// Đăng ký tham dự (Registration)
type Registration struct {
	ID        string
	EventID   string
	GuestID   string
	Status    string
	CreatedAt time.Time
	CheckedIn bool
}
