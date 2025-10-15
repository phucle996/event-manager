package entity

import "time"

// Event đại diện cho một sự kiện trong hệ thống
type Event struct {
	ID          string    // UUID hoặc ObjectID
	Name        string    // Tên sự kiện
	Description string    // Mô tả chi tiết sự kiện
	Type        string    // Loại sự kiện: "Sự kiện mở" | "Sự kiện giới hạn" | "Sự kiện riêng tư"
	Status      string    // "Sắp diễn ra" | "Đang diễn ra" | "Đã kết thúc"
	Location    string    // Địa điểm tổ chức (thay vì LocationID cho dễ hiển thị)
	MaxGuests   uint      // Giới hạn khách (0 nếu là sự kiện mở)
	StartDate   time.Time // Thời gian bắt đầu
	EndDate     time.Time // Thời gian kết thúc
	ImageURLs   []string  // Đường dẫn ảnh nơi tổ chức (nếu có)
	CreatedAt   time.Time // Ngày tạo sự kiện
	UpdatedAt   time.Time // Ngày cập nhật cuối cùng
}
