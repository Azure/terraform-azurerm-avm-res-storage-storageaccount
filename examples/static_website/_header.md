# Static Website Example

Enables static website hosting on a StorageV2 account and creates the reserved `$web` container that Azure Storage serves the site from.

Static website hosting is configured through the `properties.staticWebsite` block on the `blobServices/default` sub-resource, which requires API version `2025-08-01` or later.

Blob service properties are set alongside it because they target that same sub-resource, so this example exercises both writers in a single apply.
