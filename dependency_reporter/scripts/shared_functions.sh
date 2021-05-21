#! /bin/bash

function check_argument() {
  argument="$1"
  message="$2"
  continue_on_fail="$3"

  if [[ -z $argument ]]; then
    echo $message
    $continue_on_fail || exit 1
  fi
}
