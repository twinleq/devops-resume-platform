# Open Policy Agent (OPA) security policies for DevOps Resume Platform

package kubernetes.admission

# Deny containers that run as root
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    container.securityContext.runAsUser == 0
    msg := "Container must not run as root user"
}

# Require security context for all containers
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.securityContext
    msg := "Container must have security context defined"
}

# Require read-only root filesystem
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem
    msg := "Container must have read-only root filesystem"
}

# Deny privileged containers
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    container.securityContext.privileged == true
    msg := "Privileged containers are not allowed"
}

# Deny containers with ALL capabilities
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    container.securityContext.capabilities.add[_] == "ALL"
    msg := "Containers with ALL capabilities are not allowed"
}

# Require resource limits
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.resources.limits
    msg := "Container must have resource limits defined"
}

# Require resource requests
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.resources.requests
    msg := "Container must have resource requests defined"
}

# Require liveness probe
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.livenessProbe
    msg := "Container must have liveness probe defined"
}

# Require readiness probe
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.readinessProbe
    msg := "Container must have readiness probe defined"
}

# Deny containers without image tag
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    not container.image
    msg := "Container must have image specified"
}

# Deny containers with latest tag
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    container := input.request.object.spec.containers[_]
    endswith(container.image, ":latest")
    msg := "Containers with latest tag are not allowed"
}

# Require specific labels
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    not input.request.object.metadata.labels["app.kubernetes.io/name"]
    msg := "Pod must have app.kubernetes.io/name label"
}

deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    not input.request.object.metadata.labels["app.kubernetes.io/version"]
    msg := "Pod must have app.kubernetes.io/version label"
}

# Deny host network
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    input.request.object.spec.hostNetwork == true
    msg := "Host network is not allowed"
}

# Deny host PID
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    input.request.object.spec.hostPID == true
    msg := "Host PID is not allowed"
}

# Deny host IPC
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    input.request.object.spec.hostIPC == true
    msg := "Host IPC is not allowed"
}

# Require service account
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.operation == "CREATE"
    not input.request.object.spec.serviceAccountName
    msg := "Pod must have service account specified"
}

# Network Policy validation
deny[msg] {
    input.request.kind.kind == "NetworkPolicy"
    input.request.operation == "CREATE"
    not input.request.object.spec.podSelector
    msg := "NetworkPolicy must have podSelector defined"
}

# Ingress validation
deny[msg] {
    input.request.kind.kind == "Ingress"
    input.request.operation == "CREATE"
    rule := input.request.object.spec.rules[_]
    not rule.host
    msg := "Ingress rule must have host specified"
}

# Service validation
deny[msg] {
    input.request.kind.kind == "Service"
    input.request.operation == "CREATE"
    not input.request.object.spec.selector
    msg := "Service must have selector defined"
}

# ConfigMap validation
deny[msg] {
    input.request.kind.kind == "ConfigMap"
    input.request.operation == "CREATE"
    not input.request.object.data
    msg := "ConfigMap must have data defined"
}

# Secret validation
deny[msg] {
    input.request.kind.kind == "Secret"
    input.request.operation == "CREATE"
    not input.request.object.data
    not input.request.object.stringData
    msg := "Secret must have data or stringData defined"
}

