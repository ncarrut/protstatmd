FROM rocker/r-rmd:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
	&& apt-get install -y --no-install-recommends libcurl4-openssl-dev \
    libssl-dev/unstable \
    libxml2-dev \
    libnetcdf-dev \
    procps \
    python3.6 \
    rsync

RUN install2.r --error \
    BiocManager \
    conflicted \
    dplyr \
    DT \
    ggplot2 \
    gridExtra \
    htmltools \
    plotly \
    scales \
    tidyr \
    XML \
    xml2 \
    ncdf4
    

RUN Rscript -e 'BiocManager::install(version="3.12", update=TRUE, ask=FALSE)'

RUN Rscript -e 'BiocManager::install(c("edgeR", "MSnbase", "MSstats", "qvalue"), dependencies = TRUE)'

COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts
