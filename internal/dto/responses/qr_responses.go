package responses

import (
	"time"

	"github.com/lib/pq"
)

type GetInfoResponse struct {
	ClientID              string `json:"id"`
	Title                 string `json:"title"`
	CompressedDescription string `json:"compressed-description"`

	Description Description    `json:"description"`
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

type GetMarkersResponse struct {
	Markers []Marker `json:"markers"`
}

type Marker struct {
	ClientID string `json:"id"`

	Lat   string `json:"lat"`
	Lon   string `json:"lon"`
	Title string `json:"title"`
	Type  string `json:"type"`

	CompressedDescription string `json:"compressed-description"`
}
