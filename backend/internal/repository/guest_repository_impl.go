package repository_imple

import (
	"context"
	"errors"
	"strings"

	models "event_manager/internal/models"

	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

// GuestRepositoryImpl implements GuestRepository interface
type GuestRepositoryImpl struct {
	col *mongo.Collection
}

// NewGuestRepository khởi tạo repository với collection "guests"
func NewGuestRepository(db *mongo.Database) *GuestRepositoryImpl {
	return &GuestRepositoryImpl{
		col: db.Collection("guests"),
	}
}

// Insert thêm khách mời mới
func (r *GuestRepositoryImpl) Insert(ctx context.Context, m *models.GuestModel) error {
	if m == nil {
		return errors.New("guest model is nil")
	}
	if strings.TrimSpace(m.ID) == "" {
		m.ID = uuid.NewString()
	}
	_, err := r.col.InsertOne(ctx, m)
	return err
}

// Update thông tin khách mời (theo ID)
func (r *GuestRepositoryImpl) Update(ctx context.Context, m *models.GuestModel) error {
	if m == nil {
		return errors.New("guest model is nil")
	}
	if strings.TrimSpace(m.ID) == "" {
		return errors.New("missing guest ID")
	}

	update := bson.M{
		"$set": bson.M{
			"full_name": m.FullName,
			"email":     m.Email,
			"phone":     m.Phone,
		},
	}

	filter := bson.M{"_id": m.ID}
	_, err := r.col.UpdateOne(ctx, filter, update)
	return err
}

// Delete khách mời theo ID
func (r *GuestRepositoryImpl) Delete(ctx context.Context, id string) error {
	if strings.TrimSpace(id) == "" {
		return errors.New("invalid guest id")
	}
	_, err := r.col.DeleteOne(ctx, bson.M{"_id": id})
	return err
}

// FindByID tìm khách mời theo ID
func (r *GuestRepositoryImpl) FindByID(ctx context.Context, id string) (*models.GuestModel, error) {
	if strings.TrimSpace(id) == "" {
		return nil, errors.New("invalid guest id")
	}

	var result models.GuestModel
	err := r.col.FindOne(ctx, bson.M{"_id": id}).Decode(&result)
	if err == mongo.ErrNoDocuments {
		return nil, nil
	}
	return &result, err
}

// FindByEmail tìm khách mời theo email
func (r *GuestRepositoryImpl) FindByEmail(ctx context.Context, email string) (*models.GuestModel, error) {
	var result models.GuestModel
	err := r.col.FindOne(ctx, bson.M{"email": email}).Decode(&result)
	if err == mongo.ErrNoDocuments {
		return nil, nil
	}
	return &result, err
}

// FindAll lấy tất cả khách mời
func (r *GuestRepositoryImpl) FindAll(ctx context.Context) ([]*models.GuestModel, error) {
	cur, err := r.col.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cur.Close(ctx)

	var guests []*models.GuestModel
	for cur.Next(ctx) {
		var g models.GuestModel
		if err := cur.Decode(&g); err != nil {
			return nil, err
		}
		guests = append(guests, &g)
	}
	return guests, cur.Err()
}
