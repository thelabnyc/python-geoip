ARG PYTHON_VERSION=3.6
FROM python:${PYTHON_VERSION}

# Environment Settings
ENV GEOIP_PATH "/data/geo"
ENV GEOIP_COUNTRY "GeoLite2-Country.mmdb"
ENV GEOIP_CITY "GeoLite2-City.mmdb"
ENV LIBMAXMINDDB_VERSION "1.2.0"

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
RUN pip install "geoip2"

# Install IPython, because it's nice to have
RUN pip install "ipython"
