package entities

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Marker struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey"`
	BuildingID uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	ClientID              string `gorm:"not null"`
	Lat                   string `gorm:"not null"`
	Lon                   string `gorm:"not null"`
	Title                 string `gorm:"not null"`
	Type                  string `gorm:"not null"`
	CompressedDescription string `gorm:"not null"`
}

func (m *Marker) BeforeCreate(db *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}
