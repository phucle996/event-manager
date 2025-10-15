package repository_imple

import (
	"context"
	"errors"
	repository_interface "event_manager/internal/domain/repository"
	"event_manager/internal/models"
	"fmt"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// 🧩 UserMongoRepository triển khai interface UserRepository
type UserMongoRepository struct {
	col *mongo.Collection
}

// ✅ Constructor
func NewUserMongoRepository(db *mongo.Database) repository_interface.UserRepository {
	return &UserMongoRepository{
		col: db.Collection("users"),
	}
}

// ➕ Thêm mới user
func (r *UserMongoRepository) Insert(ctx context.Context, user *models.UserModel) error {
	if user == nil {
		return errors.New("user is nil")
	}
	_, err := r.col.InsertOne(ctx, user)
	return err
}

// ✏️ Cập nhật user theo ID
func (r *UserMongoRepository) Update(ctx context.Context, user *models.UserModel) error {
	if user == nil {
		return errors.New("user is nil")
	}
	if user.ID.IsZero() {
		return errors.New("missing user ID")
	}

	filter := bson.M{"_id": user.ID}
	update := bson.M{
		"$set": bson.M{
			"username":   user.Username,
			"email":      user.Email,
			"full_name":  user.FullName,
			"status":     user.Status,
			"role":       user.Role,
			"updated_at": user.UpdatedAt,
		},
	}

	res, err := r.col.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return fmt.Errorf("user not found with id: %s", user.ID.Hex())
	}
	return nil
}

// ❌ Xoá user theo ID
func (r *UserMongoRepository) Delete(ctx context.Context, id string) error {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return fmt.Errorf("invalid id: %v", err)
	}
	res, err := r.col.DeleteOne(ctx, bson.M{"_id": objID})
	if err != nil {
		return err
	}
	if res.DeletedCount == 0 {
		return fmt.Errorf("user not found with id: %s", id)
	}
	return nil
}

// 🔍 Tìm user theo ID
func (r *UserMongoRepository) FindByID(ctx context.Context, id string) (*models.UserModel, error) {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return nil, fmt.Errorf("invalid id: %v", err)
	}

	var m models.UserModel
	err = r.col.FindOne(ctx, bson.M{"_id": objID}).Decode(&m)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &m, nil
}

// 🔍 Tìm user theo username
func (r *UserMongoRepository) FindByUsername(ctx context.Context, username string) (*models.UserModel, error) {
	var m models.UserModel
	err := r.col.FindOne(ctx, bson.M{"username": username}).Decode(&m)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &m, nil
}

// 📋 Liệt kê danh sách user
func (r *UserMongoRepository) List(ctx context.Context, limit, offset int) ([]*models.UserModel, error) {
	opts := options.Find()
	if limit > 0 {
		opts.SetLimit(int64(limit))
	}
	if offset > 0 {
		opts.SetSkip(int64(offset))
	}

	cursor, err := r.col.Find(ctx, bson.M{}, opts)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var users []*models.UserModel
	for cursor.Next(ctx) {
		var u models.UserModel
		if err := cursor.Decode(&u); err != nil {
			return nil, err
		}
		users = append(users, &u)
	}

	if err := cursor.Err(); err != nil {
		return nil, err
	}
	return users, nil
}
