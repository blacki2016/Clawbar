#!/bin/sh
set -eu

REPO="blacki2016/Clawbar"
APP_NAME="Clawbar"
BIN_DIR="${HOME}/.local/bin"
INSTALL_ROOT="${HOME}/.local/share/clawbar"
APP_INSTALL_DIR="${INSTALL_ROOT}/${APP_NAME}.app"

tmpdir=""

cleanup() {
    if [ -n "${tmpdir}" ] && [ -d "${tmpdir}" ]; then
        rm -rf "${tmpdir}"
    fi
}

fail() {
    printf '%s\n' "Error: $*" >&2
    exit 1
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

latest_tag() {
    curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest" \
        | sed 's#.*/tag/##'
}

linux_asset_url() {
    tag="$1"
    arch="$2"

    for name in \
        "ClawbarCLI-${tag}-linux-${arch}.tar.gz" \
        "clawbar-cli-${tag}-linux-${arch}.tar.gz" \
        "CodexBarCLI-${tag}-linux-${arch}.tar.gz"
    do
        url="https://github.com/${REPO}/releases/download/${tag}/${name}"
        if curl -fsLI "$url" >/dev/null 2>&1; then
            printf '%s\n' "$url"
            return 0
        fi
    done

    return 1
}

find_first_executable() {
    base="$1"

    for candidate in \
        "${base}/clawbar" \
        "${base}/ClawbarCLI" \
        "${base}/CodexBarCLI"
    do
        if [ -x "$candidate" ] && [ ! -d "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    find "$base" -type f \( -name 'clawbar' -o -name 'ClawbarCLI' -o -name 'CodexBarCLI' \) -perm -111 2>/dev/null | head -n 1
}

trap cleanup EXIT INT TERM HUP

need_cmd curl
need_cmd uname
need_cmd mktemp
need_cmd find
need_cmd ln
need_cmd rm
need_cmd mv
need_cmd mkdir

os_name=$(uname -s)
arch_name=$(uname -m)

case "$arch_name" in
    arm64|aarch64) release_arch="aarch64" ;;
    x86_64|amd64) release_arch="x86_64" ;;
    *) fail "Unsupported architecture: ${arch_name}" ;;
esac

mkdir -p "$BIN_DIR" "$INSTALL_ROOT"
tmpdir=$(mktemp -d)
extract_dir="${tmpdir}/extract"
mkdir -p "$extract_dir"

case "$os_name" in
    Darwin)
        need_cmd unzip

        zip_path="${tmpdir}/Clawbar-macOS.zip"
        app_source=""
        target_binary=""

        printf '%s\n' "Downloading Clawbar CLI bundle for macOS..."
        curl -fsSL "https://github.com/${REPO}/releases/latest/download/Clawbar-macOS.zip" -o "$zip_path"
        unzip -q "$zip_path" -d "$extract_dir"

        app_source=$(find "$extract_dir" -type d -name "${APP_NAME}.app" -prune | head -n 1)
        [ -n "$app_source" ] || fail "Could not find ${APP_NAME}.app in the release archive"

        rm -rf "$APP_INSTALL_DIR"
        mv "$app_source" "$APP_INSTALL_DIR"

        target_binary="${APP_INSTALL_DIR}/Contents/Helpers/clawbar"
        [ -x "$target_binary" ] || fail "Bundled CLI helper not found at ${target_binary}"
        ;;
    Linux)
        need_cmd tar

        tag=$(latest_tag)
        [ -n "$tag" ] || fail "Could not resolve the latest release tag"

        asset_url=$(linux_asset_url "$tag" "$release_arch" || true)
        [ -n "$asset_url" ] || fail "No Linux CLI asset found for ${release_arch} in release ${tag}"

        archive_path="${tmpdir}/clawbar-cli.tar.gz"

        printf '%s\n' "Downloading Clawbar CLI for Linux (${release_arch})..."
        curl -fsSL "$asset_url" -o "$archive_path"
        tar -xzf "$archive_path" -C "$extract_dir"

        target_binary=$(find_first_executable "$extract_dir")
        [ -n "$target_binary" ] || fail "Could not find a CLI executable in the Linux archive"
        ;;
    *)
        fail "Unsupported operating system: ${os_name}"
        ;;
esac

install_target="${INSTALL_ROOT}/clawbar"
rm -f "$install_target"
cp "$target_binary" "$install_target"
chmod 755 "$install_target"

ln -sf "$install_target" "${BIN_DIR}/clawbar"

printf '\n%s\n' "Clawbar CLI installed."
printf '%s\n' "  Binary: ${install_target}"
printf '%s\n' "  Symlink: ${BIN_DIR}/clawbar"

case ":$PATH:" in
    *:"${BIN_DIR}":*)
        ;;
    *)
        printf '%s\n' "  Add ${BIN_DIR} to your PATH if 'clawbar' is not found."
        ;;
esac

printf '%s\n' "  Run: clawbar --help"
