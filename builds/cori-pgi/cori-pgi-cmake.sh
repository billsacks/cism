#!/bin/sh

# After this executes, do:
#   make -j 8

# Set path to top cism directory
# Note, this is an easy way to build out of source.
# In directory you want to build in, run:
#   $ source $CISM/builds/linux-gnu-cism/linux-gnu-cism-cmake $CISM
# where $CISM is the path to the top level cism directory.
if [ $# -eq 0 ]
then
    cism_top="../.." 
else
    cism_top=${1%/}
fi

echo CISM: "${cism_top}"


module unload cmake
module unload cray-hdf5
module unload cray-hdf5-parallel
module unload netcdf
module unload python
module unload cray-shmem
module unload cray-mpich cray-mpich2
module unload netcdf-hdf5parallel cray-netcdf-hdf5parallel cray-parallel-netcdf
module unload boost
module unload pgi
module unload PrgEnv-cray PrgEnv-gnu PrgEnv-intel PrgEnv-pathscale PrgEnv-pgi

module load modules/3.2.10.2
module load cmake/3.1.3
module load PrgEnv-pgi/5.2.40
module unload pgi
module load cray-shmem/7.1.1
module load cray-mpich/7.1.1
module load pgi/14.2.0
module load cray-netcdf-hdf5parallel/4.3.2
module load cray-parallel-netcdf/1.5.0
module load python/2.7.9
module load boost/1.57

module list


# remove old build data:
rm -rf ./CMakeCache.txt
rm -rf ./CMakeFiles

# This cmake configuration script builds cism_driver
# on cori using the PGI compiler suite.  It no longer relies on a build
# of Trilinos, but does need a BISICLES build located in BISICLES_INTERFACE_DIR
# (currently set to /global/u2/d/dmartin/BISICLES/code/interface)

# BUILD OPTIONS:
# The call to cmake below includes several input ON/OFF switch parameters, to
# provide a simple way to select different build options.  These are:
# CISM_BUILD_CISM_DRIVER -- ON by default, set to OFF to only build the CISM libraries.
# CISM_ENABLE_BISICLES -- OFF by default, set to ON to build a BISICLES-capable cism_driver.
# CISM_ENABLE_FELIX -- OFF by default, set to ON to build a FELIX-capable cism_driver.
# CISM_USE_TRILINOS -- OFF by default, set to on for builds with Trilinos.
# CISM_MPI_MODE -- ON by default, only set to OFF for serial builds.
# CISM_SERIAL_MODE -- OFF by default, set to ON for serial builds.
# CISM_USE_GPTL_INSTRUMENTATION -- ON by default, set to OFF to not use GPTL instrumentation.
# CISM_COUPLED -- OFF by default, set to ON to build with CESM.


cmake \
  -D CISM_BUILD_CISM_DRIVER:BOOL=ON \
  -D CISM_ENABLE_BISICLES=OFF \
  -D CISM_ENABLE_FELIX=OFF \
\
  -D CISM_USE_TRILINOS:BOOL="${CISM_USE_TRILINOS:=ON}" \
  -D CISM_MPI_MODE:BOOL=ON \
  -D CISM_SERIAL_MODE:BOOL=OFF \
\
  -D CISM_USE_GPTL_INSTRUMENTATION:BOOL=ON \
  -D CISM_COUPLED:BOOL=OFF \
\
  -D CISM_TRILINOS_DIR=/project/projectdirs/piscees/trilinos-default/cori-pgi/install \
  -D CISM_TRILINOS_GPTL_DIR=/project/projectdirs/piscees/cism_gptl/Trilinos-11.12.1/cori-pgi-ci-nophal/install \
  -D CISM_TRILINOS_ALBANY_DIR=/project/projectdirs/piscees/trilinos-default/cori-pgi-albany/install \
\
  -D CISM_NETCDF_DIR="$NETCDF_DIR" \
  -D CISM_MPI_BASE_DIR="$MPICH_DIR" \
\
  -D CISM_FMAIN=/opt/pgi/14.2.0/linux86-64/14.2/lib/f90main.o \
\
  -D CMAKE_INSTALL_PREFIX:PATH="$cism_top/builds/cori-pgi/install" \
  -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -D CMAKE_VERBOSE_CONFIGURE:BOOL=ON \
\
  -D CMAKE_CXX_COMPILER=CC \
  -D CMAKE_C_COMPILER=cc \
  -D CMAKE_Fortran_COMPILER=ftn \
\
  -D CISM_SCI_LIB_DIR="$CRAY_LIBSCI_PREFIX_DIR/lib" \
  -D CISM_GPTL_DIR=/project/projectdirs/piscees/cism_gptl/libgptl/libgptl-cori-pgi \
\
  -D CMAKE_CXX_FLAGS:STRING="-O2 -mp --diag_suppress 554,111,611 -DH5_USE_16_API" \
  -D CISM_Fortran_FLAGS:STRING="-O2 -mp" \
  -D BISICLES_LIB_SUBDIR=libpgi \
  -D BISICLES_INTERFACE_DIR="$cism_top/../BISICLES/CISM-interface/interface" \
  -D CISM_MPI_LIBS:STRING="mpichf90" \
  -D CISM_STATIC_LINKING:BOOL=ON \
  "${cism_top}"


###

# This line must be added for working Trilinos build; must be absent for build without Trilinos

#  -D CISM_FMAIN=/opt/pgi/14.2.0/linux86-64/14.2/lib/f90main.o \

# This is Pat's old line, wich NERSC help recommended be replaced with env var $MPI_DIR

#  -D CISM_MPI_BASE_DIR=$CRAY_MPICH2_DIR \

