package middleware

import (
	"net/http"
	"q-story/internal/errors"
	"q-story/internal/infrastructure/logger"

	"github.com/gin-gonic/gin"
)

func ErrorHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		if len(c.Errors) == 0 {
			return
		}

		err := c.Errors.Last().Err

		if appErr, ok := err.(errors.AppError); ok {

			logger.Log.Warn("Возникла ошибка при обработке запроса: ", appErr.Code)

			switch appErr.Code {

			case errors.CodeInvalidInput:

				c.JSON(http.StatusBadRequest, gin.H{
					"code":    appErr.Code,
					"message": appErr.Message,
				})
				return

			case errors.CodeNotFound:

				c.JSON(http.StatusNotFound, gin.H{
					"code":    appErr.Code,
					"message": appErr.Message,
				})
				return

			case errors.CodeInternalError:

				c.JSON(http.StatusInternalServerError, gin.H{
					"code":    appErr.Code,
					"message": appErr.Message,
				})
				return

			default:

				c.JSON(http.StatusInternalServerError, gin.H{
					"code":    errors.ErrorInternal.Code,
					"message": errors.ErrorInternal.Message,
				})
			}
		}

		logger.Log.Error("Непредвиденная ошибка на сервере: ", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    errors.ErrorInternal.Code,
			"message": errors.ErrorInternal.Message,
		})
	}
}
