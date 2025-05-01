ARG BASE_IMAGE=registry.gitlab.com/thelabnyc/python:py313@sha256:e1ed3aaeb702ac20c0340dcb09ae51d125738cabaa48516df73e98eb733fa91d
FROM ${BASE_IMAGE}

# Environment Settings
ENV GEOIP_PATH "/data/geo"
ENV GEOIP_COUNTRY "GeoLite2-Country.mmdb"
ENV GEOIP_CITY "GeoLite2-City.mmdb"
ENV LIBMAXMINDDB_VERSION "1.6.0"

# Create directories
RUN mkdir -p "$GEOIP_PATH"

# Install GeoIP2 C library
# See https://docs.djangoproject.com/en/dev/ref/contrib/gis/geoip2/
RUN cd "/tmp/" && \
    wget --quiet "https://github.com/maxmind/libmaxminddb/releases/download/$LIBMAXMINDDB_VERSION/libmaxminddb-$LIBMAXMINDDB_VERSION.tar.gz" && \
    tar -zxf "libmaxminddb-$LIBMAXMINDDB_VERSION.tar.gz" && \
    rm "libmaxminddb-$LIBMAXMINDDB_VERSION.tar.gz" && \
    cd "/tmp/libmaxminddb-$LIBMAXMINDDB_VERSION/" && \
    ./configure && \
    make && \
    make check && \
    make install && \
    ldconfig && \
    rm -r "/tmp/libmaxminddb-$LIBMAXMINDDB_VERSION"

# Accept Maxmind License Key as a build arg
# See https://blog.maxmind.com/2019/12/18/significant-changes-to-accessing-and-using-geolite2-databases/
ARG MAXMIND_LICENSE_KEY

# Add and unzip the GeoIP2 databases
COPY data/* "$GEOIP_PATH/"
RUN cd "$GEOIP_PATH" && \
    tar xvzf "$GEOIP_PATH/$GEOIP_COUNTRY.tar.gz" && \
    mv $GEOIP_PATH/GeoLite2-Country_*/* "$GEOIP_PATH/" && \
    rmdir $GEOIP_PATH/GeoLite2-Country_* && \
    rm "$GEOIP_PATH/$GEOIP_COUNTRY.tar.gz"
RUN cd "$GEOIP_PATH" && \
    tar xvzf "$GEOIP_PATH/$GEOIP_CITY.tar.gz" && \
    mv $GEOIP_PATH/GeoLite2-City_*/* "$GEOIP_PATH/" && \
    rmdir $GEOIP_PATH/GeoLite2-City_* && \
    rm "$GEOIP_PATH/$GEOIP_CITY.tar.gz"

# Install the GeoIP Python library
RUN pip install --no-cache-dir --upgrade "geoip2"

# Install IPython, because it's nice to have
RUN pip install --no-cache-dir --upgrade "ipython"

# Optionally install Geospatial libraries
ARG GEOSPATIAL
RUN if [ "$GEOSPATIAL" = "true" ]; then \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get update; \
        apt-get install -yq \
            binutils \
            libproj-dev \
            gdal-bin; \
        rm -rf /var/lib/apt/lists/*; \
        unset DEBIAN_FRONTEND; \
    fi
