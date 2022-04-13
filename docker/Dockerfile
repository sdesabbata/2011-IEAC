# Base image https://hub.docker.com/r/rocker/ml
FROM rocker/geospatial:4.1.1

# create an R user
ENV USER rstudio

# Install additional required R libraries
COPY ./Requirements.R /tmp/Requirements.R
RUN Rscript /tmp/Requirements.R