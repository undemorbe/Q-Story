package ports

import (
	"q-story/internal/entities"

	"github.com/google/uuid"
)

type BuildingRepository interface {
	FindByID(buildingID uuid.UUID) (*entities.Building, error)
	CreateBuilding(building *entities.Building) error
	UpdateBuilding(building *entities.Building) error
}

type MarkerRepository interface {
	GetAll() ([]entities.Marker, error)
	CreateMarker(marker *entities.Marker) error
	UpdateMarker(marker *entities.Marker) error
}
