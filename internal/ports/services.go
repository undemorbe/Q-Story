package ports

import (
	"q-story/internal/dto/requests"
	"q-story/internal/dto/responses"

	"github.com/google/uuid"
)

type QrService interface {
	GetMarkers() (responses.GetMarkersResponse, error)
	GetInfo(qrCode uuid.UUID) (
		responses.GetInfoResponse, error)
	PostInfo(req *requests.PostInfoRequest) error
}
