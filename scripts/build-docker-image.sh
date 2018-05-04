#! /bin/sh

root="$PWD"
repo_dir="$root"/demo-repository
image_name="learnocaml-docker"

function print_usage() {
    printf "Usage: %s <OPTIONS>\n\
Options:\n\
  -repo-dir (default = demo-repository): Repository containing the exercises.\n\
  -root (default = %s): Root of the learn-ocaml repository.\n" "$0" "$pwd"
}

while [[ $# -gt 0 ]]; do
  curr="$1"

  case $curr in
      -image-name)
      image_name="$2"
      shift
      shift
      ;;
      -repo-dir)
      repo_dir="$2"
      shift
      shift
      ;;
      -root)
      root="$2"
      shift
      shift
      ;;
      *)    # unknown option
      echo "Unknown option $1"
      print_usage
      exit 2
      ;;
  esac
done

exercises_repository="$root"/exercises_repository
      
if [ -d "$tmp_repo_dir" ]; then
    rm -rf "$exercises_repository"
fi

cp -r "$repo_dir" "$exercises_repository" 

docker build -f "$root/Dockerfile" -t "$image_name" "$root"

rm -rf "$exercises_repository"
