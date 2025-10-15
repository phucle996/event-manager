package models

import (
	"errors"
	"strings"
	"time"

	"event_manager/internal/domain/entity"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// RegistrationModel represents the MongoDB document for a registration.
type RegistrationModel struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	EventID   string             `bson:"event_id" json:"event_id"`
	GuestID   string             `bson:"guest_id" json:"guest_id"`
	Status    string             `bson:"status" json:"status"`
	CreatedAt time.Time          `bson:"created_at" json:"created_at"`
	CheckedIn bool               `bson:"checked_in" json:"checked_in"`
}

// RegistrationEntityToModel converts a domain registration into its persistence model.
func RegistrationEntityToModel(e *entity.Registration) (*RegistrationModel, error) {
	eventID := strings.TrimSpace(e.EventID)
	if eventID == "" {
		return nil, errors.New("event id is required")
	}

	guestID := strings.TrimSpace(e.GuestID)
	if guestID == "" {
		return nil, errors.New("guest id is required")
	}

	var id primitive.ObjectID
	if e.ID != "" {
		id, _ = primitive.ObjectIDFromHex(e.ID)
	}

	return &RegistrationModel{
		ID:        id,
		EventID:   eventID,
		GuestID:   guestID,
		Status:    e.Status,
		CreatedAt: e.CreatedAt,
		CheckedIn: e.CheckedIn,
	}, nil
}

// RegistrationModelToEntity converts a MongoDB registration document into the domain entity.
func (m *RegistrationModel) RegistrationModelToEntity() *entity.Registration {
	return &entity.Registration{
		ID:        m.ID.Hex(),
		EventID:   strings.TrimSpace(m.EventID),
		GuestID:   strings.TrimSpace(m.GuestID),
		Status:    m.Status,
		CreatedAt: m.CreatedAt,
		CheckedIn: m.CheckedIn,
	}
}
