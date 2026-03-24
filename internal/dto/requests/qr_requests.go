package requests

import (
	"github.com/google/uuid"
)

type GetInfoRequest struct {
	QrCode uuid.UUID `json:"id" binding:"required"`
}
