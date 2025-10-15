package dto

import "time"

// RegistrationCreateRequest carries payload to create a registration.
type RegistrationCreateRequest struct {
	EventID string `json:"event_id" binding:"required"`
	GuestID string `json:"guest_id" binding:"required"`
	Status  string `json:"status"`
}

// RegistrationResponse represents registration data returned to clients.
type RegistrationResponse struct {
	ID        string    `json:"id"`
	EventID   string    `json:"event_id"`
	GuestID   string    `json:"guest_id"`
	Status    string    `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	CheckedIn bool      `json:"checked_in"`
}
