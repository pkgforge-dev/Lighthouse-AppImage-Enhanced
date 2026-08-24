#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake         \
    fmt           \
    libzip        \
    nlohmann-json \
    sdl2_net      \
    spdlog        \
    tinyxml2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

make-aur-package zenity-rs-bin

echo "Making stable build of Lighthouse..."
echo "---------------------------------------------------------------"
REPO="https://github.com/HarbourMasters/Lighthouse"
VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//')"
git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./Lighthouse
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./Lighthouse
patch -Np1 -i ../thread5-mesg-guard.patch

cmake ./ -Bbuild -DCMAKE_POSITION_INDEPENDENT_CODE=ON
cmake --build build --config Release
cmake --build build --config Release --target GeneratePortO2R

mv -v build/assets build/Lighthouse build/config.yml build/lighthouse.o2r ../AppDir/bin
wget -O ../AppDir/bin/gamecontrollerdb.txt https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/master/gamecontrollerdb.txt
