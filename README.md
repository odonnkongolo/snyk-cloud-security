# 🛡️ AI-Enhanced DevSecOps Pipeline (Snyk Integration)

## 🚀 Architecture Overview
This repository demonstrates the integration of an industry-standard, AI-enhanced security engine (Snyk) directly into a GitHub Actions Continuous Integration (CI) pipeline. Moving beyond traditional regex-based SAST scanners, this architecture utilises Snyk Code AI and Snyk IaC to perform semantic analysis, predict logic flaws, and enforce strict infrastructure hygiene prior to cloud deployment.

## 🛠️ Tech Stack
* **CI/CD Orchestration:** GitHub Actions
* **AI Security Engine:** Snyk (Code & Infrastructure as Code)
* **Application:** Python / Flask (containerised via Docker)
* **Container Registry:** Amazon ECR
* **Infrastructure:** Terraform (AWS EKS, VPC, IAM, KMS)
* **Container Orchestration:** Kubernetes (Amazon EKS)

## 🏗️ Core Engineering Mechanics
1. **Static Code Checks Gate:** Upon every push to `main`, the pipeline runs Ruff, Flake8, and Bandit against the Python application, TFLint against all Terraform HCL files, and Trivy for container filesystem scanning. These checks must all pass before any Snyk scan is triggered.
2. **AI Application Logic Scan:** Snyk Code performs semantic, ML-powered static analysis of the Python application source — detecting injection risks, hardcoded secrets, and insecure patterns using Snyk's machine learning models.
3. **Infrastructure Posture Scan:** Snyk IaC scans all Terraform (`.tf`) and Kubernetes (`.yaml`) configuration files to intercept misconfigurations (e.g., exposed ports, unencrypted volumes) before they are provisioned in AWS.
4. **Deployment & Enforcement:** Only if all security gates pass cleanly, the application is containerised, pushed to ECR, and deployed to the EKS cluster. If any High or Critical vulnerability is detected, the pipeline returns a non-zero exit code, neutralizing the deployment.

## 📂 Repository Structure
* `/app`: Contains the Python Flask application code and dependencies (`requirements.txt`).
* `/infrustructure`: Contains the Terraform configuration mapping out the VPC, EKS cluster, node groups, and IAM execution roles.
* `/kubernetes`: Contains the Kubernetes manifest (`prod-flask-app.yaml`) defining the Deployment and Service configurations.
* `/.github/workflows`: Contains the CI/CD pipeline automation workflows defining the strict security gates and deployment process.

## 🚀 Incident Response & Remediation Runbook

**1. Intercepting Infrastructure Misconfigurations:**
The initial GitHub Actions run failed during the Snyk IaC scan, flagging a high-severity public access vulnerability.

```bash
# SNYK-CC-TF-94: EKS API endpoint publicly accessible
# Remediation applied to infrustructure/eks.tf:
endpoint_public_access = false
endpoint_private_access = true
```

**2. Hardening Kubernetes Workloads:**
Identified several low-to-medium severity vulnerabilities in the Kubernetes deployment via Snyk IaC. Applied strict security contexts to mitigate privilege escalation and container breakout risks:

```yaml
# Remediation applied to kubernetes/prod-flask-app.yaml:
readOnlyRootFilesystem: true
allowPrivilegeEscalation: false
runAsNonRoot: true
runAsUser: 1000
capabilities:
  drop:
    - ALL
```

**3. Automated Remediation of Transitive Dependencies:**
The Snyk Cloud Console identified a residual Medium vulnerability (`CVE-2024-5569` in `zipp@3.15.0`) via the dashboard's AI-generated priority scoring. Pinned the safe version to override the transitive dependency.

```text
# Fixed in zipp@3.19.1 (SNYK-PYTHON-ZIPP-7430899)
# Remediation applied to app/requirements.txt:
zipp>=3.19.1
```

## 📸 Security Posture Evidence
<img alt="Snyk IaC scan output showing 1 high severity EKS public access finding before remediation" src="images/Screenshot%202026-06-15%20at%2021.27.03.png" />
<img alt="Snyk Cloud Console showing all 8 scanned project files with severity breakdown" src="images/Screenshot%202026-06-15%20at%2021.28.12.png" />
<img alt="Snyk dashboard showing zipp@3.15.0 infinite loop vulnerability with priority score 666 and fix recommendation" src="images/Screenshot%202026-06-15%20at%2021.54.51.png" />
<img alt="GitHub Actions log showing Snyk Code scan completed with 0 total issues" src="images/Screenshot%202026-06-15%20at%2022.03.10.png" />
<img alt="GitHub Actions log showing Snyk IaC scan completed with 0 critical, 0 high, 0 medium, 0 low issues" src="images/Screenshot%202026-06-15%20at%2022.03.52.png" />
<img alt="Snyk Cloud Console showing all 8 project files with 0 Critical, 0 High, 0 Medium findings after full remediation" src="images/Screenshot%202026-06-15%20at%2023.45.50.png" />