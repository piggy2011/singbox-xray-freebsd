# SingBox & Xray FreeBSD Builder

Automated GitHub Actions workflow for compiling **sing-box v1.12.12** and **xray-core v25.10.15**
for **FreeBSD 14.1 (amd64)**.

## Features
- Cross-compiles on Ubuntu runner (GOOS=freebsd, GOARCH=amd64)
- Bundles both binaries with SHA256 checksums
- Output as `.tar.gz` artifacts

## Usage
1. Fork or clone this repo
2. Run workflow manually in *Actions → Build FreeBSD Proxies v1.0*
3. Download artifacts or releases for FreeBSD usage

## License
MIT © 2025 piggy2011
