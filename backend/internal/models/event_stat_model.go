package models

import (
	"event_manager/internal/domain/entity"
)

// EventStatModel đại diện dữ liệu lưu trong MongoDB / SQL
// Có thể thêm tag JSON / BSON nếu cần (ở data layer)
type EventStatModel struct {
	EventID     string `bson:"event_id" json:"event_id"`
	TotalGuests int    `bson:"total_guests" json:"total_guests"`
	CheckedIn   int    `bson:"checked_in" json:"checked_in"`
	Absent      int    `bson:"absent" json:"absent"`
}

// Convert entity → model
func EventStatEntityToModel(e *entity.EventStat) *EventStatModel {
	if e == nil {
		return nil
	}

	return &EventStatModel{
		EventID:     e.EventID,
		TotalGuests: e.TotalGuests,
		CheckedIn:   e.CheckedIn,
		Absent:      e.Absent,
	}
}

// Convert model → entity
func EventStatModelToEntity(m *EventStatModel) *entity.EventStat {
	if m == nil {
		return nil
	}

	return &entity.EventStat{
		EventID:     m.EventID,
		TotalGuests: m.TotalGuests,
		CheckedIn:   m.CheckedIn,
		Absent:      m.Absent,
	}
}
