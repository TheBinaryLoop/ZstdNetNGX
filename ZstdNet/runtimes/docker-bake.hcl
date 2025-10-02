variable "ZSTD_VERSION" {
  default = "1.5.7"
}

# Common args for all targets
target "_common" {
  args = {
    ZSTD_VERSION = "${ZSTD_VERSION}"
  }
}

# === Individual build targets (map 1:1 to Dockerfile stages) ===
target "linux-musl-x64" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-musl-x64"
}

target "linux-musl-x86" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-musl-x86"
}

target "linux-musl-arm64" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-musl-arm64"
}

target "linux-musl-arm" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-musl-arm"
}

target "linux-glibc-x64" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-glibc-x64"
}

target "linux-glibc-x86" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-glibc-x86"
}

target "linux-glibc-arm64" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-glibc-arm64"
}

target "linux-glibc-arm" {
  inherits = ["_common"]
  context  = "."
  target   = "linux-glibc-arm"
}

target "win-x64" {
  inherits = ["_common"]
  context  = "."
  target   = "win-x64"
}

target "win-x86" {
  inherits = ["_common"]
  context  = "."
  target   = "win-x86"
}

#target "osx-x64" {
#  inherits = ["_common"]
#  context  = "."
#  target   = "osx-x64"
#}

# Finale collects everything under /out
target "finale" {
  inherits = ["_common"]
  context  = "."
  target   = "finale"
}

# === Output helpers ===

# Builds all stages (useful for CI cache warming)
group "all" {
  targets = [
    "linux-musl-x64",
    "linux-musl-x86",
    "linux-musl-arm64",
    "linux-musl-arm",
    "linux-glibc-x64",
    "linux-glibc-x86",
    "linux-glibc-arm64",
    "linux-glibc-arm",
    "win-x64",
    "win-x86",
#    "osx-x64",
    "finale"
  ]
}

# Writes the finale artifacts to ./artifacts on your host
target "artifacts" {
  inherits = ["finale"]
  target   = "artifacts"
  output   = ["type=local,dest=./"]
}
