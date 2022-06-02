#!/bin/bash

RUNDIR=$(pwd)

if [ -z "${1}" ]; then
  echo "Expected to be passed the path to a NEUT source distribution."
  exit 1
fi

NEUT_ROOT=$(readlink -f ${1})

NEUT_INSTALL_PREFIX=${NEUT_ROOT}
if [ ! -z "${2}" ]; then

  if [ -e "${2}" ] && [ ! -d "${2}" ]; then
    echo "[ERROR]: ${2} Appears to exist, but is not a directory."
    exit 1
  fi
  NEUT_INSTALL_PREFIX=${2}
fi
  
echo "Will install NEUT to ${NEUT_INSTALL_PREFIX}."

# Check CERNLIB, if not found install
if [ ! -e cernlib ]; then
  if [ -z "`which git 2>/dev/null`" ]; then
    echo "*** System package git was not found. Please install before compiling this package!"
    echo ""
    exit 1
  fi

  NEED_IMAKE=0
  NEED_MAKEDEPEND=0

  # Check IMake
  if [ -z "`which imake 2>/dev/null`" ]; then
    echo "*** System package imake was not found. A local copy will be built for cernlib build!"
    echo ""
    NEED_IMAKE=1
  fi

  # Check makedepend
  if [ -z "`which makedepend 2>/dev/null`" ]; then
    echo "*** System package makedepend was not found. A local copy will be built for cernlib build!"
    echo ""
    NEED_MAKEDEPEND=1
  fi

  # Check g++
  if [ -z "`which g++ 2>/dev/null`" ]; then
    echo "*** g++ was not found. Please install/set up the gcc environment before compiling this package!"
    echo ""
    exit 1
  fi

  # Check gfortran
  if [ -z "`which gfortran 2>/dev/null`" ]; then
    echo "*** gfortran was not found. Please install/set up the gfortran environment before compiling this package!"
    echo ""
    exit 1
  fi

  # Check root
  if [ -z "`which root-config 2>/dev/null`" ]; then
    echo "*** root-config was not found. Please install/set up the root environment before compiling this package!"
    echo ""
    exit 1
  fi

  # Get Luke's CERNLIB
  git clone https://github.com/luketpickering/cernlibgcc5-.git cernlib

  cd cernlib
  # Build IMake and/or makedepend
  if [ ${NEED_IMAKE} ] || [ ${NEED_MAKEDEPEND} ]; then
    ./build_xutils_imake_makedepend.sh ${NEED_IMAKE} ${NEED_MAKEDEPEND}
  fi

  source xorg/xorg_utils_setup.sh
  ./build_cernlib.sh
  source setup_cernlib.sh
else 
  source cernlib/setup_cernlib.sh

  # Check root
  if [ -z "`which root-config 2>/dev/null`" ]; then
    echo "*** root-config was not found. Please install/set up the root environment."
    echo ""
    exit 1
  fi

fi
