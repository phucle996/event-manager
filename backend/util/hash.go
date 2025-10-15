package utils

import (
	"crypto/sha256"
	"encoding/base64"

	"golang.org/x/crypto/bcrypt"
)

// HashPassword băm password bằng bcrypt với cost = 12
func HashPassword(plainPassword string) (string, error) {
	const cost = 12
	hash, err := bcrypt.GenerateFromPassword([]byte(plainPassword), cost)
	if err != nil {
		return "", err
	}
	return string(hash), nil
}

// ComparePassword so sánh plain password với hashed password trong DB
func ComparePassword(hashedPassword, plainPassword string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(plainPassword))
}

// HashToken băm token bằng SHA256 để lưu DB
func HashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return base64.URLEncoding.EncodeToString(sum[:])
}
