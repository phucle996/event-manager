package utils

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// GenToken tạo token ngẫu nhiên dựa trên secret
func GenToken(secret string, length int) (string, error) {
	bytes := make([]byte, length)
	_, err := rand.Read(bytes)
	if err != nil {
		return "", err
	}
	// Kết hợp secret + random bytes -> token
	token := fmt.Sprintf("%s.%s", secret, base64.URLEncoding.EncodeToString(bytes))
	return token, nil
}

func GenJWT(secret string, userID int) (string, error) {
	claims := jwt.MapClaims{
		"sub": userID,              // subject = userID
		"jti": uuid.New().String(), // unique token ID
		// "device_id": deviceID,            // gắn thông tin thiết bị
		// "roles":     roles,                                // vai trò/quyền
		"iat": time.Now().Unix(),                    // issued at
		"exp": time.Now().Add(time.Hour * 1).Unix(), // hết hạn sau 1h
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}
