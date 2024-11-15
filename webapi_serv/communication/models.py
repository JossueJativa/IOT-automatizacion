from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.
class HomeAssistant(models.Model):
    url = models.CharField(max_length=100)
    token = models.CharField(max_length=100)

class DeviceHistory(models.Model):
    state = models.BooleanField()
    description = models.CharField(max_length=100, default='None')
    date = models.DateTimeField(auto_now_add=True)

class Devices(models.Model):
    name = models.CharField(max_length=50)
    homeassistant = models.ForeignKey(HomeAssistant, on_delete=models.CASCADE)
    history = models.ManyToManyField(DeviceHistory)

class User(AbstractUser):
    devices = models.ManyToManyField(Devices)
    tokenPhone = models.CharField(max_length=100)