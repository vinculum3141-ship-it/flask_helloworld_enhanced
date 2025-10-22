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
