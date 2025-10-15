package entity

import (
	"time"
)

type User struct {
	ID        string
	Username  string
	Email     string
	FullName  string
	Status    string
	Role      string
	CreatedAt time.Time
	UpdatedAt time.Time
}
