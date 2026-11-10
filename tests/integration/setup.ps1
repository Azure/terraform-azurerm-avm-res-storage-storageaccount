$ErrorActionPreference = 'Stop'
$recoveryPath = Join-Path $PSScriptRoot '../fixtures/customer_managed_key_recovery'
$terraform = @(Get-ChildItem -Path (Join-Path $env:AVM_HOME 'tools/terraform/*/terraform') -File)
if ($terraform.Count -ne 1) {
    throw 'Expected exactly one managed Terraform binary in the CI runtime.'
}

# Recover the previous run before allowing another integration deployment.
& $terraform[0].FullName "-chdir=$recoveryPath" init -backend=false -input=false -no-color
if ($LASTEXITCODE -ne 0) {
    throw 'Initializing the one-time CMK fixture recovery failed.'
}

& $terraform[0].FullName "-chdir=$recoveryPath" apply -auto-approve -input=false -no-color
if ($LASTEXITCODE -ne 0) {
    throw 'CMK fixture recovery failed; integration deployment is not allowed.'
}
