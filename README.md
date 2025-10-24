# Hello Flask on Kubernetes (Minikube + EKS Demo)

This project demonstrates how to:

* Build a simple Python/Flask app into a Docker container.
* Deploy it to a local Kubernetes cluster using Minikube.
* Run automated tests (unit + integration).
* Optionally, deploy to AWS EKS for cloud testing.

---

## Key Takeaways (for a Test Engineer)

| Area | Why It Matters |
|------|----------------|
| **Separation of concerns** | App code, infra manifests, and tests live independently. |
| **Automated testing** | Tests run at two levels (unit + Kubernetes). |
| **Reproducibility** | Scripts and Makefile create consistent local and CI environments. |
| **CI/CD integration** | GitHub Actions pipeline shows how to automate build, deploy, and validation. |
| **Cloud-readiness** | EKS config can reuse the same manifests. |

---

## Pre-Push validation Checklist

Optional, but it is recommended to do a dry-run of basic checks before pushing to the remote repo and kicking off a pipeline run.

Basic components to check:

* YAML syntax validation
* GitHub Actions schema validation
* Workflow structure analysis
* Environment variables check
* Action version verification
* Script existence and permissions
* Docker/Kubernetes configuration validation
* Test Python dependencies
* Test Docker build (if Docker is running)
* Validate Kubernetes manifests

**Pre-requisites**    
Configured Python environment, install dependencies and validation tools
```
python3 -m venv .venv
source .venv/bin/activate
pip install -r flask-k8s/app/requirements.txt pytest requests yamllint
```

**Run Validation Tests**    
For convenience these are captured in various validation scripts for easy execution
```
# Repository validation
bash validate-repo-structure.sh

# Workflow validation
bash validate-workflow.sh

# Local component testing
bash flask-k8s/scripts/unit_tests.sh
bash flask-k8s/scripts/build_image.sh  
kubectl apply --dry-run=client -f flask-k8s/k8s
```

---

## CI/CD Workflow
The current pipeline will trigger on every push to a feature branch as well as every PR

### Workflow
1. Setup: Python 3.11 
2. Docker: Build with layer caching
3. Deploy: To Minikube
4. Test: Unit → K8s → Smoke tests
5. Security: Trivy vulnerability scan
6. Cleanup: Always runs, even on failure
7. Report: Detailed test results with GitHub annotations

### Features
1. Security & Permissions
    * ✅ Minimal permissions
    * ✅ Environment variables centralized
    * ✅ Security scanning in parallel
    * ✅ SARIF upload to Security tab
2. Performance & Caching
    * ❌ Pip dependency caching
    * ❌ Docker layer caching
    * ✅ Updated actions
    * ✅ Parallel jobs
3. Reliability & Resilience
    * ✅ Step timeouts
    * ✅ Job timeout
    * ✅ Guaranteed cleanup
    * ✅ Deployment readiness wait
4. Workflow Triggers
    * ✅ Multi-branch support
    * ✅ Pull request validation
    * ✅ Manual dispatch with parameters
    * ✅ Conditional deployment for PRs
5. Error Handling & Reporting
    * ✅ Test result artifacts
    * ✅ Detailed status reporting
    * ✅ Continue-on-error for tests
    * ✅ GitHub annotations
6) Production-Ready Features
    * ⚠️ Environment-aware behavior
    * ✅ Resource management
    * ✅ Comprehensive testing sequence
    * ✅ Artifact retention

---

## [Optional] Run in a terminal

Installed GitHub CLI for advanced validation
```
sudo apt install gh -y
```
For first time use, create a personal access token for your GitHub repository.
Then follow instruction from https://cli.github.com/manual/gh_auth_login

With the GitHub CLI pipeline workflows can be controlled and viewed in a terminal
```
gh pr create --title 'Flask CI/CD Pipeline'
gh workflow run ci-cd.yml
gh run watch
```

To test and experiment with this interface:
* Create an isolated test branch
```
git checkout -b test-gh-pipeline
```
* Make an update to the workflow
* Stage, commit and push workflow change
```
git push origin test-gh-pipeline
```
* Push will trigger the automated workflow on the feature branch. 
* Monitor via GitHub web interface → Actions tab
* Execute the pipeline manually from the terminal (e.g.)
```
gh workflow run "Flask CI/CD Pipeline" --ref test-gh-pipeline --repo vinculum3141-ship-it/flask_helloworld_enhanced --field run_smoke_tests=true --field demo_message="Manual demo run"
```