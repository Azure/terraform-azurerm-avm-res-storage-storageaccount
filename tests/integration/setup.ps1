$ErrorActionPreference = 'Stop'
$recoveryPath = Join-Path $PSScriptRoot '../fixtures/customer_managed_key_recovery'

# Recover the previous run before allowing another integration deployment.
terraform "-chdir=$recoveryPath" init -backend=false -input=false -no-color
if ($LASTEXITCODE -ne 0) {
    throw 'Initializing the one-time CMK fixture recovery failed.'
}

terraform "-chdir=$recoveryPath" apply -auto-approve -input=false -no-color
if ($LASTEXITCODE -ne 0) {
    throw 'CMK fixture recovery failed; integration deployment is not allowed.'
}
