"""Smallest Django project that serves JSON: no database, no sessions, no admin."""
import os

# Required: fail fast instead of shipping a default key.
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]
DEBUG = False
# The HEALTHCHECK calls 127.0.0.1, so it must stay in the list.
ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1").split(",")

ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"
INSTALLED_APPS = []
MIDDLEWARE = ["django.middleware.security.SecurityMiddleware"]
DATABASES = {}
USE_TZ = True
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
