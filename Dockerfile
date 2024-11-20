# Stage 1: Builder
FROM alpine:latest as builder

RUN apk add --no-cache \
        unzip \
        curl \
        jq && \
    LATEST_VERSION=$(curl -s https://api.github.com/repos/pocketbase/pocketbase/releases/latest | jq -r '.tag_name') && \
    curl -L -o /tmp/pb.zip "https://github.com/pocketbase/pocketbase/releases/download/${LATEST_VERSION}/pocketbase_${LATEST_VERSION#v}_linux_amd64.zip" && \
    unzip /tmp/pb.zip -d /pb/ && \
    rm /tmp/pb.zip

# Stage 2: Final image
FROM alpine:latest

# Copy PocketBase binary from builder stage
COPY --from=builder /pb /pb

# Ensure necessary certificates are installed
RUN apk add --no-cache ca-certificates

# Expose PocketBase default port
EXPOSE 8080

# Start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]