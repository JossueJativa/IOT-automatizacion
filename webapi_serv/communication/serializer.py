from rest_framework import serializers
from .models import *

class HomeAssistantSerializer(serializers.ModelSerializer):
    class Meta:
        model = HomeAssistant
        fields = '__all__'

class DeviceHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceHistory
        fields = '__all__'

class DevicesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Devices
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'