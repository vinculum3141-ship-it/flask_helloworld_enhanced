# Hello Flask on Kubernetes (Minikube + EKS Demo)

This project demonstrates how to:

* Build a simple Python/Flask app into a Docker container.
* Deploy it to a local Kubernetes cluster using Minikube.
* Run automated tests (unit + integration).
* Optionally, deploy to AWS EKS for cloud testing.

---

## **Key Takeaways (for a Test Engineer)**

| Area | Why It Matters |
|------|----------------|
| **Separation of concerns** | App code, infra manifests, and tests live independently. |
| **Automated testing** | Tests run at two levels (unit + Kubernetes). |
| **Reproducibility** | Scripts and Makefile create consistent local and CI environments. |
| **CI/CD integration** | GitHub Actions pipeline shows how to automate build, deploy, and validation. |
| **Cloud-readiness** | EKS config can reuse the same manifests. |

## CI/CD Workflow
### Workflow
1. Trigger: On push to feature branch
2. Setup: Python 3.11 + pip caching
3. Docker: Build with layer caching
4. Deploy: To Minikube (skip for PRs)
5. Test: Unit → K8s → Smoke tests
6. Security: Trivy vulnerability scan
7. Cleanup: Always runs, even on failure
8. Report: Detailed test results with GitHub annotations

### Features
1. Security & Permissions
    * Minimal permissions: Limited to only required GitHub token permissions
    * Environment variables: Centralized configuration for maintainability
    * Security scanning: Trivy vulnerability scanner running in parallel
    * SARIF upload: Integration with GitHub Security tab

2. Performance & Caching
    * Pip dependency caching: Automatic caching with actions/setup-python@v5
    * Docker layer caching: BuildX with layer caching to speed up image builds
    * Updated actions: Latest versions for better performance and security
    * Parallel jobs: Security scanning runs alongside main build-test job

3. Reliability & Resilience
    * Step timeouts: Individual timeouts prevent hung jobs
    * Job timeout: 30-minute global timeout for the entire job
    * Guaranteed cleanup: Always runs even if tests fail (if: always())
    * Deployment readiness: Waits for Kubernetes pods to be ready before testing

4. Workflow Triggers
    * Multi-branch support: main, develop, feature/**, hotfix/**
    * Pull request validation: Automatic testing on PRs to main branches
    * Manual dispatch: On-demand execution with configurable parameters
    * Conditional deployment: Skips deployment for PR builds

5. Error Handling & Reporting
    * Test result artifacts: Upload test reports, logs for debugging
    * Detailed status reporting: Clear summary with emojis and GitHub annotations
    * Continue-on-error: Tests don't block cleanup but still report failures
    * GitHub Annotations: ::error and ::notice messages in UI

6. Production-Ready Features
    * Environment-aware: Different behavior for test/staging/production
    * Resource management: Minikube configuration (2 CPU, 4GB RAM)
    * Comprehensive testing: Unit → K8s → Smoke tests in logical sequence
    * Artifact retention: 30-day retention for test results

## Step-by-step commands (run in a terminal)

### Pre-requisites
Configured Python environment
```
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies and validation tools
```
pip install -r flask-k8s/app/requirements.txt pytest requests yamllint
```

[Optional] Installed GitHub CLI for advanced validation
```
sudo apt install gh -y
```
For first time use, create a personal access token for your GitHub repository.
Then follow instruction from https://cli.github.com/manual/gh_auth_login

With the GitHub CLI pipeline workflows can be controlled and viewed in a terminal
* gh pr create --title 'Enhanced CI/CD Pipeline'
* gh workflow run ci-cd.yml
* gh run watch

Alternatively, follow the standard Git workflow
* git push origin test-workflow-structure
* Monitor via GitHub web interface → Actions tab

### Recommended dry-run strategy
Run validation scripts
```
# Repository validation
bash validate-repo-structure.sh

# Workflow validation
bash validate-workflow.sh
```

Local component testing
```
cd /home/ruby/Projects/courses/halloworldtestengineer/flask-k8s
./scripts/unit_tests.sh
./scripts/build_image.sh  
kubectl apply --dry-run=client -f k8s/
```

Checks for:
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

Push to GitHub
Create an isolated test branch
```
git checkout -b test-pipeline
```
Stage the workflow changes
```
git add .github/workflows/ci-cd.yml scripts/
```

Commit with descriptive message
```
git commit -m "feat: CI/CD pipeline with caching, security, and reliability"
```

Push to trigger workflow on feature branch
```
git push origin test-enhanced-pipeline
```

 Monitor execution in GitHub Actions tab
* Safe: Won't affect main/develop branches
* Real: Uses actual GitHub runners
* Complete: Tests entire pipeline end-to-end