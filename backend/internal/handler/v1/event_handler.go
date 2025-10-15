package handler

import (
	"context"
	"event_manager/internal/domain/entity"
	service_interface "event_manager/internal/domain/service"
	requestx "event_manager/internal/dto/request"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// =========================================
// 🧩 EventHandler
// =========================================
type EventHandler struct {
	service service_interface.EventService
}

// ✅ Khởi tạo handler
func NewEventHandler(s service_interface.EventService) *EventHandler {
	return &EventHandler{service: s}
}

// =========================================
// ⚙️ API Handlers
// =========================================
// POST /events
func (h *EventHandler) CreateEvent(c *gin.Context) {
	var req requestx.EventCreateRequest

	// ⚠️ FE gửi multipart/form-data nên dùng ShouldBind, KHÔNG dùng ShouldBindJSON
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 🔹 Validate logic bổ sung
	if req.Type == "Sự kiện giới hạn" && req.MaxGuests < 2 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Sự kiện giới hạn phải có ít nhất 2 khách mời.",
		})
		return
	}

	// 🖼️ Nhận danh sách nhiều file ảnh
	form, err := c.MultipartForm()
	if err != nil && err != http.ErrNotMultipart {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Không thể đọc form dữ liệu"})
		return
	}

	imagePaths := []string{}
	if form != nil && form.File != nil {
		files := form.File["images"] // FE gửi dưới tên "images[]"
		for _, file := range files {
			filename := fmt.Sprintf("%d_%s", time.Now().UnixNano(), file.Filename)
			savePath := "./uploads/" + filename

			if err := c.SaveUploadedFile(file, savePath); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": fmt.Sprintf("Không thể lưu file %s: %v", file.Filename, err),
				})
				return
			}

			imagePaths = append(imagePaths, savePath)
		}
	}

	// 🧱 Tạo entity từ DTO
	event := &entity.Event{
		ID:          uuid.New().String(),
		Name:        req.Name,
		Description: req.Description,
		Type:        req.Type,
		Status:      "Sắp diễn ra",
		Location:    req.Location,
		MaxGuests:   req.MaxGuests,
		StartDate:   req.StartDate,
		EndDate:     req.EndDate,
		ImageURLs:   imagePaths, // 🖼️ Danh sách nhiều ảnh
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	// 💾 Gọi service lưu DB
	if err := h.service.Create(c, event); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Header("Content-Type", "application/json")
	c.JSON(http.StatusCreated, gin.H{
		"message": "Tạo sự kiện thành công",
	})
}

// PUT /events/:id
func (h *EventHandler) UpdateEvent(c *gin.Context) {
	id := c.Param("id")

	// ⚙️ Bước 1: Bind form dữ liệu (multipart/form-data)
	var req requestx.EventUpdateRequest
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// ⚙️ Bước 2: Validate logic
	if req.Type == "Sự kiện giới hạn" && req.MaxGuests < 2 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Sự kiện giới hạn phải có ít nhất 2 khách mời.",
		})
		return
	}

	// ⚙️ Bước 3: Nhận danh sách ảnh mới (nếu có)
	form, err := c.MultipartForm()
	if err != nil && err != http.ErrNotMultipart {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Không thể đọc form dữ liệu"})
		return
	}

	imagePaths := []string{}
	if form != nil && form.File != nil {
		files := form.File["images"] // FE gửi dưới key "images"
		for _, file := range files {
			filename := fmt.Sprintf("%d_%s", time.Now().UnixNano(), file.Filename)
			savePath := "./uploads/" + filename
			if err := c.SaveUploadedFile(file, savePath); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": fmt.Sprintf("Không thể lưu file %s: %v", file.Filename, err),
				})
				return
			}
			imagePaths = append(imagePaths, savePath)
		}
	}

	// ⚙️ Bước 4: Tạo entity để cập nhật
	event := &entity.Event{
		ID:          id,
		Name:        req.Name,
		Description: req.Description,
		Type:        req.Type,
		Status:      req.Status,
		Location:    req.Location,
		MaxGuests:   req.MaxGuests,
		ImageURLs:   imagePaths,
		UpdatedAt:   time.Now(),
	}
	// 👉 Chỉ cập nhật nếu client có truyền thời gian
	if req.StartDate != nil {
		event.StartDate = *req.StartDate
	}
	if req.EndDate != nil {
		event.EndDate = *req.EndDate
	}

	// ⚙️ Bước 5: Cập nhật trong service
	if err := h.service.Update(c, event); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// ⚙️ Bước 6: Trả về phản hồi
	c.JSON(http.StatusOK, gin.H{
		"message": "✅ Cập nhật sự kiện thành công",
	})
}

// DELETE /events/:id
func (h *EventHandler) DeleteEvent(c *gin.Context) {
	id := c.Param("id")
	if err := h.service.Delete(c, id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Đã xoá sự kiện"})
}

// GET /events/:id
func (h *EventHandler) GetEventByID(c *gin.Context) {
	id := c.Param("id")

	event, err := h.service.GetByID(c, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if event == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Không tìm thấy sự kiện"})
		return
	}

	// ✅ Map trực tiếp sang DTO
	resp := requestx.EventDetailResponse{
		ID:          event.ID,
		Name:        event.Name,
		Description: event.Description,
		Type:        event.Type,
		Status:      event.Status,
		Location:    event.Location,
		MaxGuests:   int(event.MaxGuests),
		StartDate:   event.StartDate,
		EndDate:     event.EndDate,
		ImageURLs:   event.ImageURLs,
	}

	c.JSON(http.StatusOK, gin.H{
		"data": resp,
	})
}

// GET /events?status=Sắp diễn ra&from=2025-10-01&to=2025-12-31
func (h *EventHandler) ListEvents(c *gin.Context) {
	status := c.Query("status")
	fromStr := c.Query("from")
	toStr := c.Query("to")

	var from, to time.Time
	var err error
	if fromStr != "" {
		from, err = time.Parse("2006-01-02", fromStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Ngày 'from' không hợp lệ"})
			return
		}
	}
	if toStr != "" {
		to, err = time.Parse("2006-01-02", toStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Ngày 'to' không hợp lệ"})
			return
		}
	}

	// 🔹 Gọi service để lấy danh sách entity (đầy đủ)
	events, err := h.service.List(c, status, from, to)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 🔹 Map sang DTO
	res := make([]requestx.EventResponse, 0, len(events))
	for _, e := range events {
		res = append(res, requestx.EventResponse{
			ID:        e.ID,
			Name:      e.Name,
			Status:    e.Status,
			StartDate: e.StartDate,
			EndDate:   e.EndDate,
			Location:  e.Location,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": res})
}

// PATCH /events/auto-update
func (h *EventHandler) AutoUpdateStatus(c *gin.Context) {
	if err := h.service.AutoUpdateStatus(context.Background()); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Đã cập nhật trạng thái tự động"})
}

// GET /events/:id/statistics
func (h *EventHandler) GetStatistics(c *gin.Context) {
	eventID := c.Param("id")
	stat, err := h.service.ComputeStatistics(c, eventID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, stat)
}
