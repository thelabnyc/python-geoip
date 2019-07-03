ARG BASE_IMAGE=python
ARG PYTHON_VERSION=3.6
FROM ${BASE_IMAGE}:${PYTHON_VERSION}

# Optionally install Geospatial libraries
ARG GEOSPATIAL
RUN if [ "$GEOSPATIAL" = "true" ]; then \
        apt-get update; \
        apt-get install -y binutils libproj-dev gdal-bin; \
        rm -rf /var/lib/apt/lists/*; \
    fi

# Environment Settings
ENV GEOIP_PATH "/data/geo"
ENV GEOIP_COUNTRY "GeoLite2-Country.mmdb"
ENV GEOIP_CITY "GeoLite2-City.mmdb"
ENV LIBMAXMINDDB_VERSION "1.3.2"

# Create directories
RUN mkdir -p "$GEOIP_PATH"

# Install GeoIP2 C library
# See https://docs.djangoproject.com/en/dev/ref/contrib/gis/geoip2/
RUN cd "/tmp/" && \
    wget "https://github.com/maxmind/libmaxminddb/releases/download/$LIBMAXMINDDB_VERSION/libmaxminddb-$LIBMAXMINDDB_VERSION.tar.gz" && \
    tar -zxf "libmaxminddb-$LIBMAXMINDDB_VERSION.tar.gz" && \
    rm "libmaxminddb-$LIBMAXMINDDB_VERSION.tar.gz" && \
    cd "/tmp/libmaxminddb-$LIBMAXMINDDB_VERSION/" && \
    ./configure && \
    make && \
    make check && \
    make install && \
    ldconfig && \
    rm -r "/tmp/libmaxminddb-$LIBMAXMINDDB_VERSION"

# Download and unzip the GeoIP2 Country database
RUN cd "$GEOIP_PATH" && \
    wget "https://geolite.maxmind.com/download/geoip/database/$GEOIP_COUNTRY.gz" && \
    gunzip "$GEOIP_PATH/$GEOIP_COUNTRY.gz"

# Download and unzip the GeoIP2 City database
RUN cd "$GEOIP_PATH" && \
    wget "https://geolite.maxmind.com/download/geoip/database/$GEOIP_CITY.gz" && \
    gunzip "$GEOIP_PATH/$GEOIP_CITY.gz"

# Install the GeoIP Python library
RUN pip install --no-cache-dir --upgrade "geoip2"

# Install IPython, because it's nice to have
RUN pip install --no-cache-dir --upgrade "ipython"
