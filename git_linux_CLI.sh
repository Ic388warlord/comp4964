#!/bin/bash

list_directory() {
  echo "command list_directory called"
  directory="$1"
  if [ ! -d "$directory" ]
  then
    echo "Directory '$directory' not found, exiting..."
    exit 1
  fi

  ls -ltrn "$directory"
}

delete_directory() {
  echo "Command delete_directory called"
  directory="$1"
  if [ ! -d "$directory" ]
  then
    echo "Directory '$directory' not found, exiting..."
    exit 1
  fi

  rm -rf "$directory"
  if [ ! -d "$directory" ]
  then
    echo "Delete directory operation is successful"
  fi
}

delete_file() {
  echo "Command delete_file called"
  file="$1" 	
  if [ ! -f "$file" ]
  then
    echo "File '$file' not found, exiting..."
    exit 1
  fi

  rm "$file"
  if [ ! -f "$file" ]
  then
    echo "Delete file operation is successful"
  fi
}

new_directory() {
  echo "Command new directory called"
  if [ -d "$1" ]
  then
    echo "Directory or file with same name exists. Exiting..."
    exit 1
  fi

  mkdir $1
  if ls | grep -q $1
  then
    echo "Directory created successfully"
  else
    echo "Directory is not created"
  fi 
}

git_push() {
  echo "Command git_push called"
  if git status | grep -q "Your branch is ahead"
  then
    echo "There are local commit to push."
    git status
    git push
    if git status | grep -q "Your branch is up to date"
    then
      echo "Git push is successful"
    fi  
  else
    echo "There are no local commits to push. Exiting..."
  fi
}

git_add_commit() {
  echo "Command git_add_commit() called"
  file="$1"
  commit_msg="$2"

  if [ ! -f "$file" ];
  then
    echo "File '$file' not found."
    return
  fi

  git add "$file"
  echo "=== File added is either new file or modified. If file has no change, nothing is done. ==="
  git status
  echo "================================================="

  git commit -m "$commit_msg"

  echo "=== Check status, file committed, no longer appear ==="
  git status
  echo "======================================================="

  echo "=== Check git log for commit message. If file has no change, commit message will not show ==="
  git log --pretty=oneline
  echo "========================================"
}

git_clone_repo() {
  echo "Command git_clone_repo() called"
  if [ -d "$1" ]
  then
    echo "This directory already exists, no need for a new one."
    cd "$1"
  else
    echo "This directory does not exist, making a new one."
    mkdir "$1"
    cd "$1"
  fi

  if git clone "$2"
  then
    repo_name=$(basename "$2" .git)
    cd $repo_name
    echo "=== Check URL remote repository ==="
    if git remote -v | grep -q "$repo_name"
    then
      echo "Repository names match for configuration"
    else
      echo "Repository names do not match. Clean up"
      cd ../../
      rm -rf "$1"
    fi
    echo "===================================="
  else
    echo "Git Cloning has failed. Repository is not found. Cleaning up"
    cd ../
    rm -rf "$1"
  fi
}

git_remote_setup() {
  echo "Command git_remote_setup() called"
  if [ ! -d "$1" ]
  then
    echo "Directory provided does not exist"
    exit 1
  fi

  cd $1
  echo "=== Current Directory ==="
  pwd
  echo "========================="

  if git remote | grep -q "origin"
  then
    echo "Remote origin already exists"
    exit 1
  fi

  git remote add origin $2
  echo "=== Updated Remote Configs ==="
  git remote -v
  echo "=============================="

  touch setupRemote.txt
  git add setupRemote.txt
  git commit -m "Setup git remote repository."
  git push --set-upstream origin main

  echo "=== Verify git push success ==="
  git status
}

git_init_repo() {
  echo "Command git_init_repo() called"
  if [ -d "$1" ]
  then
    echo "This directory already exists, no need for a new one."
  else
    echo "This directory does not exist, making a new one."
    mkdir $1
    cd $1
    git init -b main
    git status
    git config --global user.email $2
    git config --global user.name $3
    echo "Current Git Configs"
    git config --list
  fi
}

menu() {
  echo "Hello and welcome to the Linux Git Repository Manager command-line interface program."
  echo "Here is the list of commands it supports."
  echo "1.menu"
  echo
  echo "2.git_init_repo <DIR_NAME> <GIT_EMAIL> <GIT_USERNAME>"
  echo "Arguments:"
  echo "  <DIR_NAME>     : Name of the directory used for the Git repository"
  echo "  <GIT_EMAIL>    : Git email address for configuration."
  echo "  <GIT_USERNAME> : Git username for configuration."
  echo
  echo "3.git_remote_setup <DIR_NAME> <URL>"
  echo "Arguments:"
  echo "  <DIR_NAME>     : Name of the directory where Git repository exists"
  echo "  <URL>          : URL for the remote repository (GITHUB) to store pushed files"
  echo "Note: When creating the Github repo, no file should exist such as README.md"
  echo "Note: git_init_repo will need to be run first"
  echo
  echo "4.git_clone_repo <DIR_NAME> <URL>"
  echo "Arguments:"
  echo "  <DIR_NAME>     : Name of the directory where the user wants to put cloned Git repository."
  echo "  <URL>          : URL where the existing remote repository will be cloned from."
  echo
  echo "5.git_add_commit <FILE_NAME> <COMMIT_MSG>"
  echo "Arguments:"
  echo "  <FILE_NAME>    : Name of the file where you want to add and commit to the Git repository."
  echo "  <COMMIT_MSG>   : Summary message used for git commit, will show up in git logs."
  echo
  echo "6.git_push"
  echo
  echo "7.new_directory <DIR_NAME>"
  echo "Arguments:"
  echo "  <DIR_NAME>	 : Directory name that is created in git repository"
  echo
  echo "8.delete_file <FILE_NAME>"
  echo "Arguments:"
  echo "  <FILE_NAME>	 : The file name listed will be deleted."
  echo
  echo "9.delete_directory <DIR_NAME>"
  echo "Arguments:"
  echo "  <DIR_NAME>	 : The directory name to be deleted."
  echo
  echo "10.list_directory <DIR_NAME>"
  echo "Arguments:"
  echo "  <DIR_NAME>	 : The directory name to show the listed content."
}

# $1 is the variable for command name entered
case "$1" in
  menu)
    menu
    ;;
  git_init_repo)
    if [ $# -lt 4 ]
    then
      echo "Invalid number of arguments, usage: git_init_repo <DIR_NAME> <GIT_EMAIL> <GIT_USERNAME>"
      exit 1
    fi
    git_init_repo "$2" "$3" "$4"
    ;;
  git_remote_setup)
    if [ $# -lt 3 ]
    then
      echo "Invalid number of arguments, usage: git_remote_setup <DIR_NAME> <URL>"
      exit 1
    fi
    git_remote_setup "$2" "$3"
    ;;
  git_clone_repo)
    if [ $# -lt 3 ]
    then
      echo "Invalid number of arguments, usage: git_clone_repo <DIR_NAME> <URL>"
      exit 1
    fi
    git_clone_repo "$2" "$3"
    ;;
  git_add_commit)
    if [ $# -lt 3 ]
    then
      echo "Invalid number of arguments, usage: git_add_commit <FILE_NAME> <COMMIT_MSG>"
      exit 1
    fi
    git_add_commit "$2" "$3"
    ;;
  git_push)
    git_push
    ;;
  new_directory)
    if [ $# -lt 2 ]
    then
      echo "Invalid number of arguments, usage: new_directory <DIR_NAME>"
      exit 1
    fi
    new_directory "$2"
    ;;
  delete_file)
    if [ $# -lt 2 ]
    then
      echo "Invalid number of arguments, usage: delete_file <FILE_NAME>"
      exit 1
    fi
    delete_file "$2"
    ;;
  delete_directory)
    if [ $# -lt 2 ]
    then
      echo "Invalid number of arguments, usage: delete_directory <FILE_NAME>"
      exit 1
    fi
    delete_directory "$2"
    ;;
  list_directory)
    if [ $# -lt 2 ]
    then
      echo "Invalid number of arguments, usage: list_directory <FILE_NAME>"
      exit 1
    fi
    list_directory "$2"
    ;;
  *)
    echo "Invalid command: $1. This command does not exist."
    echo "To see list of commands, usage: menu"
esac
