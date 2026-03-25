package main

import (
	//"q-story/internal/infrastructure/database"
	"q-story/internal/handlers"
	"q-story/internal/infrastructure/database"
	"q-story/internal/infrastructure/logger"
	"q-story/internal/middleware"
	"q-story/internal/repositories"
	"q-story/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	r := gin.Default()

	r.Use(middleware.RecoveryMiddleware())
	r.Use(middleware.ErrorHandler())

	logger.InitLogger()

	err := godotenv.Load()
	if err != nil {
		logger.Log.Fatal("Ошибка при загрузке .env файла")
	}

	db, err := database.NewPostgresConnection()
	if err != nil {
		logger.Log.Fatal("Ошибка подключения к БД: ", err)
	}
	logger.Log.Info("Успешно осуществлено подключение к БД")

	err = database.RunMigrations(db)
	if err != nil {
		logger.Log.Fatal("Ошибка применения миграций: ", err)
	}
	logger.Log.Info("Миграции успешно применены")

	buildingRepo := repositories.NewBuildingRepository(db)
	markerRepo := repositories.NewMarkerRepository(db)

	qrService := services.NewQrService(buildingRepo, markerRepo)

	qrHandler := handlers.NewQrHandler(qrService)

	api := r.Group("/api")
	{
		api.GET("/get-info", qrHandler.GetInfo)
		api.GET("/get-markers", qrHandler.GetMarkers)
		api.POST("/post-info", qrHandler.PostInfo)
	}

	logger.Log.Info("Сервер запущен на :5050")
	if err := r.Run(":5050"); err != nil {
		logger.Log.Error(err)
	}
}
