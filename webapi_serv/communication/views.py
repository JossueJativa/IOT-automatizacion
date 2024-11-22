from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework_simplejwt.tokens import RefreshToken

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from django.contrib.auth import authenticate

from .models import *
from .serializer import *
import random
import requests

# Create your views here.
class HomeAssistantViewSet(viewsets.ModelViewSet):
    queryset = HomeAssistant.objects.all()
    serializer_class = HomeAssistantSerializer

class DeviceHistoryViewSet(viewsets.ModelViewSet):
    queryset = DeviceHistory.objects.all()
    serializer_class = DeviceHistorySerializer

class DevicesViewSet(viewsets.ModelViewSet):
    queryset = Devices.objects.all()
    serializer_class = DevicesSerializer

    # Get device by id
    def retrieve(self, request, *args, **kwargs):
        device_id = kwargs.get('pk')

        if not device_id:
            return Response({'error': 'Please provide a device id'}, status=400)
        
        device = Devices.objects.filter(id=device_id).first()

        if not device:
            return Response({'error': 'Device not found'}, status=404)
        
        data = [
            DeviceHistorySerializer(history).data
            for history in device.history.all()
        ]
        data = data[::-1]

        return Response({
            'device': DevicesSerializer(device).data,
            'history': data
        }, status=200)
    
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter(
                'device_id',
                openapi.IN_QUERY,
                description="ID del dispositivo para generar consumo de energía",
                type=openapi.TYPE_INTEGER,
                required=True
            )
        ],
        responses={
            200: openapi.Response('Energía generada con éxito'),
            400: openapi.Response('Solicitud incorrecta'),
            404: openapi.Response('Dispositivo no encontrado'),
        }
    )
    @action(detail=False, methods=['get'])
    def generate_energy(self, request, *args, **kwargs):
        try:
            device_id = int(request.query_params.get('device_id', 0))
        except ValueError:
            return Response({'error': 'El ID del dispositivo debe ser un número entero'}, status=400)

        if not device_id:
            return Response({'error': 'Proporcione un ID de dispositivo'}, status=400)

        device = Devices.objects.filter(id=device_id).first()

        if not device:
            return Response({'error': 'Dispositivo no encontrado'}, status=404)

        energy_hour = {i: random.randint(0, 100) for i in range(24)}

        return Response({'message': 'Energía generada con éxito', 'energy_hour': energy_hour}, status=200)
    
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter(
                'homeassistant_id',
                openapi.IN_QUERY,
                description="ID del Home Assistant para obtener dispositivos",
                type=openapi.TYPE_INTEGER,
                required=True
            )
        ],
        responses={
            200: openapi.Response('Dispositivos obtenidos con éxito'),
            400: openapi.Response('Solicitud incorrecta'),
            404: openapi.Response('Home Assistant no encontrado'),
            500: openapi.Response('Error al obtener dispositivos')
        }
    )
    @action(detail=False, methods=['get'])
    def get_devices(self, request, *args, **kwargs):
        homeassistant_id = request.query_params.get('homeassistant_id')

        if not homeassistant_id:
            return Response({'error': 'Please provide a homeassistant_id'}, status=400)

        homeassistant = HomeAssistant.objects.filter(id=homeassistant_id).first()

        if not homeassistant:
            return Response({'error': 'HomeAssistant not found'}, status=404)

        # Configuración para la solicitud a la API de Home Assistant
        headers = {
            'Authorization': f"Bearer {homeassistant.token}",
            'Content-Type': 'application/json'
        }
        url = f"{homeassistant.url}/api/states"

        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            return Response({'error': str(e)}, status=500)

        # Filtrar dispositivos de tipo "button" o "switch"
        all_devices = response.json()
        button_switch_devices = [
            device for device in all_devices
            if device.get('entity_id', '').startswith(('button.', 'switch.'))
        ]

        return Response({'devices': button_switch_devices}, status=200)
    
    @swagger_auto_schema(
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'type': openapi.Schema(type=openapi.TYPE_STRING),
                'domain': openapi.Schema(type=openapi.TYPE_STRING),
                'service': openapi.Schema(type=openapi.TYPE_STRING),
                'service_data': openapi.Schema(type=openapi.TYPE_OBJECT),
                'homeassistant_id': openapi.Schema(type=openapi.TYPE_INTEGER)
            }
        ),
        responses={
            200: openapi.Response('Servicio llamado con éxito'),
            400: openapi.Response('Solicitud incorrecta'),
            404: openapi.Response('Home Assistant no encontrado'),
            500: openapi.Response('Error al llamar al servicio')
        }
    )
    @action(detail=False, methods=['post'])
    def call_service(self, request, *args, **kwargs):
        data = request.data

        if not data:
            return Response({'error': 'Please provide a data'}, status=400)
        
        homeassistant = HomeAssistant.objects.filter(id=data.get('homeassistant_id')).first()

        if not homeassistant:
            return Response({'error': 'HomeAssistant not found'}, status=404)
        
        # Configuración para la solicitud a la API de Home Assistant
        headers = {
            'Authorization': f"Bearer {homeassistant.token}",
            'Content-Type': 'application/json'
        }
        url = f"{homeassistant.url}/api/services/{data.get('domain')}/{data.get('service')}"

        try:
            response = requests.post(url, headers=headers, json=data.get('service_data'))
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            return Response({'error': str(e)}, status=500)
        
        return Response({'message': 'Service called successfully'}, status=200)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    @swagger_auto_schema(
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'username': openapi.Schema(type=openapi.TYPE_STRING),
                'email': openapi.Schema(type=openapi.TYPE_STRING),
                'password': openapi.Schema(type=openapi.TYPE_STRING),
                'confirm': openapi.Schema(type=openapi.TYPE_STRING),
                'tokenPhone': openapi.Schema(type=openapi.TYPE_STRING)
            }
        ),
        responses={200: 'OK', 400: 'Bad Request'}
    )
    def create(self, request):
        username = request.data.get('username')
        email = request.data.get('email')
        password = request.data.get('password')
        confirm = request.data.get('confirm')
        tokenPhone = request.data.get('tokenPhone')

        if not username or not email or not password or not confirm or not tokenPhone:
            return Response({'error': 'Please fill all fields'}, status=400)
        
        if password != confirm:
            return Response({'error': 'Passwords do not match'}, status=400)

        try:
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password,
                tokenPhone=tokenPhone
            )
            user.save()

            if user:
                refresh = RefreshToken.for_user(user)
                return Response({
                    'refresh': str(refresh),
                    'access': str(refresh.access_token)
                }, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=400)
        
    @swagger_auto_schema(
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'username': openapi.Schema(type=openapi.TYPE_STRING),
                'password': openapi.Schema(type=openapi.TYPE_STRING)
            }
        ),
        responses={200: 'OK', 400: 'Bad Request'}
    )
    @action(detail=False, methods=['post'])
    def login(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return Response({'error': 'Se necesitan todos los campos llenos'}, status=400)
        
        user = authenticate(username=username, password=password)
        
        if user:
            return Response({
                'refresh': str(RefreshToken.for_user(user)),
                'access': str(RefreshToken.for_user(user).access_token)
            }, status=200)
        else:
            return Response({'error': 'Credenciales incorrectas'}, status=400)