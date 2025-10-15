package repository_imple

import (
	"context"
	"errors"
	repository_interface "event_manager/internal/domain/repository"
	"event_manager/internal/models"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	mongooptions "go.mongodb.org/mongo-driver/mongo/options"
)

// EventRepoImpl implements EventRepository
type EventRepoImpl struct {
	col *mongo.Collection
}

// ✅ Khởi tạo repository Mongo
func NewEventMongoRepository(db *mongo.Database) repository_interface.EventRepository {
	return &EventRepoImpl{col: db.Collection("events")}
}

// =======================================
// 🧩 Implement các phương thức interface
// =======================================

// 🟢 Insert — thêm mới sự kiện
func (r *EventRepoImpl) Insert(ctx context.Context, m *models.EventModel) error {
	if m == nil {
		return errors.New("model is nil")
	}

	if m.ID == "" {
		m.ID = primitive.NewObjectID().Hex()
	}

	m.Status = getStatusByTime(m.StartDate, m.EndDate)
	m.CreatedAt = time.Now()
	m.UpdatedAt = time.Now()

	_, err := r.col.InsertOne(ctx, m)
	return err
}

// 🟡 Update — cập nhật sự kiện
func (r *EventRepoImpl) Update(ctx context.Context, m *models.EventModel) error {
	if m.ID == "" {
		return errors.New("missing event ID")
	}

	filter := bson.M{"_id": m.ID}
	update := bson.M{
		"$set": bson.M{
			"name":        m.Name,
			"description": m.Description,
			"type":        m.Type,
			"status":      getStatusByTime(m.StartDate, m.EndDate),
			"location":    m.Location,
			"max_guests":  m.MaxGuests,
			"start_date":  m.StartDate,
			"end_date":    m.EndDate,
			"image_urls":  m.ImageURLs,
			"updated_at":  time.Now(),
		},
	}

	_, err := r.col.UpdateOne(ctx, filter, update)
	return err
}

// 🔴 Delete — xoá sự kiện
func (r *EventRepoImpl) Delete(ctx context.Context, id string) error {
	if id == "" {
		return errors.New("missing event ID")
	}
	_, err := r.col.DeleteOne(ctx, bson.M{"_id": id})
	return err
}

// 🔍 FindByID — lấy sự kiện theo ID
func (r *EventRepoImpl) FindByID(ctx context.Context, id string) (*models.EventModel, error) {
	var m models.EventModel
	err := r.col.FindOne(ctx, bson.M{"_id": id}).Decode(&m)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}

	m.Status = getStatusByTime(m.StartDate, m.EndDate)
	return &m, nil
}

// 📋 FindAll — lấy tất cả sự kiện
func (r *EventRepoImpl) FindAll(ctx context.Context) ([]*models.EventModel, error) {
	cursor, err := r.col.Find(ctx, bson.D{{}})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var events []*models.EventModel
	if err := cursor.All(ctx, &events); err != nil {
		return nil, err
	}

	for _, e := range events {
		e.Status = getStatusByTime(e.StartDate, e.EndDate)
	}
	return events, nil
}

// ⏳ FindUpcoming — các sự kiện sắp diễn ra
func (r *EventRepoImpl) FindUpcoming(ctx context.Context) ([]*models.EventModel, error) {
	filter := bson.M{"start_date": bson.M{"$gte": time.Now()}}
	opts := mongooptions.Find().SetSort(bson.D{{Key: "start_date", Value: 1}})

	cursor, err := r.col.Find(ctx, filter, opts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var events []*models.EventModel
	if err := cursor.All(ctx, &events); err != nil {
		return nil, err
	}

	for _, e := range events {
		e.Status = getStatusByTime(e.StartDate, e.EndDate)
	}
	return events, nil
}

// =======================================
// ⚙️ Helper functions
// =======================================

// Xác định trạng thái dựa theo StartDate và EndDate
func getStatusByTime(start, end time.Time) string {
	now := time.Now()
	switch {
	case now.Before(start):
		return "Sắp diễn ra"
	case now.After(end):
		return "Đã kết thúc"
	default:
		return "Đang diễn ra"
	}
}
