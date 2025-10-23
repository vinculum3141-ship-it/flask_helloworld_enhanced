import subprocess

def test_configmap_applied():
    # Use list args to avoid shell quoting issues and ensure consistent behavior
    pod = subprocess.check_output(
        ["kubectl", "get", "pods", "-l", "app=hello-flask", "-o", "jsonpath={.items[0].metadata.name}"],
        text=True,
    ).strip()

    assert pod, "No pod found for label app=hello-flask"

    # Use the required '--' separator and pass the command as arguments
    env = subprocess.check_output(
        ["kubectl", "exec", pod, "--", "printenv", "APP_ENV"],
        text=True,
    ).strip()

    assert env == "local", f"Expected APP_ENV='local' but got: {env!r}"