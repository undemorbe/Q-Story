package repositories

import (
	"errors"
	"q-story/internal/entities"
	"q-story/internal/ports"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type buildingRepo struct {
	db *gorm.DB
}

func NewBuildingRepository(db *gorm.DB) ports.BuildingRepository {
	return &buildingRepo{db: db}
}

func (r *buildingRepo) FindByID(buildingID uuid.UUID) (
	*entities.Building, error) {
	var building entities.Building

	err := r.db.First(&building, buildingID).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &building, nil
}

func (r *buildingRepo) CreateBuilding(building *entities.Building) error {
	return r.db.Create(building).Error
}

func (r *buildingRepo) UpdateBuilding(building *entities.Building) error {
	return r.db.Save(building).Error
}
