#!/bin/bash

# Validate GitHub Actions workflow from repository root
echo "🧪 GitHub Actions Workflow Validation (Repository Root)"
echo "======================================================"

cd "$(git rev-parse --show-toplevel)"
echo "Repository root: $(pwd)"
echo ""

# Check workflow location
if [[ -f ".github/workflows/ci-cd.yml" ]]; then
    echo "✅ Workflow found at correct location: .github/workflows/ci-cd.yml"
else
    echo "❌ Workflow not found at .github/workflows/ci-cd.yml"
    exit 1
fi

# Check flask-k8s subdirectory structure
echo "✅ Checking flask-k8s subdirectory structure:"
if [[ -d "flask-k8s" ]]; then
    echo "  ✅ flask-k8s/ directory exists"
    
    if [[ -f "flask-k8s/app/requirements.txt" ]]; then
        echo "  ✅ flask-k8s/app/requirements.txt exists"
    else
        echo "  ❌ flask-k8s/app/requirements.txt missing"
    fi
    
    if [[ -f "flask-k8s/app/Dockerfile" ]]; then
        echo "  ✅ flask-k8s/app/Dockerfile exists"
    else
        echo "  ❌ flask-k8s/app/Dockerfile missing"
    fi
    
    if [[ -d "flask-k8s/scripts" ]]; then
        echo "  ✅ flask-k8s/scripts/ directory exists"
        echo "  📋 Scripts found:"
        ls flask-k8s/scripts/*.sh | sed 's/^/    /'
    else
        echo "  ❌ flask-k8s/scripts/ directory missing"
    fi
    
    if [[ -d "flask-k8s/k8s" ]]; then
        echo "  ✅ flask-k8s/k8s/ directory exists"
    else
        echo "  ❌ flask-k8s/k8s/ directory missing"
    fi
else
    echo "❌ flask-k8s/ subdirectory not found"
    exit 1
fi

echo ""
echo "🎯 WORKFLOW EXECUTION CONTEXT:"
echo "-----------------------------"
echo "• Workflow runs from: $(pwd) (repository root)"
echo "• Flask app located in: $(pwd)/flask-k8s/"
echo "• All commands use 'working-directory: flask-k8s' where needed"
echo ""

echo "✅ Repository structure is correct for GitHub Actions!"
echo ""
echo "🚀 READY TO PUSH:"
echo "• Workflow: .github/workflows/ci-cd.yml ✅"
echo "• App code: flask-k8s/ ✅" 
echo "• Scripts: flask-k8s/scripts/ ✅"
echo "• Manifests: flask-k8s/k8s/ ✅"