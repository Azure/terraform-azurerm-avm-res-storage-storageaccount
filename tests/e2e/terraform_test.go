package e2e

import (
	"os"
	"testing"
	"time"

	test_helper "github.com/Azure/terraform-module-test-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestComplete(t *testing.T) {
	vars := make(map[string]any, 0)
	identityId := os.Getenv("MSI_ID")
	if identityId != "" {
		vars["managed_identity_principal_id"] = identityId
	}
	test_helper.RunE2ETest(t, "../../", "examples/complete", terraform.Options{
		Vars: vars,
	}, func(t *testing.T, output test_helper.TerraformOutput) {
		time.Sleep(time.Minute)
	})
}

func TestPrivateEndpoint(t *testing.T) {
	test_helper.RunE2ETest(t, "../../", "examples/private_endpoint", terraform.Options{}, func(t *testing.T, output test_helper.TerraformOutput) {})
}
