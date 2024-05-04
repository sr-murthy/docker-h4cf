FROM ubuntu:18.04

MAINTAINER The HDF-EOS Tools and Information Center <eoshelp@hdfgroup.org>

ENV HOME /root

COPY ["./apt.txt", "./"]

RUN apt update && apt install -yq $(grep -vE "^\s*#" ./apt.txt)

#Build HDF4 lib.
ARG HDF4_VER=4.2.16
RUN wget https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF4/HDF${HDF4_VER}-2/src/hdf-${HDF4_VER}-2.tar.gz && \
    tar zxvf hdf-${HDF4_VER}-2.tar.gz && \
    cd hdf-${HDF4_VER}-2 && \
    ./configure --prefix=/usr/local/ --enable-shared --disable-netcdf --disable-fortran && \
    make && make check && make install && \
    cd .. && \
    rm -f hdf-${HDF4_VER}-2.tar.gz 

#Build HDF-EOS2 lib.
ARG HDFEOS_VER=3.0
RUN wget -O hdf-eos2-${HDFEOS_VER}-src.tar.gz https://git.earthdata.nasa.gov/projects/DAS/repos/hdfeos/raw/hdf-eos2-${HDFEOS_VER}-src.tar.gz?at=3128a738021501c821549955f6c78348e5f33850 && \
    tar zxvf hdf-eos2-${HDFEOS_VER}-src.tar.gz && \
    cd hdf-eos2-${HDFEOS_VER} && \
    ./configure --prefix=/usr/local/ --enable-install-include  --with-hdf4=/usr/local && \
    make && make check && make install && \
    cd .. && \
    rm -f hdf-eos2-${HDFEOS_VER}-src.tar.gz 

# Build HDF5 lib.
ARG HDF5_VER=1.14.4-2
ARG HDF5_DOTVER=1.14.4.2
RUN wget https://github.com/HDFGroup/hdf5/releases/download/hdf5_${HDF5_DOTVER}/hdf5-${HDF5_VER}.tar.gz && \
    tar zxvf hdf5-${HDF5_VER}.tar.gz && \
    cd hdf5-${HDF5_VER} && \
    ./configure --prefix=/usr/local/ && \
    make && make check && make install && \
    cd .. && \
    rm -f hdf5-${HDF5_VER}.tar.gz

# Build netCDF C lib.
ARG NETCDF_C_VER=4.9.2
RUN wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDF_C_VER}.tar.gz && \
    tar zxvf v${NETCDF_C_VER}.tar.gz && \
    cd netcdf-c-${NETCDF_C_VER} && \
    CPPFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib LD_LIBRARY_PATH=-L/usr/local/lib && \
    ./configure --prefix=/usr/local --disable-byterange --enable-shared --enable-hdf4 --enable-hdf4-file-tests && \
    make && make check && make install && \
    cd .. && rm -rf netcdf-c-${NETCDF_C_VER} && rm -f v${NETCDF_C_VER}.tar.gz

# Build H4CF Conversion Toolkit
ARG H4CF_VER=1.3
RUN wget http://hdfeos.org/software/h4cflib/h4cflib_${H4CF_VER}.tar.gz && \
    tar zxvf h4cflib_${H4CF_VER}.tar.gz && \
    cd h4cflib_${H4CF_VER} && \
    CPPFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib LD_LIBRARY_PATH=-L/usr/local/lib && \
    ./configure --prefix=/usr/local/ --with-hdf4=/usr/local/ --with-hdfeos2=/usr/local/ --with-netcdf=/usr/local/ && \
    make && make install && \
    cd .. && \
    rm -f hf4cflib_${H4CF_VER}.tar.gz

ENV LD_LIBRARY_PATH /usr/local/lib
