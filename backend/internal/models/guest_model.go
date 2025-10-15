package models

import (
	"strings"

	"event_manager/internal/domain/entity"

	"github.com/google/uuid"
)

// GuestModel maps the guest entity to the MongoDB "guests" collection.
type GuestModel struct {
	ID       string `bson:"_id" json:"id"`
	FullName string `bson:"full_name" json:"full_name"`
	Email    string `bson:"email" json:"email"`
	Phone    string `bson:"phone" json:"phone"`
}

// GuestEntityToModel converts a domain guest entity into its persistence model.
func GuestEntityToModel(e *entity.Guest) *GuestModel {
	id := strings.TrimSpace(e.ID)
	if id == "" {
		id = uuid.NewString()
	}

	return &GuestModel{
		ID:       id,
		FullName: e.FullName,
		Email:    e.Email,
		Phone:    e.Phone,
	}
}

// GuestModelToEntity converts a MongoDB guest document into the domain entity.
func GuestModelToEntity(m *GuestModel) *entity.Guest {
	if m == nil {
		return nil
	}

	return &entity.Guest{
		ID:       strings.TrimSpace(m.ID),
		FullName: m.FullName,
		Email:    m.Email,
		Phone:    m.Phone,
	}
}
