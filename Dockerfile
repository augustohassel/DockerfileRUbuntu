FROM ubuntu:bionic

RUN apt-get update -qq && apt-get upgrade -y

# paquetes globales
RUN apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    pandoc \
    pandoc-citeproc \
    libmariadbclient-dev \
    libsodium-dev \
    curl \
    gnupg \
    vim \
    telnet \
    locales \
    apt-utils \
    lsb-release \
    software-properties-common \
    && apt-get clean all

# configuracion locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# instalacion de R
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add -

RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get install -q -y \
      r-base-dev \
      r-recommended \ 
    && echo 'options(repos = c(CRAN = "https://cloud.r-project.org"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
    && rm -rf /var/lib/apt/lists/*

# descargar drivers para MSSQL    
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update -qq && \
    ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    mssql-tools \
    unixodbc-dev
    
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN ["/bin/bash", "-c", "source ~/.bashrc "]

# Actualizar nuevamente todos los paquetes
RUN apt-get update -qq && \
    apt-get install -y
	
# Limpiar 
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*
