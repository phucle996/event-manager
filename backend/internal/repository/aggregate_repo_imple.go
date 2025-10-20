package repository_imple

import (
	"context"
	"errors"
	repository_interface "event_manager/internal/domain/repository"
	"event_manager/internal/models"
	"fmt"
	"strings"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type AggregateRepo struct {
	col *mongo.Collection
}

// ✅ Khởi tạo repository chuyên cho aggregation
func NewAggregateRepo(db *mongo.Database) repository_interface.AggregateRepo {
	return &AggregateRepo{col: db.Collection("registrations")}
}

// ======================================================
// 📊 1️⃣ Thống kê số khách theo loại sự kiện (Event Type)
// ======================================================
func (r *AggregateRepo) AggregateGuestCountByEventType(ctx context.Context) ([]*models.EventTypeGuestAggregation, error) {
	jsonPipeline := `
	[
	  { "$lookup": {
	      "from": "events",
	      "localField": "event_id",
	      "foreignField": "_id",
	      "as": "event"
	  }},
	  { "$unwind": { "path": "$event", "preserveNullAndEmptyArrays": true }},
	  { "$group": {
	      "_id": { "$ifNull": ["$event.type", "Unknown"] },
	      "total_guests": { "$sum": 1 },
	      "checked_in": { "$sum": { "$cond": ["$checked_in", 1, 0] } }
	  }},
	  { "$project": {
	      "event_type": "$_id",
	      "total_guests": 1,
	      "checked_in": 1
	  }},
	  { "$sort": { "total_guests": -1 } }
	]`

	var pipeline mongo.Pipeline
	if err := bson.UnmarshalExtJSON([]byte(jsonPipeline), true, &pipeline); err != nil {
		return nil, fmt.Errorf("invalid pipeline JSON: %v", err)
	}

	cursor, err := r.col.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []*models.EventTypeGuestAggregation
	for cursor.Next(ctx) {
		var agg models.EventTypeGuestAggregation
		if err := cursor.Decode(&agg); err != nil {
			return nil, err
		}
		results = append(results, &agg)
	}
	return results, cursor.Err()
}

// ======================================================
// 📊 2️⃣ Thống kê số khách theo sự kiện (Event)
// ======================================================
func (r *AggregateRepo) AggregateGuestCountByEvent(ctx context.Context) ([]*models.EventGuestAggregation, error) {
	return r.aggregateGuestCountByEvent(ctx, 0)
}

func (r *AggregateRepo) AggregateTopEventsByGuestCount(ctx context.Context, limit int) ([]*models.EventGuestAggregation, error) {
	return r.aggregateGuestCountByEvent(ctx, limit)
}

func (r *AggregateRepo) aggregateGuestCountByEvent(ctx context.Context, limit int) ([]*models.EventGuestAggregation, error) {
	jsonPipeline := fmt.Sprintf(`
	[
	  { "$group": {
	      "_id": "$event_id",
	      "total_guests": { "$sum": 1 },
	      "checked_in": { "$sum": { "$cond": ["$checked_in", 1, 0] } }
	  }},
	  { "$sort": { "total_guests": -1 } },
	  { "$lookup": {
	      "from": "events",
	      "localField": "_id",
	      "foreignField": "_id",
	      "as": "event"
	  }},
	  { "$unwind": { "path": "$event", "preserveNullAndEmptyArrays": true }},
	  { "$project": {
	      "event_id": "$_id",
	      "event_name": "$event.name",
	      "location": "$event.location",
	      "total_guests": 1,
	      "checked_in": 1
	  }}
	  %s
	]`, func() string {
		if limit > 0 {
			return fmt.Sprintf(`, { "$limit": %d }`, limit)
		}
		return ""
	}())

	var pipeline mongo.Pipeline
	if err := bson.UnmarshalExtJSON([]byte(jsonPipeline), true, &pipeline); err != nil {
		return nil, fmt.Errorf("invalid pipeline JSON: %v", err)
	}

	cursor, err := r.col.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []*models.EventGuestAggregation
	for cursor.Next(ctx) {
		var agg models.EventGuestAggregation
		if err := cursor.Decode(&agg); err != nil {
			return nil, err
		}
		results = append(results, &agg)
	}
	return results, cursor.Err()
}

// ======================================================
// 📊 3️⃣ Thống kê theo địa điểm (Location)
// ======================================================
func (r *AggregateRepo) AggregateGuestCountByLocation(ctx context.Context) ([]*models.LocationGuestAggregation, error) {
	jsonPipeline := `
	[
	  { "$lookup": {
	      "from": "events",
	      "localField": "event_id",
	      "foreignField": "_id",
	      "as": "event"
	  }},
	  { "$unwind": { "path": "$event", "preserveNullAndEmptyArrays": true }},
	  { "$group": {
	      "_id": "$event.location",
	      "total_guests": { "$sum": 1 },
	      "checked_in": { "$sum": { "$cond": ["$checked_in", 1, 0] } }
	  }},
	  { "$project": {
	      "location": "$_id",
	      "total_guests": 1,
	      "checked_in": 1
	  }},
	  { "$sort": { "total_guests": -1 } }
	]`

	var pipeline mongo.Pipeline
	if err := bson.UnmarshalExtJSON([]byte(jsonPipeline), true, &pipeline); err != nil {
		return nil, fmt.Errorf("invalid pipeline JSON: %v", err)
	}

	cursor, err := r.col.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []*models.LocationGuestAggregation
	for cursor.Next(ctx) {
		var agg models.LocationGuestAggregation
		if err := cursor.Decode(&agg); err != nil {
			return nil, err
		}
		results = append(results, &agg)
	}
	return results, cursor.Err()
}

// ======================================================
// 📊 4️⃣ Xu hướng tham gia theo thời gian (Trend)
// ======================================================
func (r *AggregateRepo) AggregateParticipationTrend(ctx context.Context, from, to time.Time, granularity string) ([]*models.ParticipationTrendAggregation, error) {
	unit := mapGranularity(granularity)
	matchStage := ""

	if !from.IsZero() || !to.IsZero() {
		timeFilter := bson.M{}
		if !from.IsZero() {
			timeFilter["$gte"] = from
		}
		if !to.IsZero() {
			timeFilter["$lte"] = to
		}
		jsonBytes, _ := bson.MarshalExtJSON(bson.M{"created_at": timeFilter}, true, true)
		matchStage = fmt.Sprintf(`, { "$match": %s }`, string(jsonBytes))
	}

	jsonPipeline := fmt.Sprintf(`
	[
	  { "$group": {
	      "_id": { "$dateTrunc": { "date": "$created_at", "unit": "%s" } },
	      "total_guests": { "$sum": 1 },
	      "checked_in": { "$sum": { "$cond": ["$checked_in", 1, 0] } }
	  }},
	  { "$project": {
	      "period": "$_id",
	      "total_guests": 1,
	      "checked_in": 1
	  }},
	  { "$sort": { "period": 1 } }
	  %s
	]`, unit, matchStage)

	var pipeline mongo.Pipeline
	if err := bson.UnmarshalExtJSON([]byte(jsonPipeline), true, &pipeline); err != nil {
		return nil, fmt.Errorf("invalid pipeline JSON: %v", err)
	}

	cursor, err := r.col.Aggregate(ctx, pipeline, options.Aggregate().SetAllowDiskUse(true))
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []*models.ParticipationTrendAggregation
	for cursor.Next(ctx) {
		var agg models.ParticipationTrendAggregation
		if err := cursor.Decode(&agg); err != nil {
			return nil, err
		}
		results = append(results, &agg)
	}
	return results, cursor.Err()
}

func mapGranularity(g string) string {
	switch strings.ToLower(g) {
	case "hour", "hours":
		return "hour"
	case "week", "weeks":
		return "week"
	case "month", "months":
		return "month"
	default:
		return "day"
	}
}

// Đếm số đăng ký theo EventID
func (r *AggregateRepo) CountByEvent(ctx context.Context, eventID string) (int, error) {
	count, err := r.col.CountDocuments(ctx, bson.M{"event_id": eventID})
	return int(count), err
}

// AggregateGuestStatsByEvent aggregates attendance stats for a single event.
func (r *AggregateRepo) AggregateGuestStatsByEvent(ctx context.Context, eventID string) (*models.EventStatModel, error) {
	eventID = strings.TrimSpace(eventID)
	if eventID == "" {
		return nil, errors.New("event id is required")
	}

	pipeline := mongo.Pipeline{
		{{"$match", bson.D{{"event_id", eventID}}}},
		{{"$group", bson.D{
			{"_id", "$event_id"},
			{"total_guests", bson.D{{"$sum", 1}}},
			{"checked_in", bson.D{{"$sum", bson.D{{"$cond", bson.A{"$checked_in", 1, 0}}}}}},
		}}},
		{{"$project", bson.D{
			{"event_id", "$_id"},
			{"total_guests", 1},
			{"checked_in", 1},
			{"absent", bson.D{{"$subtract", bson.A{"$total_guests", "$checked_in"}}}},
		}}},
	}

	cursor, err := r.col.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	if cursor.Next(ctx) {
		var result models.EventStatModel
		if err := cursor.Decode(&result); err != nil {
			return nil, err
		}
		return &result, nil
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}

	return &models.EventStatModel{
		EventID:     eventID,
		TotalGuests: 0,
		CheckedIn:   0,
		Absent:      0,
	}, nil
}
