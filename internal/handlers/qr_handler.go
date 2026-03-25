package handlers

import (
	"net/http"
	"q-story/internal/dto/requests"
	"q-story/internal/dto/responses"
	"q-story/internal/errors"
	"q-story/internal/infrastructure/logger"
	"q-story/internal/ports"

	"github.com/gin-gonic/gin"
)

type QrHandler struct {
	qrService ports.QrService
}

func NewQrHandler(qrService ports.QrService) *QrHandler {
	return &QrHandler{
		qrService: qrService,
	}
}

func (h *QrHandler) GetInfo(c *gin.Context) {
	var req requests.GetInfoRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.qrService.GetInfo(req.QrCode)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Успешно выполнено получение информации о здании")
	c.JSON(http.StatusOK, response)
}

func (h *QrHandler) GetMarkers(c *gin.Context) {

	response, err := h.qrService.GetMarkers()

	if err != nil {
		c.Error(err)
	}

	logger.Log.Info("Успешно выполнено поучение маркеров")
	c.JSON(http.StatusOK, response)
}

func (h *QrHandler) PostInfo(c *gin.Context) {
	var req requests.PostInfoRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	err = h.qrService.PostInfo(&req)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Успешно выполнено сохранение маркера и здания")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}
