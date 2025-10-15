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

// RegistrationHandler exposes registration HTTP endpoints.
type RegistrationHandler struct {
	svc service_interface.RegistrationService
}

// NewRegistrationHandler constructs a registration handler.
func NewRegistrationHandler(svc service_interface.RegistrationService) *RegistrationHandler {
	return &RegistrationHandler{svc: svc}
}

// Register handles POST /registrations.
func (h *RegistrationHandler) Register(c *gin.Context) {
	var req dto.RegistrationCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	reg := &entity.Registration{
		EventID:   strings.TrimSpace(req.EventID),
		GuestID:   strings.TrimSpace(req.GuestID),
		Status:    strings.TrimSpace(req.Status),
		CreatedAt: time.Now(),
	}

	if err := h.svc.Register(ctx, reg); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.RegistrationResponse{
		ID:        reg.ID,
		EventID:   reg.EventID,
		GuestID:   reg.GuestID,
		Status:    reg.Status,
		CreatedAt: reg.CreatedAt,
		CheckedIn: reg.CheckedIn,
	}

	c.JSON(http.StatusCreated, gin.H{"data": resp})
}

// CheckIn handles PUT /registrations/:id/check-in.
func (h *RegistrationHandler) CheckIn(c *gin.Context) {
	id := c.Param("id")
	if strings.TrimSpace(id) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "registration id is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	reg, err := h.svc.CheckIn(ctx, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.RegistrationResponse{
		ID:        reg.ID,
		EventID:   reg.EventID,
		GuestID:   reg.GuestID,
		Status:    reg.Status,
		CreatedAt: reg.CreatedAt,
		CheckedIn: reg.CheckedIn,
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}

// Cancel handles PUT /registrations/:id/cancel.
func (h *RegistrationHandler) Cancel(c *gin.Context) {
	id := c.Param("id")
	if strings.TrimSpace(id) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "registration id is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	reg, err := h.svc.Cancel(ctx, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.RegistrationResponse{
		ID:        reg.ID,
		EventID:   reg.EventID,
		GuestID:   reg.GuestID,
		Status:    reg.Status,
		CreatedAt: reg.CreatedAt,
		CheckedIn: reg.CheckedIn,
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}

// GetByID handles GET /registrations/:id.
func (h *RegistrationHandler) GetByID(c *gin.Context) {
	id := c.Param("id")
	if strings.TrimSpace(id) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "registration id is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	reg, err := h.svc.GetByID(ctx, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if reg == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "registration not found"})
		return
	}

	resp := dto.RegistrationResponse{
		ID:        reg.ID,
		EventID:   reg.EventID,
		GuestID:   reg.GuestID,
		Status:    reg.Status,
		CreatedAt: reg.CreatedAt,
		CheckedIn: reg.CheckedIn,
	}

	c.JSON(http.StatusOK, gin.H{"data": resp})
}

// List handles GET /registrations.
// Clients must provide either event_id or guest_id.
func (h *RegistrationHandler) List(c *gin.Context) {
	eventID := strings.TrimSpace(c.Query("event_id"))
	guestID := strings.TrimSpace(c.Query("guest_id"))

	if eventID == "" && guestID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "event_id or guest_id is required"})
		return
	}
	if eventID != "" && guestID != "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "only one of event_id or guest_id can be provided"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	var (
		registrations []*entity.Registration
		err           error
	)

	if eventID != "" {
		registrations, err = h.svc.ListByEvent(ctx, eventID)
	} else {
		registrations, err = h.svc.ListByGuest(ctx, guestID)
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	responses := make([]dto.RegistrationResponse, 0, len(registrations))
	for _, reg := range registrations {
		if reg == nil {
			continue
		}
		responses = append(responses, dto.RegistrationResponse{
			ID:        reg.ID,
			EventID:   reg.EventID,
			GuestID:   reg.GuestID,
			Status:    reg.Status,
			CreatedAt: reg.CreatedAt,
			CheckedIn: reg.CheckedIn,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": responses})
}
