package dto

import (
	"time"
)

//
// =======================================================
// 🟢 REQUEST DTOs
// =======================================================
//

// 📥 Dùng khi tạo user mới
type CreateUserRequest struct {
	Username string `json:"username" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	FullName string `json:"full_name" binding:"required"`
}

// 📥 Dùng khi cập nhật thông tin user
type UpdateUserRequest struct {
	FullName string `json:"full_name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
}

//
// =======================================================
// 🟣 RESPONSE DTOs
// =======================================================
//

// 📤 Dùng cho phản hồi chi tiết user
type UserResponse struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	FullName  string    `json:"full_name"`
	Status    string    `json:"status"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// 📤 Dùng cho danh sách user
type UserListResponse struct {
	Data  []*UserResponse `json:"data"`
	Total int             `json:"total"`
}
