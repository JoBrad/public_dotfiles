#!/usr/bin/env bash


# Azure CLI Profile Manager
# This script was originally created by Austin Maddox (Thanks!)
#
# Manages multiple Azure CLI login profiles with different tenants, subscriptions, and cloud environments
# Add to your .bashrc or .zshrc to make it easier to switch between profiles, example:
#   alias azp="source ~/.azure-profiles/azure-profile-manager.sh"

__azp_is_sourced() {
  _is_sourced=0
  if [ -n "${BASH_VERSION-}" ]; then
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] && _is_sourced=1
  elif [ -n "${ZSH_VERSION-}" ]; then
    # shellcheck disable=SC2296
    (( zsh_eval_context[(I)file] )) && _is_sourced=1
  fi
  echo "$_is_sourced"
}

__azp_terminate() {
  local exit_code="${1:-0}"
  if __azp_is_sourced; then
    return "${exit_code}"
  else
    exit "${exit_code}"
  fi
}

show_help() {
    cat << EOF
Azure CLI Profile Manager

USAGE:
    $0 <command> [arguments]

COMMANDS:
    add <name> <tenant> <subscription> <cloud>  Add a new profile
    remove <name>                               Remove a profile
    list                                        List all profiles
    switch <name>                              Switch to a profile
    interactive                                Interactive profile selection
    current                                    Show current Azure CLI context
    help                                       Show this help message

ARGUMENTS:
    name          Profile name (e.g., dev-someproject, prod-someproject)
    tenant        Azure tenant ID (GUID)
    subscription  Azure subscription ID (GUID)
    cloud         Cloud environment: pub, public, gov, government

EXAMPLES:
    # Add a new profile for development environment
    $0 add dev-someproject "43a7c7cb-e2a7-4186-8cf7-335e83a59624" "d0359952-27be-4d84-ae0f-ecc3299c546d" pub

    # Add a profile for government cloud
    $0 add prod-someproject "fd85bccc-c571-4c42-ac66-b3928099ae25" "4f02fea2-2757-49bc-924d-d0e5ff1ab8a2" gov

    # List all configured profiles
    $0 list

    # Switch to a specific profile (automatically exports ARM_TENANT_ID and ARM_SUBSCRIPTION_ID)
    $0 switch dev-someproject

    # Interactive profile selection
    $0 interactive

    # Show current Azure CLI context
    $0 current

ENVIRONMENT VARIABLES:
    DEBUG=1             Enable debug output

CONFIGURATION:
    Profiles are stored in: $PROFILES_CONFIG

EOF
}

# Returns the configuration path for Azure profile manager configuration
_get_az_profiles_dir() {
    echo "${XDG_CONFIG_HOME:-$HOME/.config}/.azure-profiles"
}


# Creates the configuration path and file for Azure profile manager, if it does not exist.
_mk_az_profiles_dir() {
    local profile_dir=$(_get_az_profiles_dir)
    if [[ ! -d "${profile_dir}" ]];
    then
        mkdir -p "${profile_dir}"
        echo '{}' > "${profile_dir}/profiles.json"
    fi
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script config file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR=$(_get_az_profiles_dir)
PROFILES_CONFIG="$CONFIG_DIR/profiles.json"

# Create && init config directory if it doesn't exist
_mk_az_profiles_dir

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_debug() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# ===============================
# Supporting Functions

check_dependencies() {
    local missing_deps=()

    if ! command -v az &> /dev/null; then
        missing_deps+=("azure-cli")
    fi

    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Please install them and try again."
        exit 1
    fi
}

set_cloud_environment() {
    local cloud_env="$1"

    case "$cloud_env" in
        "pub"|"public"|"AzureCloud")
            print_debug "Setting cloud environment to Azure Public Cloud"
            az cloud set --name AzureCloud &>/dev/null
            ;;
        "gov"|"government"|"AzureUSGovernment")
            print_debug "Setting cloud environment to Azure US Government"
            az cloud set --name AzureUSGovernment &>/dev/null
            ;;
        *)
            print_error "Unknown cloud environment: $cloud_env"
            print_error "Supported environments: pub, public, gov, government"
            return 1
            ;;
    esac
}

add_profile() {
    local profile_name="$1"
    local tenant_id="$2"
    local subscription_id="$3"
    local cloud_env="$4"

    if [[ -z "$profile_name" || -z "$tenant_id" || -z "$subscription_id" || -z "$cloud_env" ]]; then
        print_error "Usage: add_profile <profile_name> <tenant_id> <subscription_id> <cloud_environment>"
        print_error "Cloud environments: AzureCloud (public/pub) or AzureUSGovernment (government/gov)"
        return 1
    fi

    # Validate cloud environment
    case "$cloud_env" in
        "pub"|"gov"|"public"|"government"|"AzureCloud"|"AzureUSGovernment")
            ;;
        *)
            print_error "Invalid cloud environment: $cloud_env"
            print_error "Supported environments: AzureCloud (public/pub) or AzureUSGovernment (government/gov)"
            return 1
            ;;
    esac

    # Normalize cloud environment name
    case "$cloud_env" in
        "pub"|"public"|"AzureCloud")
            cloud_env="AzureCloud"
            ;;
        "gov"|"government"|"AzureUSGovernment")
            cloud_env="AzureUSGovernment"
            ;;
    esac

    # Check if profile already exists
    if jq -e ".\"$profile_name\"" "$PROFILES_CONFIG" > /dev/null 2>&1; then
        print_warning "Profile '$profile_name' already exists. Updating..."
    fi

    # Add/update profile in config
    jq --arg name "$profile_name" \
       --arg tenant "$tenant_id" \
       --arg subscription "$subscription_id" \
       --arg cloud "$cloud_env" \
       '.[$name] = {
           "tenant_id": $tenant,
           "subscription_id": $subscription,
           "cloud_environment": $cloud
       }' "$PROFILES_CONFIG" > "$PROFILES_CONFIG.tmp"

    cat "$PROFILES_CONFIG.tmp" > "$PROFILES_CONFIG"
    rm "$PROFILES_CONFIG.tmp"

    print_status "Profile '$profile_name' added successfully"
    print_status "  Tenant ID: $tenant_id"
    print_status "  Subscription ID: $subscription_id"
    print_status "  Cloud Environment: $cloud_env"
}

remove_profile() {
    local profile_name="$1"

    if [[ -z "$profile_name" ]]; then
        print_error "Usage: remove_profile <profile_name>"
        return 1
    fi

    # Check if profile exists
    if ! jq -e ".\"$profile_name\"" "$PROFILES_CONFIG" > /dev/null 2>&1; then
        print_error "Profile '$profile_name' does not exist"
        return 1
    fi

    # Remove profile from config
    jq "del(.\"$profile_name\")" "$PROFILES_CONFIG" > "$PROFILES_CONFIG.tmp"
    mv "$PROFILES_CONFIG.tmp" "$PROFILES_CONFIG"

    print_status "Profile '$profile_name' removed successfully"
}

list_profiles() {
    local current_subscription=""
    local current_tenant=""

    # Try to get current Azure CLI context (single az cli call)
    if account_info=$(az account show --query '{id:id, tenantId:tenantId}' -o tsv 2>/dev/null); then
        read -r current_subscription current_tenant <<< "$account_info"
    fi

    print_status "Available Azure CLI Profiles:"
    echo

    if [[ $(jq 'length' "$PROFILES_CONFIG") -eq 0 ]]; then
        print_warning "No profiles configured"
        return 0
    fi

    # Print table header for pretty output
    printf "%-20s %-15s %-38s %-38s %s\n" "PROFILE" "CLOUD" "TENANT ID" "SUBSCRIPTION ID" "STATUS"
    printf "%-20s %-15s %-38s %-38s %s\n" "-------" "-----" "---------" "---------------" "------"

    # List profiles
    jq -r 'to_entries[] | "\(.key)|\(.value.cloud_environment)|\(.value.tenant_id)|\(.value.subscription_id)"' "$PROFILES_CONFIG" | \
    while IFS='|' read -r name cloud tenant subscription; do
        local profile_status=""
        if [[ "$subscription" == "$current_subscription" && "$tenant" == "$current_tenant" ]]; then
            profile_status="* ACTIVE"
        fi

        printf "%-20s %-15s %-38s %-38s %s\n" "$name" "$cloud" "$tenant" "$subscription" "$profile_status"
    done
}

switch_profile() {
    local profile_name="$1"

    local export="no"
    if [[ "$2" == "--export-arm" ]];
    then
        export="arm"
    elif [[ "$2" == "--export-az" ]];
    then
        export="az"
    fi

    if [[ -z "$profile_name" ]]; then
        print_error "Usage: switch_profile <profile_name> <export_option>"
        return 1
    fi

    # Check if profile exists
    if ! jq -e ".\"$profile_name\"" "$PROFILES_CONFIG" > /dev/null 2>&1; then
        print_error "Profile '$profile_name' does not exist"
        print_status "Available profiles:"
        list_profiles
        return 1
    fi

    # Get profile deets
    local tenant_id=$(jq -r ".\"$profile_name\".tenant_id" "$PROFILES_CONFIG")
    local subscription_id=$(jq -r ".\"$profile_name\".subscription_id" "$PROFILES_CONFIG")
    local cloud_env=$(jq -r ".\"$profile_name\".cloud_environment" "$PROFILES_CONFIG")

    print_debug "Switching to profile: $profile_name"
    print_debug "  Tenant ID: $tenant_id"
    print_debug "  Subscription ID: $subscription_id"
    print_debug "  Cloud Environment: $cloud_env"

    print_debug "Setting cloud environment..."
    if ! set_cloud_environment "$cloud_env"; then
        print_error "Failed to set cloud environment"
        return 1
    fi

    if [[ "${export}" == "arm" ]];
    then
        export ARM_TENANT_ID="$tenant_id"
        export ARM_SUBSCRIPTION_ID="$subscription_id"
        echo "Exported ARM environment variables:"
        echo "  ARM_TENANT_ID: $ARM_TENANT_ID"
        echo "  ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
    elif [[ "${export}" == "az" ]];
    then
        export AZURE_TENANT_ID="$tenant_id"
        export AZURE_SUBSCRIPTION_ID="$subscription_id"
        echo "Exported Azure CLI environment variables:"
        echo "  AZURE_TENANT_ID: $AZURE_TENANT_ID"
        echo "  AZURE_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID"
    fi

    print_debug "Logging in to Azure..."

    # Login with auto-dismiss of interactive prompts
    if ! printf "\n" | az login --tenant "$tenant_id" --allow-no-subscriptions > /dev/null 2>&1; then
        print_error "Failed to login to Azure"
        return 1
    fi

    # Set subscription (this will be the definitive subscription setting)
    print_debug "Setting subscription..."
    if ! az account set --subscription "$subscription_id" --only-show-errors --output none; then
        print_error "Failed to set subscription: $subscription_id"
        print_warning "You may not have access to this subscription or it may not exist"
        return 1
    fi

    # Verify the switch was successful (single az cli call for account info)
    local current_subscription="" current_tenant="" current_subscription_name="" current_cloud=""
    if account_info=$(az account show --query '{id:id, tenantId:tenantId, name:name, environmentName:environmentName}' -o tsv 2>/dev/null); then
        read -r current_subscription current_tenant current_subscription_name current_cloud <<< "$account_info"
    fi

    if [[ "$current_subscription" == "$subscription_id" && "$current_tenant" == "$tenant_id" ]]; then
        print_status "Successfully switched to profile: $profile_name"
        print_status "Current context:"
        print_status "  Subscription: $current_subscription_name ($current_subscription)"
        print_status "  Tenant: $current_tenant"
        print_status "  Cloud: $current_cloud"
    else
        print_error "Profile switch verification failed"
        return 1
    fi
}

show_current() {
    print_status "Current Azure CLI Context:"

    # Get account info in single az cli call
    local current_subscription="" current_tenant="" current_subscription_name=""
    if account_info=$(az account show --query '{id:id, tenantId:tenantId, name:name}' -o tsv 2>/dev/null); then
        read -r current_subscription current_tenant current_subscription_name <<< "$account_info"
    else
        print_warning "Not logged in to Azure CLI"
        return 0
    fi

    local current_cloud=$(az cloud show --query name -o tsv 2>/dev/null || echo "")

    echo "  Subscription: $current_subscription_name ($current_subscription)"
    echo "  Tenant: $current_tenant"
    echo "  Cloud: $current_cloud"

    # Check if current context matches any profile
    local matching_profile=""
    if [[ -f "$PROFILES_CONFIG" ]]; then
        matching_profile=$(jq -r "to_entries[] | select(.value.subscription_id == \"$current_subscription\" and .value.tenant_id == \"$current_tenant\") | .key" "$PROFILES_CONFIG" | head -1)
    fi

    if [[ -n "$matching_profile" ]]; then
        echo "  Profile: $matching_profile"
    else
        echo "  Profile: (not managed by profile manager)"
    fi
}

interactive_switch() {
    local profiles_array=()
    local profile_count=0

    print_debug "Starting interactive profile selection"

    if [[ ! -f "$PROFILES_CONFIG" ]]; then
        print_error "Profiles configuration file not found: $PROFILES_CONFIG"
        return 1
    fi

    local profile_length
    profile_length=$(jq 'length' "$PROFILES_CONFIG" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        print_error "Failed to read profiles configuration file"
        return 1
    fi

    if [[ "$profile_length" -eq 0 ]]; then
        print_warning "No profiles configured"
        return 1
    fi

    print_debug "Found $profile_length profiles"

    # Build array of profile names using mapfile
    local profiles_json
    profiles_json=$(jq -r 'keys[]' "$PROFILES_CONFIG" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        print_error "Failed to extract profile names"
        return 1
    fi

    print_debug "Raw profiles JSON: $profiles_json"

    mapfile -t profiles_array <<< "$profiles_json"
    profile_count=${#profiles_array[@]}

    print_debug "Profile count: $profile_count"
    print_debug "Profiles array: ${profiles_array[*]}"

    if [[ $profile_count -eq 0 ]]; then
        print_warning "No profiles configured"
        return 1
    fi

    # Display profiles with numbers
    print_status "Select a profile to switch to:"
    echo
    for i in "${!profiles_array[@]}"; do
        local profile_name="${profiles_array[$i]}"
        local cloud_env
        cloud_env=$(jq -r ".\"$profile_name\".cloud_environment" "$PROFILES_CONFIG" 2>/dev/null)
        printf "%2d) %-20s (%s)\n" $((i + 1)) "$profile_name" "$cloud_env"
    done
    echo

    # Get user selection
    local selection=""
    while true; do
        read -p "Enter selection (1-$profile_count): " selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le $profile_count ]]; then
            break
        else
            print_warning "Invalid selection. Please enter a number between 1 and $profile_count"
        fi
    done

    # Switch to selected profile
    local selected_profile="${profiles_array[$((selection - 1))]}"
    print_status "Do you wish to export environment variables for this profile?"
    print_status "  1) No export"
    print_status "  2) Export ARM_TENANT_ID and ARM_SUBSCRIPTION_ID"
    print_status "  3) Export AZURE_TENANT_ID and AZURE_SUBSCRIPTION_ID"
    local export_selection=""
    while true; do
        read -p "Enter selection (1-3): " export_selection
        if [[ "$export_selection" =~ ^[1-3]$ ]]; then
            break
        else
            print_warning "Invalid selection. Please enter a number between 1 and 3"
        fi
    done
    export_option=""
    case "$export_selection" in
        "1")
            export_option=""
            ;;
        "2")
            export_option="--export-arm"
            ;;
        "3")
            export_option="--export-az"
            ;;
    esac

    print_debug "Selected profile: $selected_profile"
    switch_profile "$selected_profile" "$export_option"
}

# ===============================
# Main Function

main() {
    check_dependencies
    local command="${1:-help}"

    case "$command" in
        "add")
            shift
            add_profile "$@"
            ;;
        "remove"|"rm")
            shift
            remove_profile "$@"
            ;;
        "list"|"ls")
            list_profiles
            ;;
        "switch"|"use"|"set")
            shift
            switch_profile "$@"
            ;;
        "interactive"|"i")
            interactive_switch
            ;;
        "current"|"show")
            show_current
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"
__azp_terminate "$?"
