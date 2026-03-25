package responses

type GenericResponse struct {
	Message string `json:"message,omitempty"`
	Code    string `json:"code,omitempty"`
}
