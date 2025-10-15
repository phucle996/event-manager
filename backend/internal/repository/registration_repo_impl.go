package repository_imple

import (
	"context"
	"errors"
	repository_interface "event_manager/internal/domain/repository"
	"event_manager/internal/models"
	"strings"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

// RegistrationRepoImpl là struct thao tác MongoDB
type RegistrationRepoImpl struct {
	col *mongo.Collection
}

// ✅ Hàm khởi tạo
func NewRegistrationMongoRepository(db *mongo.Database) repository_interface.RegistrationRepository {
	return &RegistrationRepoImpl{col: db.Collection("registrations")}
}

// ============================
// 🧩 Triển khai interface
// ============================

// Thêm mới đăng ký
func (r *RegistrationRepoImpl) Insert(ctx context.Context, m *models.RegistrationModel) error {
	if m.ID.IsZero() {
		m.ID = primitive.NewObjectID()
	}
	if m.CreatedAt.IsZero() {
		m.CreatedAt = time.Now()
	}
	_, err := r.col.InsertOne(ctx, m)
	return err
}

// Cập nhật đăng ký
func (r *RegistrationRepoImpl) Update(ctx context.Context, m *models.RegistrationModel) error {
	filter := bson.M{"_id": m.ID}
	setFields := bson.M{
		"status":     m.Status,
		"checked_in": m.CheckedIn,
	}
	if strings.TrimSpace(m.EventID) != "" {
		setFields["event_id"] = strings.TrimSpace(m.EventID)
	}
	if strings.TrimSpace(m.GuestID) != "" {
		setFields["guest_id"] = strings.TrimSpace(m.GuestID)
	}
	update := bson.M{"$set": setFields}
	_, err := r.col.UpdateOne(ctx, filter, update)
	return err
}

// Xoá đăng ký
func (r *RegistrationRepoImpl) Delete(ctx context.Context, id string) error {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	_, err = r.col.DeleteOne(ctx, bson.M{"_id": objID})
	return err
}

// Tìm đăng ký theo ID
func (r *RegistrationRepoImpl) FindByID(ctx context.Context, id string) (*models.RegistrationModel, error) {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	var result models.RegistrationModel
	err = r.col.FindOne(ctx, bson.M{"_id": objID}).Decode(&result)
	if err == mongo.ErrNoDocuments {
		return nil, nil
	}
	return &result, err
}

// Lấy danh sách đăng ký theo EventID
func (r *RegistrationRepoImpl) FindByEvent(ctx context.Context, eventID string) ([]*models.RegistrationModel, error) {
	cur, err := r.col.Find(ctx, bson.M{"event_id": eventID})
	if err != nil {
		return nil, err
	}
	defer cur.Close(ctx)

	var regs []*models.RegistrationModel
	for cur.Next(ctx) {
		var reg models.RegistrationModel
		if err := cur.Decode(&reg); err == nil {
			regs = append(regs, &reg)
		}
	}
	return regs, cur.Err()
}

// Lấy danh sách đăng ký theo GuestID
func (r *RegistrationRepoImpl) FindByGuest(ctx context.Context, guestID string) ([]*models.RegistrationModel, error) {
	guestID = strings.TrimSpace(guestID)
	if guestID == "" {
		return nil, errors.New("invalid guest id")
	}
	cur, err := r.col.Find(ctx, bson.M{"guest_id": guestID})
	if err != nil {
		return nil, err
	}
	defer cur.Close(ctx)

	var regs []*models.RegistrationModel
	for cur.Next(ctx) {
		var reg models.RegistrationModel
		if err := cur.Decode(&reg); err == nil {
			regs = append(regs, &reg)
		}
	}
	return regs, cur.Err()
}
