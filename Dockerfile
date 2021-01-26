# builder image
FROM golang:1.15-alpine as builder
RUN mkdir /build

WORKDIR /build
COPY go.mod .
COPY go.sum .
COPY cmd .
#RUN go mod download
RUN go mod vendor
RUN CGO_ENABLED=0 GOOS=linux go build -a -o aws-s3-provisioner .

# generate clean, runtime image
FROM registry.redhat.io/ubi8-minimal
COPY --from=builder /build/aws-s3-provisioner /usr/bin/

# executable
ENTRYPOINT ["/usr/bin/aws-s3-provisioner"]
CMD ["-v=2", "-alsologtostderr"]
