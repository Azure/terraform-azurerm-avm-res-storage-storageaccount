package e2e

import (
	"os"
	"testing"

	test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestComplete(t *testing.T) {
	currentRoot, err := test_helper.GetCurrentModuleRootPath()
	if err != nil {
		t.FailNow()
	}
	currentMajorVersion, err := test_helper.GetCurrentMajorVersionFromEnv()
	if err != nil {
		t.FailNow()
	}
	vars := make(map[string]any, 0)
	identityId := os.Getenv("MSI_ID")
	if identityId != "" {
		vars["managed_identity_principal_id"] = identityId
	}
	test_helper.ModuleUpgradeTest(t, "Azure", "terraform-azurerm-storage-account", "examples/complete", currentRoot, terraform.Options{
		Vars: vars,
	}, currentMajorVersion)
}
