package handler

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	service_interface "event_manager/internal/domain/service"

	"github.com/gin-gonic/gin"
)

// AnalyticsHandler exposes aggregated reporting endpoints.
type AnalyticsHandler struct {
	aggregateSvc service_interface.AggregateService
}

// NewAnalyticsHandler constructs an analytics handler.
func NewAnalyticsHandler(aggregateSvc service_interface.AggregateService) *AnalyticsHandler {
	return &AnalyticsHandler{aggregateSvc: aggregateSvc}
}

// GetGuestCountByEvent returns total guests registered for an event.
func (h *AnalyticsHandler) GetGuestCountByEvent(c *gin.Context) {
	eventID := c.Param("id")
	if strings.TrimSpace(eventID) == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "event id is required"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	count, err := h.aggregateSvc.CountGuestsByEvent(ctx, eventID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := gin.H{
		"event_id":     eventID,
		"total_guests": count,
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

// GetGuestStatsByEvent returns guest counts grouped by event.
func (h *AnalyticsHandler) GetGuestStatsByEvent(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	stats, err := h.aggregateSvc.GuestStatsByEvent(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := make([]gin.H, 0, len(stats))
	for _, stat := range stats {
		if stat == nil {
			continue
		}
		response = append(response, gin.H{
			"event_id":     stat.EventID,
			"event_name":   stat.EventName,
			"location":     stat.Location,
			"total_guests": stat.TotalGuests,
			"checked_in":   stat.CheckedIn,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

// GetGuestStatsByEventType returns guest counts grouped by event type.
func (h *AnalyticsHandler) GetGuestStatsByEventType(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	stats, err := h.aggregateSvc.GuestStatsByEventType(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := make([]gin.H, 0, len(stats))
	for _, stat := range stats {
		if stat == nil {
			continue
		}
		response = append(response, gin.H{
			"event_type":   stat.EventType,
			"total_guests": stat.TotalGuests,
			"checked_in":   stat.CheckedIn,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

// GetGuestStatsByLocation returns guest counts grouped by location.
func (h *AnalyticsHandler) GetGuestStatsByLocation(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	stats, err := h.aggregateSvc.GuestStatsByLocation(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := make([]gin.H, 0, len(stats))
	for _, stat := range stats {
		if stat == nil {
			continue
		}
		response = append(response, gin.H{
			"location":     stat.Location,
			"total_guests": stat.TotalGuests,
			"checked_in":   stat.CheckedIn,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

// GetParticipationTrend returns registration trend grouped by granularity.
func (h *AnalyticsHandler) GetParticipationTrend(c *gin.Context) {
	fromStr := c.Query("from")
	toStr := c.Query("to")
	granularity := c.DefaultQuery("granularity", "day")

	from, err := parseTime(fromStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("invalid from: %v", err)})
		return
	}
	to, err := parseTime(toStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("invalid to: %v", err)})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	trend, err := h.aggregateSvc.ParticipationTrend(ctx, from, to, granularity)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := make([]gin.H, 0, len(trend))
	for _, point := range trend {
		if point == nil {
			continue
		}
		response = append(response, gin.H{
			"period":       point.Period,
			"total_guests": point.TotalGuests,
			"checked_in":   point.CheckedIn,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"granularity": granularity,
		"data":        response,
	})
}

// GetTopEventsByGuests returns top events with most guests.
func (h *AnalyticsHandler) GetTopEventsByGuests(c *gin.Context) {
	limitStr := c.DefaultQuery("limit", "3")
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "limit must be a non-negative integer"})
		return
	}

	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	stats, err := h.aggregateSvc.TopEventsByGuestCount(ctx, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	response := make([]gin.H, 0, len(stats))
	for _, stat := range stats {
		if stat == nil {
			continue
		}
		response = append(response, gin.H{
			"event_id":     stat.EventID,
			"event_name":   stat.EventName,
			"location":     stat.Location,
			"total_guests": stat.TotalGuests,
			"checked_in":   stat.CheckedIn,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"limit": limit,
		"data":  response,
	})
}

func parseTime(value string) (time.Time, error) {
	if strings.TrimSpace(value) == "" {
		return time.Time{}, nil
	}

	layouts := []string{
		time.RFC3339,
		"2006-01-02",
		"2006-01-02 15:04:05",
	}

	for _, layout := range layouts {
		if t, err := time.Parse(layout, value); err == nil {
			return t, nil
		}
	}
	return time.Time{}, fmt.Errorf("unsupported time format")
}
