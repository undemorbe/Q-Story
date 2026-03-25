package requests

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

type GetInfoRequest struct {
	QrCode uuid.UUID `json:"id" binding:"required"`
}

type PostInfoRequest struct {
	Marker   *Marker   `json:"marker" binding:"required"`
	Buidling *Building `json:"building" binding:"required"`
}

type Marker struct {
	ClientID string `json:"id" binding:"required"`
	Lat      string `json:"lat" binding:"required"`
	Lon      string `json:"lon" binding:"required"`

	Title string `json:"title" binding:"required"`
	Type  string `json:"type"`

	CompressedDescription string `json:"compressed-description"`
}

type Building struct {
	ClientID              string `json:"id" binding:"required"`
	Title                 string `json:"title" binding:"required"`
	CompressedDescription string `json:"compressed-description"`

	Description Description    `json:"description" binding:"required"`
	Image       string         `json:"image"`
	StartedAt   time.Time      `json:"date-start"`
	EndedAt     time.Time      `json:"date-end"`
	Type        string         `json:"type"`
	Person      *string        `json:"person"`
	Resources   pq.StringArray `json:"resources"`
}

type Description struct {
	Top    string `json:"top"`
	Main   string `json:"main"`
	Bottom string `json:"bottom"`
}
