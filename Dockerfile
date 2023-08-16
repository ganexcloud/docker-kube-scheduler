FROM golang:1.21 as builder
ARG KUBE_VERSION=v1.27.4
ARG TARGETPLATFORM
ARG TARGETARCH
ENV KUBE_VERSION=${KUBE_VERSION}

WORKDIR /go/src/k8s.io/kubernetes
RUN apt-get update && apt-get install -y rsync && \
  git clone --depth=1 --branch="${KUBE_VERSION}" https://github.com/kubernetes/kubernetes.git . && \
  GOOS=linux GOARCH=${TARGETARCH} CGO_ENABLED=0 KUBE_BUILD_PLATFORMS=${TARGETPLATFORM} make WHAT=cmd/kube-scheduler

FROM busybox:1.36.1
COPY --from=builder /go/src/k8s.io/kubernetes/_output/local/bin/${TARGETPLATFORM}/kube-scheduler /usr/local/bin/kube-scheduler
ENTRYPOINT ["/usr/local/bin/kube-scheduler"]