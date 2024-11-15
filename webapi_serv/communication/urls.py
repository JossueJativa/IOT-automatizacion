from django.urls import path, include
from rest_framework import routers
from . import views

app_name = 'communication'

router = routers.DefaultRouter()

router.register('homeassistant', views.HomeAssistantViewSet)
router.register('devices', views.DevicesViewSet)
router.register('devicehistory', views.DeviceHistoryViewSet)
router.register('user', views.UserViewSet)

urlpatterns = [
    path('', include(router.urls)),
]