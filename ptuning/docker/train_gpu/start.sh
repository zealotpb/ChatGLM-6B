#!/usr/bin/env bash

CODE_DIR=/code
if [ ! -d "${CODE_DIR}" ]; then
  echo "Warning: ${CODE_DIR} doesn't exist, creating it..."
  mkdir -p ${CODE_DIR}
fi
cd ${CODE_DIR} || exit 1

arg_url=
arg_branch=
arg_requirements=
arg_init_script=
arg_main_script=

# #################### parse arguments
function parse_args() {
  while getops "u:b:r:i:m:h" opt_arg
  do
    case "${opt_arg}" in
      "u")
        arg_url=${opt_arg}
        echo "-u ${arg_url}"
        ;;
      "m")
        arg_main_script=${opt_arg}
        echo "-m ${arg_main_script}"
        ;;
      "b")
        arg_branch=${opt_arg}
        echo "-b ${arg_branch}"
        ;;
      "r")
        arg_requirements=${opt_arg}
        echo "-r ${arg_requirements}"
        ;;
      "i")
        arg_init_script=${opt_arg}
        echo "-i ${arg_init_script}"
        ;;
      "h")
        echo "Usage: start [options]"
        echo "start -u <git_url> -b <git_branch> -r <requirements.txt relative path> -i <init script relative path>"
        echo "  -u: required, url, code url using git to pull to ${CODE_DIR}."
        echo "  -m: required, main script path relative in ${CODE_DIR}."
        echo "  -b: optional, branch name, branch name of code url, if empty, default branch is pulled."
        echo "  -r: optional, requirements.txt path relative in ${CODE_DIR}, if empty, no pip installation."
        echo "  -i: optional, init script path relative in ${CODE_DIR}, if empty, no execution of init script."
        echo "  -h: optional, show help messages."
        ;;
      ":")
        echo "Warning: option -${opt_arg} needs a value, but use empty value now."
        ;;
      "?")
        echo "Warning: option -${opt_arg} not supported."
        ;;
      *)
        echo "Error: unknown error while parsing options."
        ;;
    esac
  done
}

parse_args "$@"
echo "Info: arguments parsed"
echo "  url= ${arg_url}"
echo "  main_script= ${arg_main_script}"
echo "  branch= ${arg_branch}"
echo "  requirements= ${arg_requirements}"
echo "  init_script= ${arg_init_script}"

# url must be specified
if [ "${arg_url}" == "" ]; then
  echo "Error: url= ${arg_url} is empty, but it's required."
  exit 1
fi
# main_script must be specified
if [ "${arg_main_script}" == "" ]; then
  echo "Error: main_script= ${arg_main_script} is empty, but it's required."
  exit 1
fi

# #################### update code
is_code_cloned=$(git rev-parse --is-inside-work-tree)
if [ "${is_code_cloned}" == "true" ]; then
  echo "Info: ${CODE_DIR} is not cloned as cloned= ${is_code_cloned}, cloning it..."
  if [ "${arg_url}" == "" ]; then
    echo "Error: url= ${arg_url} is empty, but it's required."
    exit 1
  fi
  if [ "${arg_url}" == "" ]; then
    echo "Info: branch= ${arg_branch} is empty, so clone default branch..."
    git clone --recursive "${arg_url}" "${CODE_DIR}"
  else
    echo "Info: branch= ${arg_branch} is not empty, so clone this branch..."
    git clone --recursive -b "${arg_branch}" "${arg_url}" "${CODE_DIR}"
  fi
else
  echo "Info: ${CODE_DIR} is cloned as cloned= ${is_code_cloned}, just pull..."
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  echo "Info: current_branch= ${current_branch}"
  git fetch
  # TODO:
fi

# main_script must exist
if [ ! -f "${CODE_DIR}/${arg_main_script}" ]; then
  echo "Error: main_script= ${CODE_DIR}/${arg_main_script} doesn't exist in url= ${arg_url}, branch= ${arg_branch}."
  exit 1
fi

# #################### install requirements.txt and execute init_script
source /app/dev/miniconda3/bin/activate base
conda env list

# install requirements.txt
if [ -f "${CODE_DIR}/${arg_requirements}" ]; then
  echo "Info: requirements.txt= ${CODE_DIR}/${arg_requirements}, installing requirements.txt..."
  pip install -U pip
  pip install -r "${CODE_DIR}/${arg_requirements}"
fi

# execute init script
if [ -f "${CODE_DIR}/${arg_init_script}" ]; then
  echo "Info: init_script= ${CODE_DIR}/${arg_init_script}, executing init_script..."
  chmod a+x "${CODE_DIR}/${arg_init_script}"
  "${CODE_DIR}/${arg_init_script}"
fi

# #################### run main_script
echo "Info: initialization done, begin to run ${CODE_DIR}/${arg_main_script}..."
chmod a+x "${CODE_DIR}/${arg_main_script}"
"${CODE_DIR}/${arg_main_script}"
