#!/usr/bin/env bash

fonts_dir="${HOME}/.local/share/fonts"
if [ ! -d "${fonts_dir}" ]; then
  echo "mkdir -p $fonts_dir"
  mkdir -p "${fonts_dir}"
else
  echo "Found fonts dir $fonts_dir"
fi


# ------------------------------------ UBUNTU
for type in regular italic bold bold-italic light light-italic medium medium-italic condensed mono mono-italic mono-bold mono-bold-italic; do
  file_path="${fonts_dir}/Ubuntu-${type}.ttf"
  file_url="https://www.1001fonts.com/download/font/ubuntu.${type}.ttf"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

# ------------------------------------ OPERATOR MONO
for type in Light BoldItalic Light-1; do
  file_path="${fonts_dir}/OperatorMono-${type}.ttf"
  file_url="https://fontsfree.net/wp-content/fonts/basic/sans-serif/FontsFree-Net-OperatorMono-${type}.ttf"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

for type in Bold Medium; do
  file_path="${fonts_dir}/OperatorMono-${type}.ttf"
  file_url="https://fontsfree.net//wp-content/fonts/basic/various-basic/FontsFree-Net-OperatorMono-${type}.ttf"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

for type in Book BookItalic-1; do
  file_path="${fonts_dir}/OperatorMono-${type}.ttf"
  file_url="https://fontsfree.net//wp-content/fonts/basic/FontsFree-Net-OperatorMono-${type}.ttf"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

# ------------------------------------ SOURCE CODE PRO
for type in regular extralight light semibold bold black; do
  file_path="${fonts_dir}/SourceCodePro-${type}.ttf"
  file_url="https://www.1001fonts.com/download/font/source-code-pro.${type}.ttf"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

# ------------------------------------ FIRA CODE
for type in regular medium bold light retina; do
  file_path="${fonts_dir}/FiraCode-${type}.ttf"
  file_url="https://www.1001fonts.com/download/font/fira-mono.${type}.ttf"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

# ------------------------------------ IBM PLEX MONO
for type in regular thin extralight light medium semibold bold italic thin-italic extralight-italic light-italic medium-italic semibold-italic bold-italic; do
  file_path="${fonts_dir}/IBMPlexMono-${type}.ttf"
  file_url="https://www.1001fonts.com/download/font/ibm-plex-mono.${type}.ttf"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

echo "fc-cache -f"
fc-cache -f
