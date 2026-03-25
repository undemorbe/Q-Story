package errors

var (
	ErrorInvalidInput = AppError{
		Code:    CodeInvalidInput,
		Message: "Некоректный формат входных данных",
	}

	ErrorNotFound = AppError{
		Code:    CodeNotFound,
		Message: "Информация об объекте не найдена",
	}

	ErrorInternal = AppError{
		Code:    CodeInternalError,
		Message: "Непредвиденная ошибка сервера. Попробуйте позже",
	}
)
