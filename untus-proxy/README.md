# Untus Proxy

A reverse proxy which allows a plain http file upload and forwards it to a tus api.

It may be used to allow non-tus clients to upload a file to a tus server.

```
non-tus-client -> untus-proxy -> tus.io-api
```

## Run (Docker)

### Build Docker Image

`docker build . -t untus-proxy:latest`


### Start Container

Given the tus api's base uri is `http://localhost:4000/files`:

`docker run -e TUS_HOST=localhost -e TUS_PORT=4000 -e TUS_BASE_PATH="/files" -p 8000:8000 untus-proxy:lates`


## Limitations

* No TLS.
    * The tus server must accept plain HTTP.
    * Ths untus-proxy will not to TLS either.

## License

* Copyright (C) 2025 IndiScale GmbH <mailto:info@indiscale.com>
* Copyright (C) 2025 Timm Fitschen

Code in this repository is licensed under the [GNU Affero General Public License](./LICENSE.md) (version 3 or
later) unless expressly stated otherwise.
