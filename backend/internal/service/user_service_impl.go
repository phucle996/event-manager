package service_imple

import (
	"context"
	"errors"
	"event_manager/internal/domain/entity"
	repository "event_manager/internal/domain/repository"
	"event_manager/internal/models"
	"fmt"
	"time"
)

// 🧩 UserServiceImpl implements UserService
type UserServiceImpl struct {
	repo repository.UserRepository
}

// ✅ Constructor
func NewUserService(repo repository.UserRepository) *UserServiceImpl {
	return &UserServiceImpl{repo: repo}
}

// ➕ CreateUser – nghiệp vụ tạo mới user
func (s *UserServiceImpl) CreateUser(ctx context.Context, username, email, fullName string) error {
	// Kiểm tra đầu vào
	if username == "" || email == "" || fullName == "" {
		return errors.New("missing required fields")
	}

	// Kiểm tra username trùng
	exist, err := s.repo.FindByUsername(ctx, username)
	if err != nil {
		return fmt.Errorf("error checking existing username: %w", err)
	}
	if exist != nil {
		return fmt.Errorf("username '%s' already exists", username)
	}

	// Tạo entity (logic thuần domain)
	user := &entity.User{
		Username:  username,
		Email:     email,
		FullName:  fullName,
		Status:    "active",
		Role:      "user",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	// Map sang model để lưu Mongo
	model := new(models.UserModel).UserEntityToModel(user)

	if err := s.repo.Insert(ctx, model); err != nil {
		return fmt.Errorf("failed to insert user: %w", err)
	}

	return nil
}

// ✏️ UpdateProfile – nghiệp vụ cập nhật thông tin user
func (s *UserServiceImpl) UpdateProfile(ctx context.Context, id string, fullName, email string) error {
	if id == "" {
		return errors.New("missing user id")
	}

	// Tìm user hiện tại
	m, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return fmt.Errorf("find user error: %w", err)
	}
	if m == nil {
		return errors.New("user not found")
	}

	// Cập nhật thông tin
	if fullName != "" {
		m.FullName = fullName
	}
	if email != "" {
		m.Email = email
	}
	m.UpdatedAt = time.Now()

	if err := s.repo.Update(ctx, m); err != nil {
		return fmt.Errorf("update user error: %w", err)
	}
	return nil
}

// 🚫 DeactivateUser – nghiệp vụ vô hiệu hóa
func (s *UserServiceImpl) DeactivateUser(ctx context.Context, id string) error {
	if id == "" {
		return errors.New("missing user id")
	}

	m, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return fmt.Errorf("find user error: %w", err)
	}
	if m == nil {
		return errors.New("user not found")
	}

	m.Status = "inactive"
	m.UpdatedAt = time.Now()

	if err := s.repo.Update(ctx, m); err != nil {
		return fmt.Errorf("failed to deactivate user: %w", err)
	}
	return nil
}

// ✅ ActivateUser – nghiệp vụ kích hoạt lại
func (s *UserServiceImpl) ActivateUser(ctx context.Context, id string) error {
	if id == "" {
		return errors.New("missing user id")
	}

	m, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return fmt.Errorf("find user error: %w", err)
	}
	if m == nil {
		return errors.New("user not found")
	}

	m.Status = "active"
	m.UpdatedAt = time.Now()

	if err := s.repo.Update(ctx, m); err != nil {
		return fmt.Errorf("failed to activate user: %w", err)
	}
	return nil
}

// 🔍 GetUserByID – nghiệp vụ lấy thông tin chi tiết user
func (s *UserServiceImpl) GetUserByID(ctx context.Context, id string) (*entity.User, error) {
	if id == "" {
		return nil, errors.New("missing user id")
	}

	m, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("find user error: %w", err)
	}
	if m == nil {
		return nil, errors.New("user not found")
	}

	return m.UserModelToEntity(), nil
}

// 📋 ListUsers – nghiệp vụ liệt kê danh sách user
func (s *UserServiceImpl) ListUsers(ctx context.Context, limit, offset int) ([]*entity.User, error) {
	list, err := s.repo.List(ctx, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list users error: %w", err)
	}

	users := make([]*entity.User, 0, len(list))
	for _, m := range list {
		users = append(users, m.UserModelToEntity())
	}

	return users, nil
}
