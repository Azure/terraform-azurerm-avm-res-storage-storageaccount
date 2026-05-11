# Private endpoint with a static IP allocation

Deploys a Storage Account with a private endpoint that pins the network
interface to specific private IP addresses via the `ip_configurations`
attribute, instead of letting Azure pick from the subnet pool.
