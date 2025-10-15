package app

import (
	dbmongo "event_manager/infra/db"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/mongo"
)

// App quản lý toàn bộ ứng dụng (DB, Modules, Router)
type App struct {
	Modules *Modules
	Router  *gin.Engine
	Client  *mongo.Client
}

// ✅ Khởi tạo toàn bộ ứng dụng
func NewApplication() *App {
	dbURL := os.Getenv("DB_URL")
	if dbURL == "" {
		panic("⚠️ Thiếu biến môi trường DB_URL")
	}

	client, err := dbmongo.ConnectMongoDB(dbURL)
	if err != nil {
		panic(fmt.Errorf("❌ Kết nối Mongo thất bại: %w", err))
	}
	fmt.Println("✅ Đã kết nối MongoDB thành công.")

	// Khởi tạo Modules
	modules := NewModules(client)

	// Khởi tạo Router
	router := gin.Default()
	RegisterRoutes(router, modules)

	return &App{
		Modules: modules,
		Router:  router,
		Client:  client,
	}
}

// ✅ Khởi động app
func (a *App) Start() error {
	host := os.Getenv("APP_HOST")
	if host == "" {
		host = "0.0.0.0"
	}
	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	addr := fmt.Sprintf("%s:%s", host, port)
	fmt.Printf("🚀 Server đang chạy tại http://%s\n", addr)
	return a.Router.Run(addr)
}

// ✅ Dừng app và đóng kết nối DB
func (a *App) Stop() {
	if a.Client == nil {
		return
	}
	if err := dbmongo.StopMongoDB(a.Client); err != nil {
		log.Println("⚠️ Lỗi khi ngắt kết nối MongoDB:", err)
	} else {
		fmt.Println("🛑 Đã ngắt kết nối MongoDB thành công.")
	}
}
