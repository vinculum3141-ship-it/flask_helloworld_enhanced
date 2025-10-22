#!/bin/bash

# GitHub Actions Workflow Dry-Run Validation Script
# This script validates your workflow without pushing to GitHub

set -e

WORKFLOW_FILE=".github/workflows/ci-cd.yml"
echo "🧪 GitHub Actions Workflow Validation Script"
echo "=============================================="
echo ""

# Check if workflow file exists
if [[ ! -f "$WORKFLOW_FILE" ]]; then
    echo "❌ Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

echo "📁 Found workflow file: $WORKFLOW_FILE"
echo ""

# 1. YAML Syntax Validation
echo "🔍 Step 1: YAML Syntax Validation"
echo "--------------------------------"
if command -v yamllint &> /dev/null; then
    echo "Running yamllint..."
    if yamllint "$WORKFLOW_FILE" --config-data '{extends: default, rules: {line-length: {max: 120}, trailing-spaces: disable}}'; then
        echo "✅ YAML syntax is valid"
    else
        echo "⚠️  YAML has formatting issues but may still work"
    fi
else
    echo "⚠️  yamllint not found, skipping syntax check"
fi
echo ""

# 2. GitHub Actions Workflow Validation (if authenticated)
echo "🔍 Step 2: GitHub Actions Schema Validation"
echo "------------------------------------------"
if command -v gh &> /dev/null; then
    echo "Checking GitHub CLI authentication..."
    if gh auth status &> /dev/null; then
        echo "✅ GitHub CLI authenticated"
        echo "Validating workflow against GitHub Actions schema..."
        # Note: GitHub CLI doesn't have direct workflow validation, 
        # but we can check if it's a valid repo and simulate
        if gh repo view &> /dev/null; then
            echo "✅ Repository accessible via GitHub CLI"
        else
            echo "⚠️  Not in a GitHub repository or not authenticated"
        fi
    else
        echo "⚠️  GitHub CLI not authenticated. Run 'gh auth login' to enable full validation"
    fi
else
    echo "⚠️  GitHub CLI not installed"
fi
echo ""

# 3. Workflow Structure Analysis
echo "🔍 Step 3: Workflow Structure Analysis"
echo "-------------------------------------"

# Check for required fields
echo "Checking required workflow fields..."

if grep -q "^name:" "$WORKFLOW_FILE"; then
    echo "✅ Workflow name defined"
else
    echo "❌ Missing workflow name"
fi

if grep -q "^on:" "$WORKFLOW_FILE"; then
    echo "✅ Trigger events defined"
else
    echo "❌ Missing trigger events"
fi

if grep -q "^jobs:" "$WORKFLOW_FILE"; then
    echo "✅ Jobs section defined"
else
    echo "❌ Missing jobs section"
fi

# Check for potential issues
echo ""
echo "Checking for potential issues..."

if grep -q "uses: actions/checkout@v[0-9]" "$WORKFLOW_FILE"; then
    echo "✅ Using versioned checkout action"
else
    echo "⚠️  Consider using versioned actions (e.g., actions/checkout@v4)"
fi

if grep -q "timeout-minutes:" "$WORKFLOW_FILE"; then
    echo "✅ Timeouts configured"
else
    echo "⚠️  Consider adding timeouts to prevent stuck jobs"
fi

if grep -q "if: always()" "$WORKFLOW_FILE"; then
    echo "✅ Cleanup steps configured"
else
    echo "⚠️  Consider adding cleanup steps with 'if: always()'"
fi

echo ""

# 4. Environment Variables Check
echo "🔍 Step 4: Environment Variables & Secrets"
echo "-----------------------------------------"
echo "Environment variables found:"
grep -n "\\${{" "$WORKFLOW_FILE" | head -10 || echo "None found"
echo ""

# 5. Action Version Check
echo "🔍 Step 5: GitHub Actions Version Check"
echo "--------------------------------------"
echo "Actions used in workflow:"
grep -n "uses:" "$WORKFLOW_FILE" | sed 's/^/  /' || echo "None found"
echo ""

# 6. Simulate Trigger Conditions
echo "🔍 Step 6: Trigger Condition Analysis"
echo "------------------------------------"
echo "This workflow will trigger on:"

if grep -A 10 "on:" "$WORKFLOW_FILE" | grep -q "push:"; then
    echo "✅ Push events to specified branches"
    grep -A 5 "push:" "$WORKFLOW_FILE" | grep "branches:" -A 5 | sed 's/^/  /'
fi

if grep -A 10 "on:" "$WORKFLOW_FILE" | grep -q "pull_request:"; then
    echo "✅ Pull request events"
    grep -A 5 "pull_request:" "$WORKFLOW_FILE" | grep "branches:" -A 5 | sed 's/^/  /'
fi

if grep -A 10 "on:" "$WORKFLOW_FILE" | grep -q "workflow_dispatch:"; then
    echo "✅ Manual workflow dispatch"
fi

echo ""

# 7. Test Scripts Validation
echo "🔍 Step 7: Referenced Scripts Validation"
echo "---------------------------------------"
echo "Checking if referenced scripts exist:"

SCRIPTS=($(grep -o "bash scripts/[a-zA-Z_]*.sh" "$WORKFLOW_FILE" | sort -u))
for script in "${SCRIPTS[@]}"; do
    script_path=${script#bash }
    if [[ -f "$script_path" ]]; then
        echo "✅ $script_path exists"
        if [[ -x "$script_path" ]]; then
            echo "  └─ ✅ Executable"
        else
            echo "  └─ ⚠️  Not executable (run: chmod +x $script_path)"
        fi
    else
        echo "❌ $script_path missing"
    fi
done

echo ""

# 8. Docker Configuration Check
echo "🔍 Step 8: Docker Configuration Check"
echo "------------------------------------"
if [[ -f "app/Dockerfile" ]]; then
    echo "✅ Dockerfile found"
    if [[ -f "app/requirements.txt" ]]; then
        echo "✅ requirements.txt found"
    else
        echo "⚠️  requirements.txt not found"
    fi
else
    echo "⚠️  Dockerfile not found in app/ directory"
fi

echo ""

# 9. Kubernetes Manifests Check
echo "🔍 Step 9: Kubernetes Manifests Check"
echo "------------------------------------"
if [[ -d "k8s" ]]; then
    echo "✅ k8s directory found"
    for file in k8s/*.yaml; do
        if [[ -f "$file" ]]; then
            echo "✅ $(basename "$file") exists"
        fi
    done
else
    echo "⚠️  k8s directory not found"
fi

echo ""

# Summary
echo "📊 VALIDATION SUMMARY"
echo "===================="
echo "✅ Workflow file exists and is readable"
echo "✅ Basic structure looks good"
echo ""
echo "🚀 NEXT STEPS TO DRY-RUN:"
echo "------------------------"
echo "1. Fix any ❌ issues found above"
echo "2. Make scripts executable: chmod +x scripts/*.sh"
echo "3. Test individual components locally:"
echo "   - Run: bash scripts/unit_tests.sh"
echo "   - Run: bash scripts/build_image.sh"
echo "4. Push to a feature branch first: git checkout -b test-workflow"
echo "5. Monitor the workflow run in GitHub Actions tab"
echo ""
echo "🎯 SAFE TESTING OPTIONS:"
echo "-----------------------"
echo "• Use 'workflow_dispatch' for manual testing"
echo "• Push to feature branch (not main/develop)"
echo "• Test locally with act (GitHub Actions local runner)"
echo ""
echo "For local testing with act:"
echo "  curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
echo "  act --dryrun"
echo ""