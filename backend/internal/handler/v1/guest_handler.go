package handler

import (
	"context"
	"net/http"
	"strings"
	"time"

	"event_manager/internal/domain/entity"
	service_interface "event_manager/internal/domain/service"
	dto "event_manager/internal/dto/request"

	"github.com/gin-gonic/gin"
)

// GuestHandler exposes guest-related HTTP endpoints.
type GuestHandler struct {
	svc service_interface.GuestService
}

// NewGuestHandler constructs a guest handler.
func NewGuestHandler(svc service_interface.GuestService) *GuestHandler {
	return &GuestHandler{svc: svc}
}

// CreateGuest handles POST /guests.
func (h *GuestHandler) CreateGuest(c *gin.Context) {
	var req dto.GuestCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	eventID := strings.TrimSpace(req.EventID)
	req.Email = strings.TrimSpace(req.Email)
	req.Phone = strings.TrimSpace(req.Phone)

	if eventID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "event_id is required"})
		return
	}
	if req.Email == "" && req.Phone == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "email or phone is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	guest := &entity.Guest{
		FullName: strings.TrimSpace(req.FullName),
		Email:    req.Email,
		Phone:    req.Phone,
	}

	if err := h.svc.Create(ctx, guest, eventID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.GuestResponse{
		ID:       guest.ID,
		FullName: guest.FullName,
		Email:    guest.Email,
		Phone:    guest.Phone,
	}

	c.JSON(http.StatusCreated, gin.H{"data": resp})
}

// UpdateGuest handles PUT /guests/:id.
func (h *GuestHandler) UpdateGuest(c *gin.Context) {
	id := c.Param("id")
	if strings.TrimSpace(id) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "guest id is required"})
		return
	}

	var req dto.GuestUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	eventID := strings.TrimSpace(req.EventID)
	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	guest := &entity.Guest{
		ID:       id,
		FullName: strings.TrimSpace(req.FullName),
		Email:    strings.TrimSpace(req.Email),
		Phone:    strings.TrimSpace(req.Phone),
	}

	if err := h.svc.Update(ctx, guest, eventID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "guest updated successfully"})
}

// DeleteGuest handles DELETE /guests/:id.
func (h *GuestHandler) DeleteGuest(c *gin.Context) {
	id := c.Param("id")
	if strings.TrimSpace(id) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "guest id is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	if err := h.svc.Delete(ctx, id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "guest deleted successfully"})
}

// GetGuestByID handles GET /guests/:id.
func (h *GuestHandler) GetGuestByID(c *gin.Context) {
	id := c.Param("id")
	if strings.TrimSpace(id) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "guest id is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	guest, err := h.svc.GetByID(ctx, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if guest == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "guest not found"})
		return
	}

	resp := dto.GuestResponse{
		ID:       guest.ID,
		FullName: guest.FullName,
		Email:    guest.Email,
		Phone:    guest.Phone,
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}

// ListGuests handles GET /guests.
func (h *GuestHandler) ListGuests(c *gin.Context) {
	keyword := c.Query("keyword")

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	guests, err := h.svc.List(ctx, keyword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	responses := make([]dto.GuestResponse, 0, len(guests))
	for _, g := range guests {
		if g == nil {
			continue
		}
		responses = append(responses, dto.GuestResponse{
			ID:       g.ID,
			FullName: g.FullName,
			Email:    g.Email,
			Phone:    g.Phone,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": responses})
}

// FindGuestByContact handles GET /guests/search?email=&phone=.
func (h *GuestHandler) FindGuestByContact(c *gin.Context) {
	email := strings.TrimSpace(c.Query("email"))
	phone := strings.TrimSpace(c.Query("phone"))

	if email == "" && phone == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "email or phone is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	guest, err := h.svc.FindByContact(ctx, email, phone)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if guest == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "guest not found"})
		return
	}

	resp := dto.GuestResponse{
		ID:       guest.ID,
		FullName: guest.FullName,
		Email:    guest.Email,
		Phone:    guest.Phone,
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}
