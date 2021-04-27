#!/usr/bin/env bash

fonts_dir="${HOME}/.local/share/fonts"
if [ ! -d "${fonts_dir}" ]; then
  echo "mkdir -p $fonts_dir"
  mkdir -p "${fonts_dir}"
else
  echo "Found fonts dir $fonts_dir"
fi

# ------------------------------------ FIRA CODE
for type in Bold Light Medium Regular Retina; do
  file_path="${fonts_dir}/FiraCode-${type}.ttf"
  file_url="https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true"
  if [ ! -e "${file_path}" ]; then
    wget -q "${file_url}" -O "${file_path}" --show-progress
  else
    echo "Found existing file $file_path"
  fi;
done

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
for type in Bold Medium Light BoldItalic Light-1; do
  file_path="${fonts_dir}/OperatorMono-${type}.ttf"
  file_url="https://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-OperatorMono-${type}.ttf"
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

echo "fc-cache -f"
fc-cache -f
