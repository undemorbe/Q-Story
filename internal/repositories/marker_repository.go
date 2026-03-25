package repositories

import (
	"q-story/internal/entities"
	"q-story/internal/ports"

	"gorm.io/gorm"
)

type markerRepo struct {
	db *gorm.DB
}

func NewMarkerRepository(db *gorm.DB) ports.MarkerRepository {
	return &markerRepo{db: db}
}

func (r *markerRepo) GetAll() ([]entities.Marker, error) {
	var markers []entities.Marker

	err := r.db.Find(&markers).Error
	if err != nil {
		return nil, err
	}

	return markers, nil
}

func (r *markerRepo) CreateMarker(marker *entities.Marker) error {
	return r.db.Create(marker).Error
}

func (r *markerRepo) UpdateMarker(marker *entities.Marker) error {
	return r.db.Save(marker).Error
}
