package entities

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

type Building struct {
	ID uuid.UUID `gorm:"type:uuid;primaryKey"`

	ClientID              string `gorm:"not null"`
	Title                 string `gorm:"not null"`
	CompressedDescription string `gorm:"not null"`

	TopDescription    string
	MainDescription   string
	BottomDescription string

	Image     string         `json:"image"`
	StartedAt time.Time      `gorm:"not null"`
	EndedAt   time.Time      `gorm:"not null"`
	Type      string         `gorm:"not null"`
	Person    string         `gorm:"default:''"`
	Resources pq.StringArray `gorm:"type:text[]"`

	Marker *Marker `gorm:"foreignKey:BuildingID;constraint:OnDelete:CASCADE"`
}

func (b *Building) BeforeCreate(db *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	if b.Resources == nil {
		b.Resources = pq.StringArray{}
	}
	return nil
}
