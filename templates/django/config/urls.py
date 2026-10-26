from django.http import HttpResponse, JsonResponse
from django.urls import path

urlpatterns = [
    path("", lambda request: HttpResponse("Hello from Django\n")),
    path("health", lambda request: JsonResponse({"status": "ok"})),
]
