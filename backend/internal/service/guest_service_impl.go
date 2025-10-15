package service_imple

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"event_manager/internal/domain/entity"
	repository "event_manager/internal/domain/repository"
	service_interface "event_manager/internal/domain/service"
	"event_manager/internal/models"
)

// GuestServiceImpl provides guest-domain operations backed by repositories.
type GuestServiceImpl struct {
	repo             repository.GuestRepository
	registrationRepo repository.RegistrationRepository
}

// NewGuestService wires dependencies into a GuestService implementation.
func NewGuestService(
	repo repository.GuestRepository,
	registrationRepo repository.RegistrationRepository,
) service_interface.GuestService {
	return &GuestServiceImpl{
		repo:             repo,
		registrationRepo: registrationRepo,
	}
}

// Create persists a new guest entity and registers the guest to the provided event.
func (s *GuestServiceImpl) Create(ctx context.Context, guest *entity.Guest, eventID string) error {
	if guest == nil {
		return errors.New("guest is nil")
	}
	if strings.TrimSpace(guest.FullName) == "" {
		return errors.New("guest full name is required")
	}
	if strings.TrimSpace(guest.Email) == "" && strings.TrimSpace(guest.Phone) == "" {
		return errors.New("guest contact (email or phone) is required")
	}

	eventID = strings.TrimSpace(eventID)
	if eventID == "" {
		return errors.New("event id is required")
	}

	model := models.GuestEntityToModel(guest)
	guest.ID = model.ID

	if err := s.repo.Insert(ctx, model); err != nil {
		return fmt.Errorf("insert guest failed: %w", err)
	}

	if s.registrationRepo != nil {
		if err := s.ensureGuestRegistration(ctx, guest.ID, eventID); err != nil {
			// Best-effort rollback to keep data consistent when registration fails.
			_ = s.repo.Delete(ctx, guest.ID)
			return err
		}
	}
	return nil
}

// Update modifies an existing guest and optionally adjusts their registration's event.
func (s *GuestServiceImpl) Update(ctx context.Context, guest *entity.Guest, eventID string) error {
	if guest == nil || strings.TrimSpace(guest.ID) == "" {
		return errors.New("invalid guest for update")
	}

	existing, err := s.repo.FindByID(ctx, guest.ID)
	if err != nil {
		return fmt.Errorf("load guest failed: %w", err)
	}
	if existing == nil {
		return errors.New("guest not found")
	}

	model := &models.GuestModel{
		ID:       strings.TrimSpace(guest.ID),
		FullName: guest.FullName,
		Email:    guest.Email,
		Phone:    guest.Phone,
	}

	if err := s.repo.Update(ctx, model); err != nil {
		return fmt.Errorf("update guest failed: %w", err)
	}

	eventID = strings.TrimSpace(eventID)
	if eventID == "" || s.registrationRepo == nil {
		return nil
	}

	if err := s.ensureGuestRegistration(ctx, guest.ID, eventID); err != nil {
		return err
	}

	return nil
}

// ensureGuestRegistration either creates or updates the registration for the guest.
func (s *GuestServiceImpl) ensureGuestRegistration(ctx context.Context, guestID, eventID string) error {
	regs, err := s.registrationRepo.FindByGuest(ctx, guestID)
	if err != nil {
		return fmt.Errorf("find registration by guest failed: %w", err)
	}

	if len(regs) == 0 {
		regEntity := &entity.Registration{
			EventID: eventID,
			GuestID: guestID,
			Status:  "pending",
		}
		regModel, err := models.RegistrationEntityToModel(regEntity)
		if err != nil {
			return fmt.Errorf("map registration to model failed: %w", err)
		}
		if err := s.registrationRepo.Insert(ctx, regModel); err != nil {
			return fmt.Errorf("insert registration failed: %w", err)
		}
		return nil
	}

	regModel := regs[0]
	// Update event and ensure guest association remains consistent.
	regModel.EventID = eventID
	regModel.GuestID = guestID
	if err := s.registrationRepo.Update(ctx, regModel); err != nil {
		return fmt.Errorf("update registration failed: %w", err)
	}
	return nil
}

// Delete removes a guest by identifier.
func (s *GuestServiceImpl) Delete(ctx context.Context, guestID string) error {
	if strings.TrimSpace(guestID) == "" {
		return errors.New("guest id is required")
	}
	if err := s.repo.Delete(ctx, guestID); err != nil {
		return fmt.Errorf("delete guest failed: %w", err)
	}
	return nil
}

// GetByID retrieves guest details by identifier.
func (s *GuestServiceImpl) GetByID(ctx context.Context, guestID string) (*entity.Guest, error) {
	if strings.TrimSpace(guestID) == "" {
		return nil, errors.New("guest id is required")
	}

	model, err := s.repo.FindByID(ctx, guestID)
	if err != nil {
		return nil, fmt.Errorf("find guest failed: %w", err)
	}
	if model == nil {
		return nil, nil
	}
	return models.GuestModelToEntity(model), nil
}

// List returns guests filtered optionally by keyword.
func (s *GuestServiceImpl) List(ctx context.Context, keyword string) ([]*entity.Guest, error) {
	modelsList, err := s.repo.FindAll(ctx)
	if err != nil {
		return nil, fmt.Errorf("list guests failed: %w", err)
	}

	keyword = strings.ToLower(strings.TrimSpace(keyword))
	result := make([]*entity.Guest, 0, len(modelsList))

	for _, model := range modelsList {
		if model == nil {
			continue
		}

		entityGuest := models.GuestModelToEntity(model)
		if keyword != "" {
			if !strings.Contains(strings.ToLower(entityGuest.FullName), keyword) &&
				!strings.Contains(strings.ToLower(entityGuest.Email), keyword) &&
				!strings.Contains(strings.ToLower(entityGuest.Phone), keyword) {
				continue
			}
		}
		result = append(result, entityGuest)
	}
	return result, nil
}

// FindByContact locates a guest by email or phone.
func (s *GuestServiceImpl) FindByContact(ctx context.Context, email, phone string) (*entity.Guest, error) {
	email = strings.TrimSpace(email)
	if email != "" {
		model, err := s.repo.FindByEmail(ctx, email)
		if err != nil {
			return nil, fmt.Errorf("find guest by email failed: %w", err)
		}
		if model != nil {
			return models.GuestModelToEntity(model), nil
		}
	}

	phone = strings.TrimSpace(phone)
	if phone == "" {
		return nil, nil
	}

	modelsList, err := s.repo.FindAll(ctx)
	if err != nil {
		return nil, fmt.Errorf("find guest by phone failed: %w", err)
	}

	for _, model := range modelsList {
		if model != nil && strings.EqualFold(model.Phone, phone) {
			return models.GuestModelToEntity(model), nil
		}
	}
	return nil, nil
}
