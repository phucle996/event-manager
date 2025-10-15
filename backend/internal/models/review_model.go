package models

import (
	"strings"
	"time"

	"event_manager/internal/domain/entity"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// MongoDB model cho Review
type ReviewModel struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	EventID   primitive.ObjectID `bson:"event_id" json:"event_id"`
	GuestID   string             `bson:"guest_id" json:"guest_id"`
	Rating    float64            `bson:"rating" json:"rating"`
	Comment   string             `bson:"comment" json:"comment"`
	CreatedAt time.Time          `bson:"created_at" json:"created_at"`
}

// Convert từ entity -> model
func ReviewEntityToModel(e *entity.Review) (*ReviewModel, error) {
	eventOID, err := primitive.ObjectIDFromHex(e.EventID)
	if err != nil {
		return nil, err
	}

	return &ReviewModel{
		EventID:   eventOID,
		GuestID:   strings.TrimSpace(e.GuestID),
		Rating:    e.Rating,
		Comment:   e.Comment,
		CreatedAt: e.CreatedAt,
	}, nil
}

// Convert từ model -> entity
func (m *ReviewModel) ReviewModelToEntity() *entity.Review {
	return &entity.Review{
		ID:        m.ID.Hex(),
		EventID:   m.EventID.Hex(),
		GuestID:   strings.TrimSpace(m.GuestID),
		Rating:    m.Rating,
		Comment:   m.Comment,
		CreatedAt: m.CreatedAt,
	}
}
