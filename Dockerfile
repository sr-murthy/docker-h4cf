FROM ubuntu:18.04

MAINTAINER The HDF-EOS Tools and Information Center <eoshelp@hdfgroup.org>

ENV HOME /root

COPY ["./apt.txt", "./"]

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt update && apt install -yq $(grep -vE "^\s*#" ./apt.txt)

#Build HDF4 lib.
ARG HDF4_VER=4.2.16
RUN wget https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF4/HDF${HDF4_VER}-2/src/hdf-${HDF4_VER}-2.tar.gz && \
    tar zxvf hdf-${HDF4_VER}-2.tar.gz && \
    cd hdf-${HDF4_VER}-2 && \
    ./configure --enable-shared --disable-netcdf --disable-fortran && \
    make && make check && make install && \
    cd .. && \
    rm -f hdf-${HDF4_VER}-2.tar.gz 

#Build HDF-EOS2 lib.
ARG HDFEOS2_VER=2.20v1.00
RUN wget -O hdf-eos${HDFEOS2_VER}.tar.Z https://git.earthdata.nasa.gov/rest/git-lfs/storage/DAS/hdfeos/cb0f900d2732ab01e51284d6c9e90d0e852d61bba9bce3b43af0430ab5414903?response-content-disposition=attachment%3B%20filename%3D%22HDF-EOS${HDFEOS_VER}.tar.Z%22%3B%20filename*%3Dutf-8%27%27HDF-EOS2.20v1.00.tar.Z && \
    tar zxvf hdf-eos${HDFEOS2_VER}.tar.Z && \
    cd hdfeos && \
    ./configure --enable-install-include --with-hdf4=/usr/local && \
    make && make check && make install && \
    cd .. && \
    rm -f hdf-eos${HDFEOS2_VER}.tar.Z

# Build HDF5 lib.
ARG HDF5_VER=1.14.4-2
ARG HDF5_DOTVER=1.14.4.2
RUN wget https://github.com/HDFGroup/hdf5/releases/download/hdf5_${HDF5_DOTVER}/hdf5-${HDF5_VER}.tar.gz && \
    tar zxvf hdf5-${HDF5_VER}.tar.gz && \
    cd hdf5-${HDF5_VER} && \
    ./configure && \
    make && make check && make install && \
    cd .. && \
    rm -f hdf5-${HDF5_VER}.tar.gz

# Build netCDF C lib.
ARG NETCDF_C_VER=4.9.2
RUN wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDF_C_VER}.tar.gz && \
    tar zxvf v${NETCDF_C_VER}.tar.gz && \
    cd netcdf-c-${NETCDF_C_VER} && \
    CPPFLAGS="-Ihdf5-${HDF5_VER}/include -Ihdf-${HDF4_VER}-2/include" \
    LDFLAGS="-Lhdf5-${HDF5_VER}/lib -Lhdf-${HDF4_VER}-2/lib" && \
    ./configure --prefix=/usr/local --disable-byterange --enable-shared --enable-hdf4 --enable-hdf4-file-tests && \
    make && make check && make install && \
    cd .. && rm -rf netcdf-c-${NETCDF_C_VER} && rm -f v${NETCDF_C_VER}.tar.gz

# Build H4CF Conversion Toolkit
ARG H4CF_VER=1.3
RUN wget http://hdfeos.org/software/h4cflib/h4cflib_${H4CF_VER}.tar.gz && \
    tar zxvf h4cflib_${H4CF_VER}.tar.gz && \
    cd h4cflib_${H4CF_VER} && \
    CPPFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib LD_LIBRARY_PATH=-L/usr/local/lib && \
    ./configure --with-hdf4=hdf-${HDF4_VER}-2 --with-hdfeos2=hdfeos --with-netcdf=hdf5-${HDF5_VER} && \
    make && make install && \
    cd .. && \
    rm -f hf4cflib_${H4CF_VER}.tar.gz

ENV LD_LIBRARY_PATH /usr/local/lib
