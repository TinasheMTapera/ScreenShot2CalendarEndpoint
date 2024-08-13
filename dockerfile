FROM rocker/r-ver

RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# add layer of dependency for httpuv
# RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
# RUN R -e "remotes::install_github('r-lib/later')"

# if you’d like the renv.lock lockfile to be used to install R 
# packages when the Docker image is built, you’ll need to copy it to the container:
WORKDIR /project
RUN mkdir -p renv
COPY renv.lock renv.lock

# set the RENV_PATHS_LIBRARY environment variable to a writable path within your Docker container
ENV RENV_PATHS_LIBRARY renv/library


# dependencies
RUN apt-get update && apt-get install -y \
libxml2-dev \
libssl-dev \
libcurl4-openssl-dev \
libz-dev \
libfontconfig1-dev \
libharfbuzz-dev \
libfribidi-dev \
libfreetype6-dev \
libpng-dev \
libtiff5-dev \
libjpeg-dev \
libgit2-dev \
libpoppler-cpp-dev \
libsodium-dev \
libtesseract-dev \
tesseract-ocr-eng \
libleptonica-dev \
pandoc \
qpdf


# copy the project
COPY . .
RUN rm -rf renv

# copy the renv auto-loader tools into the container so that a 
# project-local library can be automatically provisioned and used 
# when R is launched.
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json


# run renv to install/load packages
# RUN R -e "renv::init()"
RUN R -e "renv::restore()"

RUN R -e "devtools::check()"
RUN R -e "devtools::install()"

# expose the port for the api
EXPOSE 8080

# entrypoint
CMD [ "Rscript", "run.R" ]