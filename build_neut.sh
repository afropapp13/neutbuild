#!/bin/bash

if [ -z ${1} ]; then
  echo "Expected to be passed the path to a NEUT source distribution."
  exit 1
fi

NEUT_ROOT=$(readlink -f ${1})

if [ ! -e cernlib ]; then


if [ -z "`which git 2>/dev/null`" ]; then
  echo "*** System package git was not found. Please install before compiling this package!"
  echo ""
  exit 1
fi

NEED_IMAKE=0
NEED_MAKEDEPEND=0

if [ -z "`which imake 2>/dev/null`" ]; then
  echo "*** System package imake was not found. A local copy will be built for cernlib build!"
  echo ""
  NEED_IMAKE=1
fi

if [ -z "`which makedepend 2>/dev/null`" ]; then
  echo "*** System package makedepend was not found. A local copy will be built for cernlib build!"
  echo ""
  NEED_MAKEDEPEND=1
fi

if [ -z "`which g++ 2>/dev/null`" ]; then
  echo "*** g++ was not found. Please install/set up the gcc environment before compiling this package!"
  echo ""
  exit 1
fi

if [ -z "`which gfortran 2>/dev/null`" ]; then
  echo "*** gfortran was not found. Please install/set up the gfortran environment before compiling this package!"
  echo ""
  exit 1
fi


if [ -z "`which root-config 2>/dev/null`" ]; then
  echo "*** root-config was not found. Please install/set up the root environment before compiling this package!"
  echo ""
  exit 1
fi


git clone https://github.com/luketpickering/cernlibgcc5-.git cernlib

cd cernlib

if [ ${NEED_IMAKE} ] || [ ${NEED_MAKEDEPEND} ]; then
  ./build_xutils_imake_makedepend.sh ${NEED_IMAKE} ${NEED_MAKEDEPEND}
fi

source xorg/xorg_utils_setup.sh

echo ${PWD}
ls

./build_cernlib.sh

source setup_cernlib.sh

else 

source cernlib/setup_cernlib.sh

fi

cd ${NEUT_ROOT}

if ! cd src/neutsmpl; then
  echo "[ERROR]: ${NEUT_ROOT}/src/neutsmpl did not exist. Is this copy of NEUT valid?"
  exit 1
fi

./Makeneutsmpl.csh

if [ ! -e neutroot2 ]; then
  echo "[ERROR]: Failed to build neutroot2, please check the above output for clues why.
  exit 1
fi

cd ${NEUT_ROOT}

mkdir bin; cd bin
cp ${NEUT_ROOT}/src/neutsmpl/neutroot2 ./
cd ../
mkdir example_cards; cd example_cards
cp ${NEUT_ROOT}/src/neutsmpl/Cards/*.card ./
cd ../
mkdir crsdat; cd crsdat
cp -r ${NEUT_ROOT}/src/crsdat/* .
cd ../

echo "Built NEUT, now source setup_neut.sh"

echo -e '#!/bin/bash'"\nexport NEUT_ROOT=${NEUT_ROOT}\nNEUT_CARDS=${NEUT_ROOT}/src/neutsmpl/Cards\nNEUT_CRSDAT=${NEUT_ROOT}/src/crsdat\nexport PATH=\${NEUT_ROOT}/bin;\${PATH}" > setup_neut.sh