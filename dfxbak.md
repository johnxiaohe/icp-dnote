```json
{
  "canisters": {
    "dnote_backend": {
      "main": "src/dnote_backend/main.mo",
      "type": "motoko"
    },
    "dnote_frontend": {
      "dependencies": [
        "dnote_backend"
      ],
      "frontend": {
        "entrypoint": "src/dnote_frontend/src/index.html"
      },
      "source": [
        "src/dnote_frontend/assets",
        "dist/dnote_frontend/"
      ],
      "type": "assets"
    }
  },
  "defaults": {
    "build": {
      "args": "",
      "packtool": ""
    }
  },
  "output_env_file": ".env",
  "version": 1
}
```