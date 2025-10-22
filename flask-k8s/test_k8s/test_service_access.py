import subprocess, requests

def test_service_reachable():
    """Ensure the exposed service URL is responding."""
    url = subprocess.run(
        ["minikube", "service", "hello-flask", "--url"],
        capture_output=True, text=True
    ).stdout.strip()

    resp = requests.get(url)
    assert resp.status_code == 200
    assert "Hello" in resp.text
