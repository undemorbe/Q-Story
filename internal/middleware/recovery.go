package middleware

import (
	"net/http"
	"q-story/internal/errors"
	"q-story/internal/infrastructure/logger"

	"github.com/gin-gonic/gin"
)

func RecoveryMiddleware() gin.HandlerFunc {
	return gin.CustomRecovery(
		func(c *gin.Context, recovered interface{}) {
			logger.Log.Error("Паника на сервере: ", recovered)

			err := errors.ErrorInternal
			c.JSON(http.StatusInternalServerError, gin.H{
				"code":    err.Code,
				"message": err.Message,
			})

			c.Abort()
		})
}
