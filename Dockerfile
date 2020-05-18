# First stage: build the executable.
FROM golang:1.12.9-alpine3.10 AS builder

# Git is required for fetching the dependencies.
RUN apk add --no-cache ca-certificates git

# Set the working directory outside $GOPATH to enable the support for modules.
WORKDIR /src

# Fetch dependencies first; they are less susceptible to change on every build
# and will therefore be cached for speeding up the next build
# COPY ./go.mod ./go.sum ./
# RUN go mod download
RUN go mod init github.com/ouksal/https

# Import the code from the context.
COPY ./ ./

# Build the executable to `/app`. Mark the build as statically linked.
RUN CGO_ENABLED=0 go build \
    -installsuffix 'static' \
    -o /app .

# Final stage: the running container.
FROM alpine AS final

# Import the compiled executable from the first stage.
COPY --from=builder /app /app
# Import the root ca-certificates (required for Let's Encrypt)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Expose both 443 and 80 to our application
EXPOSE 443
EXPOSE 80

# Mount the certificate cache directory as a volume, so it remains even after
# we deploy a new version
VOLUME ["cert-cache"]         //<-- 2nd version:  /cert-cache

# Run the compiled binary.
ENTRYPOINT ["/app"]