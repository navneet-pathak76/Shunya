from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_providers_shape():
    response = client.get("/v1/ai/providers")
    assert response.status_code == 200
    assert set(response.json()) == {"chatgpt", "gemini", "claude", "sunya"}

def test_google_auth_requires_configuration():
    response = client.post("/v1/auth/google", json={"id_token": "invalid"})
    assert response.status_code == 503
