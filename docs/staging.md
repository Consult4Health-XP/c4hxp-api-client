# Staging Compatibility

Use the C4HXP staging API to validate integrations before production traffic.

## Base URL

```text
https://api.staging.consult4healthxp.com
```

Public API routes keep the same `/v2/public/*` path shape as production. For example:

```bash
curl -i "https://api.staging.consult4healthxp.com/v2/public/health"
```

## Client Configuration

Set `C4HXP_BASE_URL` when running examples or SDK integrations against staging:

```bash
export C4HXP_BASE_URL=https://api.staging.consult4healthxp.com
```

Use staging API credentials with staging. Do not reuse production API keys or production secrets in staging validation.

## Validation Checklist

- Health endpoint returns `200`.
- Catalog endpoints use a staging API key with `catalog:read` access.
- Order creation tests use staging recipients and staging data only.
- Webhook tests point to non-production endpoints.
- Package publishing is not required for staging URL compatibility.
