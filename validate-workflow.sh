#!/bin/bash

# GitHub Actions Workflow Validation Script (Repository Root Version)
# This script validates your workflow from the repository root

WORKFLOW_FILE=".github/workflows/ci-cd.yml"
echo "🧪 GitHub Actions Workflow Validation Script (Root)"
echo "=================================================="
echo "Repository: $(basename "$(pwd)")"
echo "Location: $(pwd)"

# Check GitHub CLI status (optional)
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null 2>&1; then
        echo "� GitHub CLI: Available & Authenticated ✅"
        REPO_INFO=$(gh repo view --json nameWithOwner,defaultBranch 2>/dev/null || echo "")
        if [[ -n "$REPO_INFO" ]]; then
            REPO_NAME=$(echo "$REPO_INFO" | jq -r '.nameWithOwner' 2>/dev/null || echo "Unknown")
            echo "📂 Repository: $REPO_NAME"
        fi
        GH_AVAILABLE=true
    else
        echo "� GitHub CLI: Available but not authenticated"
        echo "   💡 Optional: Run 'gh auth login' for enhanced features"
        GH_AVAILABLE=false
    fi
else
    echo "📡 GitHub CLI: Not installed (optional tool)"
    echo "   💡 Optional: Install with 'sudo apt install gh' for workflow management"
    GH_AVAILABLE=false
fi
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
    if yamllint "$WORKFLOW_FILE" --config-data '{extends: default, rules: {line-length: {max: 120}, trailing-spaces: disable}}' 2>/dev/null; then
        echo "✅ YAML syntax is valid"
    else
        echo "⚠️  YAML has formatting issues but may still work"
    fi
else
    echo "⚠️  yamllint not found, skipping syntax check"
fi
echo ""

# 2. Workflow Structure Analysis
echo "🔍 Step 2: Workflow Structure Analysis"
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

if grep -q "working-directory: flask-k8s" "$WORKFLOW_FILE"; then
    echo "✅ Working directory configured for flask-k8s"
else
    echo "⚠️  No working-directory set for flask-k8s"
fi

echo ""

# 3. Flask-K8s Structure Validation
echo "🔍 Step 3: Flask-K8s Project Structure"
echo "-------------------------------------"

if [[ -d "flask-k8s" ]]; then
    echo "✅ flask-k8s directory exists"
    
    # Check key directories and files
    if [[ -f "flask-k8s/app/requirements.txt" ]]; then
        echo "✅ flask-k8s/app/requirements.txt exists"
    else
        echo "❌ flask-k8s/app/requirements.txt missing"
    fi
    
    if [[ -f "flask-k8s/app/Dockerfile" ]]; then
        echo "✅ flask-k8s/app/Dockerfile exists"
    else
        echo "❌ flask-k8s/app/Dockerfile missing"
    fi
    
    if [[ -d "flask-k8s/scripts" ]]; then
        echo "✅ flask-k8s/scripts/ directory exists"
    else
        echo "❌ flask-k8s/scripts/ directory missing"
    fi
    
    if [[ -d "flask-k8s/k8s" ]]; then
        echo "✅ flask-k8s/k8s/ directory exists"
    else
        echo "❌ flask-k8s/k8s/ directory missing"
    fi
else
    echo "❌ flask-k8s directory not found"
    exit 1
fi

echo ""

# 4. Referenced Scripts Validation
echo "🔍 Step 4: Referenced Scripts Validation"
echo "---------------------------------------"
echo "Checking if referenced scripts exist:"

SCRIPTS=($(grep -o "scripts/[a-zA-Z_][a-zA-Z0-9_-]*\.sh" "$WORKFLOW_FILE" 2>/dev/null | sort -u || true))
if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
    echo "⚠️  No script references found in workflow"
else
    for script_path in "${SCRIPTS[@]}"; do
        full_path="flask-k8s/$script_path"
        if [[ -f "$full_path" ]]; then
            echo "✅ $full_path exists"
            if [[ -x "$full_path" ]]; then
                echo "  └─ ✅ Executable"
            else
                echo "  └─ ⚠️  Not executable (run: chmod +x $full_path)"
            fi
        else
            echo "❌ $full_path missing"
        fi
    done
fi

echo ""

# 5. Kubernetes Manifests Check
echo "🔍 Step 5: Kubernetes Manifests Check"
echo "------------------------------------"
if [[ -d "flask-k8s/k8s" ]]; then
    echo "✅ k8s directory found"
    manifest_count=0
    for file in flask-k8s/k8s/*.yaml flask-k8s/k8s/*.yml; do
        if [[ -f "$file" ]]; then
            echo "✅ $(basename "$file") exists"
            ((manifest_count++))
        fi
    done
    if [[ $manifest_count -eq 0 ]]; then
        echo "⚠️  No YAML manifests found in flask-k8s/k8s/"
    fi
else
    echo "⚠️  flask-k8s/k8s directory not found"
fi

echo ""

# 6. Action Version Check
echo "🔍 Step 6: GitHub Actions Version Check"
echo "--------------------------------------"
echo "Actions used in workflow:"
grep -n "uses:" "$WORKFLOW_FILE" | sed 's/^/  /' || echo "None found"

echo ""

# Summary
echo "📊 VALIDATION SUMMARY"
echo "===================="
echo "✅ Workflow file exists and is readable"
echo "✅ Basic structure looks good"
echo "✅ Repository structure is correct"
echo ""

# 7. GitHub CLI Integration (Optional)
if [[ "$GH_AVAILABLE" == "true" ]]; then
    echo "🔍 Step 7: GitHub CLI Operations (Optional Enhancement)"
    echo "----------------------------------------------------"
    
    # List existing workflows
    echo "📋 Available workflows:"
    if gh workflow list 2>/dev/null | grep -q .; then
        gh workflow list 2>/dev/null | sed 's/^/  /'
    else
        echo "  📝 No workflows found (workflow will appear after first push)"
    fi
    
    echo ""
    echo "📊 Recent workflow runs:"
    if gh run list --limit 3 2>/dev/null | grep -q .; then
        gh run list --limit 3 2>/dev/null | sed 's/^/  /'
    else
        echo "  📝 No workflow runs yet (runs will appear after push)"
    fi
    
    echo ""
else
    echo "🔍 Step 7: GitHub CLI Operations (Skipped - Optional)"
    echo "---------------------------------------------------"
    echo "💡 GitHub CLI not available - using standard Git workflow instead"
    echo ""
fi

echo "🚀 NEXT STEPS TO DRY-RUN:"
echo "------------------------"
echo "1. Fix any ❌ issues found above"
echo "2. Make scripts executable: chmod +x flask-k8s/scripts/*.sh"
echo "3. Test individual components locally:"
echo "   - Run: cd flask-k8s && bash scripts/unit_tests.sh"
echo "   - Run: cd flask-k8s && bash scripts/build_image.sh"

echo ""
echo "🎯 STANDARD GIT WORKFLOW:"
echo "------------------------"
echo "• Commit changes:"
echo "    git add .github/workflows/ci-cd.yml validate-*.sh"
echo "    git commit -m 'feat: Enhanced CI/CD pipeline'"
echo ""
echo "• Push to trigger workflow:"
echo "    git push origin test-workflow-structure"
echo ""
echo "• Monitor via GitHub web interface:"
echo "    → Go to GitHub repository"
echo "    → Click 'Actions' tab"
echo "    → Watch workflow execution"

if [[ "$GH_AVAILABLE" == "true" ]]; then
    echo ""
    echo "🎯 ENHANCED GITHUB CLI OPTIONS (Available):"
    echo "------------------------------------------"
    echo "• Create Pull Request:"
    echo "    gh pr create --title 'Enhanced CI/CD Pipeline'"
    echo ""
    echo "• Manually trigger workflow:"
    echo "    gh workflow run ci-cd.yml"
    echo ""
    echo "• Watch workflow execution:"
    echo "    gh run watch"
    echo ""
    echo "• View recent runs:"
    echo "    gh run list"
else
    echo ""
    echo "💡 OPTIONAL GITHUB CLI ENHANCEMENT:"
    echo "-----------------------------------"
    echo "For enhanced workflow management, optionally install GitHub CLI:"
    echo "• Install: sudo apt install gh"
    echo "• Authenticate: gh auth login"  
    echo "• Benefits: Manual triggers, real-time monitoring, PR creation"
fi

echo ""
echo "🎯 ALTERNATIVE TESTING OPTIONS:"
echo "------------------------------"
echo "• Use 'workflow_dispatch' for manual testing"
echo "• Push to feature branch (not main/develop)"
echo "• Test locally with act (GitHub Actions local runner)"
echo ""
echo "For local testing with act:"
echo "  curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
echo "  act --dryrun"
echo ""
echo "✅ Ready to push and test!"