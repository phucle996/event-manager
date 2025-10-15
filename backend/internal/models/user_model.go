package models

import (
	"event_manager/internal/domain/entity"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// 🧩 UserModel cho MongoDB
type UserModel struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id,omitempty"`
	Username  string             `bson:"username" json:"username"`
	Email     string             `bson:"email" json:"email"`
	FullName  string             `bson:"full_name" json:"full_name"`
	Status    string             `bson:"status" json:"status"`
	Role      string             `bson:"role" json:"role"`
	CreatedAt time.Time          `bson:"created_at" json:"created_at"`
	UpdatedAt time.Time          `bson:"updated_at" json:"updated_at"`
}

// 🧭 Map từ Entity → Model
func (u *UserModel) UserEntityToModel(e *entity.User) *UserModel {
	return &UserModel{
		ID:        primitive.NewObjectID(),
		Username:  e.Username,
		Email:     e.Email,
		FullName:  e.FullName,
		Status:    e.Status,
		Role:      e.Role,
		CreatedAt: e.CreatedAt,
		UpdatedAt: e.UpdatedAt,
	}
}

// 🔁 Map từ Model → Entity
func (u *UserModel) UserModelToEntity() *entity.User {
	return &entity.User{
		ID:        u.ID.Hex(),
		Username:  u.Username,
		Email:     u.Email,
		FullName:  u.FullName,
		Status:    u.Status,
		Role:      u.Role,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
	}
}
