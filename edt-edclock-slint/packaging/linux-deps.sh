# Shared Linux dependency helpers for setup.sh, install.sh, and build-deb.sh.
# Sourced, not executed.

# Slint 1.16.1 is itself edition 2024 with rust-version 1.88.
# Ubuntu/Debian apt rustc (often 1.75–1.80) cannot compile it.
MIN_RUSTC="1.88.0"

debian_runtime_packages() {
    # Runtime libraries the Slint winit backend dlopens (Wayland/X11/GL)
    # plus the few SONAMEs the binary is actually linked against.
    cat <<'EOF'
libfontconfig1
libgcc-s1
libxkbcommon0
libxkbcommon-x11-0
libwayland-client0
libwayland-egl1
libx11-6
libxcb1
libx11-xcb1
libxi6
libxcursor1
libxrender1
libegl1
libgl1
libgl1-mesa-dri
EOF
}

debian_build_packages() {
    cat <<'EOF'
build-essential
pkg-config
curl
ca-certificates
libfontconfig1-dev
libxkbcommon-dev
libxkbcommon-x11-dev
libwayland-dev
libx11-dev
libxcb1-dev
libx11-xcb-dev
libxi-dev
libxcursor-dev
libxrender-dev
libegl1-mesa-dev
libgl1-mesa-dev
libegl-dev
libgl-dev
EOF
}

fedora_runtime_packages() {
    cat <<'EOF'
fontconfig
libxkbcommon
libxkbcommon-x11
libwayland-client
libwayland-egl
libX11
libxcb
libX11-xcb
libXi
libXcursor
libXrender
libglvnd-egl
libglvnd-glx
mesa-dri-drivers
libgcc
glibc
EOF
}

fedora_build_packages() {
    cat <<'EOF'
gcc
gcc-c++
make
pkgconf
curl
ca-certificates
fontconfig-devel
libxkbcommon-devel
wayland-devel
libX11-devel
libxcb-devel
libXi-devel
libXcursor-devel
libXrender-devel
mesa-libEGL-devel
mesa-libGL-devel
libglvnd-devel
EOF
}

detect_os_family() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID_LIKE:-$ID}" in
            *debian*|*ubuntu*) echo debian ;;
            *fedora*|*rhel*|*centos*) echo fedora ;;
            *) echo "$ID" ;;
        esac
    else
        echo unknown
    fi
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    local family="$1" pkg="$2"
    case "$family" in
        debian)
            dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'
            ;;
        fedora)
            rpm -q "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

filter_missing_packages() {
    local family="$1"
    shift
    local p
    for p in "$@"; do
        if package_installed "$family" "$p"; then
            continue
        fi
        printf '%s\n' "$p"
    done
}

version_ge() {
    # Return 0 if $1 >= $2 (dotted numeric versions).
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

rustc_semver() {
    rustc --version 2>/dev/null | awk '{print $2}' | cut -d- -f1
}

ensure_system_packages() {
    local kind="$1" # runtime | build | all
    local family
    family="$(detect_os_family)"
    local pkgs=()

    case "$family" in
        debian)
            if [ "$kind" = runtime ] || [ "$kind" = all ]; then
                while IFS= read -r p; do
                    [ -n "$p" ] && pkgs+=("$p")
                done < <(debian_runtime_packages)
            fi
            if [ "$kind" = build ] || [ "$kind" = all ]; then
                while IFS= read -r p; do
                    [ -n "$p" ] && pkgs+=("$p")
                done < <(debian_build_packages)
            fi
            local missing=()
            while IFS= read -r p; do
                [ -n "$p" ] && missing+=("$p")
            done < <(filter_missing_packages debian "${pkgs[@]}")
            if [ ${#missing[@]} -eq 0 ]; then
                echo "Debian/Ubuntu packages already installed."
            elif have_cmd apt-get; then
                echo "Installing Debian/Ubuntu packages with apt-get: ${missing[*]}"
                sudo apt-get update -y
                # Some -dev names differ across Ubuntu/Debian releases; skip missing ones.
                if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"; then
                    echo "Retrying packages one at a time (some names differ by release)..."
                    local installed=0
                    for p in "${missing[@]}"; do
                        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$p"; then
                            installed=$((installed + 1))
                        else
                            echo "Note: package $p is not available on this release (skipping)."
                        fi
                    done
                    if [ "$installed" -eq 0 ]; then
                        echo "apt-get could not install any requested packages." >&2
                        return 1
                    fi
                fi
            else
                echo "apt-get not found; install these packages by hand: ${missing[*]}" >&2
                return 1
            fi
            ;;
        fedora)
            if [ "$kind" = runtime ] || [ "$kind" = all ]; then
                while IFS= read -r p; do
                    [ -n "$p" ] && pkgs+=("$p")
                done < <(fedora_runtime_packages)
            fi
            if [ "$kind" = build ] || [ "$kind" = all ]; then
                while IFS= read -r p; do
                    [ -n "$p" ] && pkgs+=("$p")
                done < <(fedora_build_packages)
            fi
            local missing=()
            while IFS= read -r p; do
                [ -n "$p" ] && missing+=("$p")
            done < <(filter_missing_packages fedora "${pkgs[@]}")
            if [ ${#missing[@]} -eq 0 ]; then
                echo "Fedora packages already installed."
            elif have_cmd dnf; then
                echo "Installing Fedora packages with dnf: ${missing[*]}"
                sudo dnf install -y "${missing[@]}"
            elif have_cmd yum; then
                echo "Installing packages with yum: ${missing[*]}"
                sudo yum install -y "${missing[@]}"
            else
                echo "dnf not found; install these packages by hand: ${missing[*]}" >&2
                return 1
            fi
            ;;
        *)
            echo "Unrecognized distro; skipping automatic system package install." >&2
            echo "Need fontconfig, libxkbcommon, Wayland or X11, and a C toolchain to build." >&2
            ;;
    esac
}

ensure_rust() {
    local current=""
    if have_cmd rustc; then
        current="$(rustc_semver)"
    fi

    if [ -n "$current" ] && version_ge "$current" "$MIN_RUSTC"; then
        echo "Rust $current is new enough (need >= $MIN_RUSTC)."
        return 0
    fi

    if [ -n "$current" ]; then
        echo "Rust $current is too old (need >= $MIN_RUSTC)."
        echo "Ubuntu/Debian 'apt install rustc' is typically too old for this project"
        echo "(edition2024 / lockfile v4 / Slint). Installing rustup's stable toolchain..."
    else
        echo "Rust is not installed. Installing rustup's stable toolchain..."
    fi

    if ! have_cmd curl; then
        echo "curl is required to install rustup. Install curl and re-run." >&2
        return 1
    fi

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

    # shellcheck disable=SC1091
    if [ -f "$HOME/.cargo/env" ]; then
        . "$HOME/.cargo/env"
    fi
    export PATH="$HOME/.cargo/bin:$PATH"

    if ! have_cmd rustc; then
        echo "rustup installed but rustc is not on PATH. Open a new shell or:" >&2
        echo "  source \"\$HOME/.cargo/env\"" >&2
        return 1
    fi

    current="$(rustc_semver)"
    if ! version_ge "$current" "$MIN_RUSTC"; then
        echo "rustc $current is still too old after rustup. Run: rustup update stable" >&2
        return 1
    fi
    echo "Using rustc $current from rustup."
}
