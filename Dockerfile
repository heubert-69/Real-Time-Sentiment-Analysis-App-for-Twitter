FROM rocker/shiny:latest

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev libssl-dev libxml2-dev libpq-dev python3 python3-pip

# Install R packages
RUN R -e "install.packages(c('shiny', 'rtweet', 'dplyr', 'ggplot2', 'plotly', 'DBI', 'RPostgres', 'httr', 'jsonlite'))"

# Install Python dependencies
RUN pip3 install flask transformers torch --break-system-packages

COPY . /srv/shiny-server/
WORKDIR /srv/shiny-server

EXPOSE 3838
CMD ["/usr/bin/shiny-server"]

