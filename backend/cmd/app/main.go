package main

import (
	"event_manager/internal/app"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/joho/godotenv"
)

func main() {

	// 1️⃣ Load biến môi trường từ file .env (nếu có)
	if err := godotenv.Load(); err != nil {
		fmt.Println("⚠️ Không tìm thấy file .env — sử dụng biến môi trường mặc định.")
	}

	application := app.NewApplication()

	// Lắng nghe tín hiệu dừng
	go func() {
		if err := application.Start(); err != nil {
			panic(err)
		}
	}()

	// Chờ tín hiệu CTRL+C
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	application.Stop()
}
