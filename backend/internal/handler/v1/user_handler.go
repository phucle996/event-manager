package handler

import (
	"context"
	service_interface "event_manager/internal/domain/service"
	dto "event_manager/internal/dto/request"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// 🧩 UserHandler cấu trúc chính của HTTP handler
type UserHandler struct {
	svc service_interface.UserService
}

// ✅ Constructor
func NewUserHandler(svc service_interface.UserService) *UserHandler {
	return &UserHandler{svc: svc}
}

// =======================================================
// 🧩 HANDLERS
// =======================================================

// 🟢 CreateUser
func (h *UserHandler) CreateUser(c *gin.Context) {
	var req *dto.CreateUserRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	if err := h.svc.CreateUser(ctx, req.Username, req.Email, req.FullName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "user created successfully"})
}

// 🟠 UpdateProfile
func (h *UserHandler) UpdateProfile(c *gin.Context) {
	id := c.Param("id")
	var req *dto.UpdateUserRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	if err := h.svc.UpdateProfile(ctx, id, req.FullName, req.Email); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user updated successfully"})
}

// 🔴 DeactivateUser
func (h *UserHandler) DeactivateUser(c *gin.Context) {
	id := c.Param("id")

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	if err := h.svc.DeactivateUser(ctx, id); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user deactivated"})
}

// 🟢 ActivateUser
func (h *UserHandler) ActivateUser(c *gin.Context) {
	id := c.Param("id")

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	if err := h.svc.ActivateUser(ctx, id); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user activated"})
}

// 🔍 GetUserByID
func (h *UserHandler) GetUserByID(c *gin.Context) {
	id := c.Param("id")

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	user, err := h.svc.GetUserByID(ctx, id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	resp := &dto.UserResponse{
		ID:        user.ID,
		Username:  user.Username,
		Email:     user.Email,
		FullName:  user.FullName,
		Status:    user.Status,
		Role:      user.Role,
		CreatedAt: user.CreatedAt,
		UpdatedAt: user.UpdatedAt,
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}

// 📋 ListUsers
func (h *UserHandler) ListUsers(c *gin.Context) {
	// Lấy query param limit và offset
	limitStr := c.DefaultQuery("limit", "10")
	offsetStr := c.DefaultQuery("offset", "0")

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid limit"})
		return
	}
	offset, err := strconv.Atoi(offsetStr)
	if err != nil || offset < 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid offset"})
		return
	}

	// Tạo context timeout 5 giây
	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	// Gọi service lấy danh sách users (entity)
	users, err := h.svc.ListUsers(ctx, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 🧩 Map thủ công từ entity → DTO
	var userDTOs []map[string]interface{}
	for _, u := range users {
		userDTOs = append(userDTOs, map[string]interface{}{
			"id":         u.ID,
			"username":   u.Username,
			"email":      u.Email,
			"full_name":  u.FullName,
			"status":     u.Status,
			"role":       u.Role,
			"created_at": u.CreatedAt,
			"updated_at": u.UpdatedAt,
		})
	}

	// 📤 Trả về JSON response chuẩn REST
	c.JSON(http.StatusOK, gin.H{
		"limit":  limit,
		"offset": offset,
		"count":  len(userDTOs),
		"data":   userDTOs,
	})
}
