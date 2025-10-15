package service_imple

import (
	"context"
	"errors"
	"fmt"
	"time"

	"event_manager/internal/domain/entity"
	repository "event_manager/internal/domain/repository"
	service_interface "event_manager/internal/domain/service"
	"event_manager/internal/models"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// RegistrationServiceImpl coordinates registration domain operations.
type RegistrationServiceImpl struct {
	repo repository.RegistrationRepository
}

// NewRegistrationService constructs a RegistrationService backed by the repository.
func NewRegistrationService(repo repository.RegistrationRepository) service_interface.RegistrationService {
	return &RegistrationServiceImpl{repo: repo}
}

// Register creates a new registration entity.
func (s *RegistrationServiceImpl) Register(ctx context.Context, registration *entity.Registration) error {
	if registration == nil {
		return errors.New("registration is nil")
	}
	if registration.EventID == "" || registration.GuestID == "" {
		return errors.New("event id and guest id are required")
	}

	if registration.ID == "" {
		registration.ID = primitive.NewObjectID().Hex()
	}
	if registration.Status == "" {
		registration.Status = "pending"
	}
	if registration.CreatedAt.IsZero() {
		registration.CreatedAt = time.Now()
	}

	model, err := models.RegistrationEntityToModel(registration)
	if err != nil {
		return fmt.Errorf("map registration to model failed: %w", err)
	}

	if err := s.repo.Insert(ctx, model); err != nil {
		return fmt.Errorf("insert registration failed: %w", err)
	}
	return nil
}

// CheckIn marks a registration as attended.
func (s *RegistrationServiceImpl) CheckIn(ctx context.Context, registrationID string) (*entity.Registration, error) {
	if registrationID == "" {
		return nil, errors.New("registration id is required")
	}

	model, err := s.repo.FindByID(ctx, registrationID)
	if err != nil {
		return nil, fmt.Errorf("find registration failed: %w", err)
	}
	if model == nil {
		return nil, errors.New("registration not found")
	}

	model.CheckedIn = true
	if model.Status == "" || model.Status == "pending" {
		model.Status = "checked_in"
	}

	if err := s.repo.Update(ctx, model); err != nil {
		return nil, fmt.Errorf("update registration failed: %w", err)
	}

	return model.RegistrationModelToEntity(), nil
}

// Cancel revokes a registration and returns the updated entity.
func (s *RegistrationServiceImpl) Cancel(ctx context.Context, registrationID string) (*entity.Registration, error) {
	if registrationID == "" {
		return nil, errors.New("registration id is required")
	}

	model, err := s.repo.FindByID(ctx, registrationID)
	if err != nil {
		return nil, fmt.Errorf("find registration failed: %w", err)
	}
	if model == nil {
		return nil, errors.New("registration not found")
	}

	model.Status = "cancelled"
	model.CheckedIn = false

	if err := s.repo.Update(ctx, model); err != nil {
		return nil, fmt.Errorf("update registration failed: %w", err)
	}

	return model.RegistrationModelToEntity(), nil
}

// GetByID fetches registration detail.
func (s *RegistrationServiceImpl) GetByID(ctx context.Context, registrationID string) (*entity.Registration, error) {
	if registrationID == "" {
		return nil, errors.New("registration id is required")
	}

	model, err := s.repo.FindByID(ctx, registrationID)
	if err != nil {
		return nil, fmt.Errorf("find registration failed: %w", err)
	}
	if model == nil {
		return nil, nil
	}
	return model.RegistrationModelToEntity(), nil
}

// ListByEvent returns registrations for the specified event.
func (s *RegistrationServiceImpl) ListByEvent(ctx context.Context, eventID string) ([]*entity.Registration, error) {
	if eventID == "" {
		return nil, errors.New("event id is required")
	}

	modelsList, err := s.repo.FindByEvent(ctx, eventID)
	if err != nil {
		return nil, fmt.Errorf("list registrations by event failed: %w", err)
	}
	return mapRegistrationModels(modelsList), nil
}

// ListByGuest returns registrations created by the guest.
func (s *RegistrationServiceImpl) ListByGuest(ctx context.Context, guestID string) ([]*entity.Registration, error) {
	if guestID == "" {
		return nil, errors.New("guest id is required")
	}

	modelsList, err := s.repo.FindByGuest(ctx, guestID)
	if err != nil {
		return nil, fmt.Errorf("list registrations by guest failed: %w", err)
	}
	return mapRegistrationModels(modelsList), nil
}
