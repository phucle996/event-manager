package models

import (
	"event_manager/internal/domain/entity"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// LocationModel tương ứng với collection "locations"
type LocationModel struct {
	ID          primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Name        string             `bson:"name" json:"name"`
	Address     string             `bson:"address" json:"address"`
	Capacity    int                `bson:"capacity" json:"capacity"`
	Description string             `bson:"description" json:"description"`
}

// Convert Location entity → Mongo model
func LocationEntityToModel(e *entity.Location) *LocationModel {
	return &LocationModel{
		ID:          primitive.NewObjectID(),
		Name:        e.Name,
		Address:     e.Address,
		Capacity:    e.Capacity,
		Description: e.Description,
	}
}

// Convert Location model → domain entity
func LocationModelToEntity(m *LocationModel) *entity.Location {
	return &entity.Location{
		ID:          m.ID.Hex(),
		Name:        m.Name,
		Address:     m.Address,
		Capacity:    m.Capacity,
		Description: m.Description,
	}
}
