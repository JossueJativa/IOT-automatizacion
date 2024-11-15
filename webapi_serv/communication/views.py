from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework_simplejwt.tokens import RefreshToken

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from django.contrib.auth import authenticate

from .models import *
from .serializer import *

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