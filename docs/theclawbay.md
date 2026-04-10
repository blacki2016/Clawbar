# theclawbay

## Overview
theclawbay is a unified API proxy that routes requests to multiple underlying AI providers (OpenRouter, OpenAI, Anthropic, etc.) through a single API key and endpoint.

## Authentication
- **API Key**: Get your key from [theclawbay.com](https://theclawbay.com).
- **Config**: Add to `~/.clawbar/config.json (legacy fallback: ~/.codexbar/config.json)`:
  ```json
  {
    "id": "theclawbay",
    "enabled": true,
    "source": "api",
    "apiKey": "ca_v1.your_key_here"
  }
  ```
- **Env var**: `THECLAWBAY_API_KEY=ca_v1...`

## Usage Endpoint
- **URL**: `https://api.theclawbay.com/api/codex-auth/v1/quota`
- **Auth**: `Authorization: Bearer <key>` header
- **Format**: JSON with usage windows (5-hour + weekly)
- **Legacy**: Append `?format=legacy_codex` for Codex-compatible output

## Data Shown
- **Primary window**: 5-hour rolling usage with percentage and reset time
- **Secondary window**: Weekly usage (resets Sunday midnight UTC)
- **Updated timestamp**: When the quota data was last refreshed

## Status Page
- [theclawbay.com/status](https://theclawbay.com/status)

## Provider Configuration Options
```json
{
  "id": "theclawbay",
  "enabled": true,
  "source": "api"
}
```

No cookie import, OAuth, or browser login required — pure API key authentication.
