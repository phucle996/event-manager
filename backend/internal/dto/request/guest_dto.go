package dto

// GuestCreateRequest carries payload to create a guest.
type GuestCreateRequest struct {
	EventID  string `json:"event_id" binding:"required"`
	FullName string `json:"full_name" binding:"required"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
}

// GuestUpdateRequest carries payload to update a guest.
type GuestUpdateRequest struct {
	EventID  string `json:"event_id"`
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
}

// GuestResponse represents guest data returned to clients.
type GuestResponse struct {
	ID       string `json:"id"`
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
}
