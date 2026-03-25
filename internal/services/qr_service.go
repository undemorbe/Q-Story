package services

import (
	"q-story/internal/dto/requests"
	"q-story/internal/dto/responses"
	"q-story/internal/entities"
	"q-story/internal/ports"

	"github.com/google/uuid"
)

type QrService struct {
	buildingRepo ports.BuildingRepository
	markerRepo   ports.MarkerRepository
}

func NewQrService(buildingRepo ports.BuildingRepository,
	markerRepo ports.MarkerRepository) ports.QrService {
	return &QrService{
		buildingRepo: buildingRepo,
		markerRepo:   markerRepo,
	}
}

func (s *QrService) GetInfo(qrCode uuid.UUID) (
	responses.GetInfoResponse, error) {

	building, err := s.buildingRepo.FindByID(qrCode)
	if err != nil {
		return responses.GetInfoResponse{},
			err
	}

	response := responses.GetInfoResponse{
		ClientID:              building.ClientID,
		Title:                 building.Title,
		CompressedDescription: building.CompressedDescription,

		Description: responses.Description{
			Top:    building.TopDescription,
			Main:   building.MainDescription,
			Bottom: building.BottomDescription,
		},

		Image:     building.Image,
		StartedAt: building.StartedAt,
		EndedAt:   building.EndedAt,
		Type:      building.Type,
		Person:    &building.Person,
		Resources: building.Resources,
	}

	return response, nil
}

func (s *QrService) GetMarkers() (
	responses.GetMarkersResponse, error) {

	markers, err := s.markerRepo.GetAll()
	if err != nil {
		return responses.GetMarkersResponse{}, err
	}

	response := responses.GetMarkersResponse{
		Markers: []responses.Marker{},
	}

	for i := range markers {
		marker := s.getMarker(&markers[i])

		response.Markers = append(response.Markers, marker)
	}

	return response, nil
}

func (s *QrService) getMarker(marker *entities.Marker) responses.Marker {

	markerForResponse := responses.Marker{
		ClientID: marker.ClientID,

		Lat:   marker.Lat,
		Lon:   marker.Lon,
		Title: marker.Title,
		Type:  marker.Type,

		CompressedDescription: marker.CompressedDescription,
	}

	return markerForResponse
}

func (s *QrService) PostInfo(req *requests.PostInfoRequest) error {

	marker := req.Marker
	building := req.Buidling

	buildingID := uuid.New()

	newMarker := &entities.Marker{
		BuildingID: buildingID,

		ClientID: req.Marker.ClientID,
		Lat:      marker.Lat,
		Lon:      marker.Lon,
		Title:    marker.Title,
		Type:     marker.Type,

		CompressedDescription: marker.CompressedDescription,
	}

	newBuilding := &entities.Building{
		ID: buildingID,

		ClientID:              building.ClientID,
		Title:                 building.Title,
		CompressedDescription: building.CompressedDescription,

		TopDescription:    building.Description.Top,
		MainDescription:   building.Description.Main,
		BottomDescription: building.Description.Bottom,

		Image:     building.Image,
		StartedAt: building.StartedAt,
		EndedAt:   building.EndedAt,
		Type:      building.Type,
		Person:    *building.Person,
		Resources: building.Resources,
	}

	err := s.markerRepo.CreateMarker(newMarker)
	if err != nil {
		return err
	}

	newBuilding.Marker = newMarker

	err = s.buildingRepo.CreateBuilding(newBuilding)
	if err != nil {
		return err
	}

	return nil
}
