package app

import (
    "fmt"

    service_interface "event_manager/internal/domain/service"
    v1handler "event_manager/internal/handler/v1"
    repository_imple "event_manager/internal/repository"
    service_imple "event_manager/internal/service"
    "event_manager/internal/storage"

    "go.mongodb.org/mongo-driver/mongo"
)

type Modules struct {
    EventService        service_interface.EventService
    UserService         service_interface.UserService
    GuestService        service_interface.GuestService
    RegistrationService service_interface.RegistrationService
    MediaStorage        storage.ObjectStorage

	V1EventHandler        *v1handler.EventHandler
	V1UserHandler         *v1handler.UserHandler
	V1GuestHandler        *v1handler.GuestHandler
	V1RegistrationHandler *v1handler.RegistrationHandler
	V1AnalyticsHandler    *v1handler.AnalyticsHandler
	db                    *mongo.Client
}

func NewModules(db *mongo.Client) *Modules {
	// Initialize repositories
	dbSavedata := db.Database("event_manager")
	eventRepo := repository_imple.NewEventMongoRepository(dbSavedata)
	registrationRepo := repository_imple.NewRegistrationMongoRepository(dbSavedata)
	guestRepo := repository_imple.NewGuestRepository(dbSavedata)
	userRepo := repository_imple.NewUserMongoRepository(dbSavedata)
	aggregateRepo := repository_imple.NewAggregateRepo(dbSavedata)

    // Initialize services
    eventService := service_imple.NewEventService(eventRepo, registrationRepo)
    userService := service_imple.NewUserService(userRepo)
    registrationService := service_imple.NewRegistrationService(registrationRepo)
    guestService := service_imple.NewGuestService(guestRepo, registrationRepo)
    aggregateService := service_imple.NewAggregateServiceImpl(aggregateRepo)

    mediaStorage, err := storage.NewMinioStorageFromEnv()
    if err != nil {
        panic(fmt.Errorf("failed to initialize MinIO storage: %w", err))
    }

    // Initialize handlers
    v1EventHandler := v1handler.NewEventHandler(eventService, mediaStorage)
	v1UserHandler := v1handler.NewUserHandler(userService)
	v1GuestHandler := v1handler.NewGuestHandler(guestService)
	v1RegistrationHandler := v1handler.NewRegistrationHandler(registrationService)
	v1AnalyticsHandler := v1handler.NewAnalyticsHandler(aggregateService)

	// Return the assembled module container
    return &Modules{
        EventService:        eventService,
        UserService:         userService,
        GuestService:        guestService,
        RegistrationService: registrationService,
        MediaStorage:        mediaStorage,

		V1EventHandler:        v1EventHandler,
		V1UserHandler:         v1UserHandler,
		V1GuestHandler:        v1GuestHandler,
		V1RegistrationHandler: v1RegistrationHandler,
		V1AnalyticsHandler:    v1AnalyticsHandler,

		db: db,
	}
}
