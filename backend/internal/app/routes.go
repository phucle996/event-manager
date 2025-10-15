package app

import "github.com/gin-gonic/gin"

func RegisterRoutes(r *gin.Engine, m *Modules) {
	api := r.Group("/api")
	{
		// api version 1 using handler version 1
		v1 := api.Group("/v1")
		{
			events := v1.Group("/events")
			{
				events.POST("/", m.V1EventHandler.CreateEvent)
				events.GET("/", m.V1EventHandler.ListEvents)
				events.GET("/:id", m.V1EventHandler.GetEventByID)
				events.GET("/:id/statistics", m.V1EventHandler.GetStatistics)
				events.PATCH("/auto-update", m.V1EventHandler.AutoUpdateStatus)
				events.PUT("/:id", m.V1EventHandler.UpdateEvent)
				events.DELETE("/:id", m.V1EventHandler.DeleteEvent)
			}

			users := v1.Group("/users")
			{
				users.POST("/", m.V1UserHandler.CreateUser)
				users.PUT("/:id", m.V1UserHandler.UpdateProfile)
				// users.PUT("/:id/activate", m.V1UserHandler.ActivateUser)
				// users.PUT("/:id/deactivate", m.V1UserHandler.DeactivateUser)
				users.GET("/", m.V1UserHandler.ListUsers)
				users.GET("/:id", m.V1UserHandler.GetUserByID)
			}

			guests := v1.Group("/guests")
			{
				guests.POST("/", m.V1GuestHandler.CreateGuest)
				guests.PUT("/:id", m.V1GuestHandler.UpdateGuest)
				guests.DELETE("/:id", m.V1GuestHandler.DeleteGuest)
				guests.GET("/", m.V1GuestHandler.ListGuests)
				guests.GET("/search", m.V1GuestHandler.FindGuestByContact)
				guests.GET("/:id", m.V1GuestHandler.GetGuestByID)
			}

			registrations := v1.Group("/registrations")
			{
				registrations.POST("/", m.V1RegistrationHandler.Register)
				registrations.GET("/", m.V1RegistrationHandler.List)
				registrations.GET("/:id", m.V1RegistrationHandler.GetByID)
				registrations.PUT("/:id/check-in", m.V1RegistrationHandler.CheckIn)
				registrations.PUT("/:id/cancel", m.V1RegistrationHandler.Cancel)
			}

			analytics := v1.Group("/analytics")
			{
				analytics.GET("/events", m.V1AnalyticsHandler.GetGuestStatsByEvent)
				analytics.GET("/event-types", m.V1AnalyticsHandler.GetGuestStatsByEventType)
				analytics.GET("/events/:id/guests", m.V1AnalyticsHandler.GetGuestCountByEvent)
				analytics.GET("/events/top", m.V1AnalyticsHandler.GetTopEventsByGuests)
				analytics.GET("/locations", m.V1AnalyticsHandler.GetGuestStatsByLocation)
				analytics.GET("/participation", m.V1AnalyticsHandler.GetParticipationTrend)
			}
		}
	}
}
