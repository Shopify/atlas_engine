FROM docker.elastic.co/elasticsearch/elasticsearch:8.11.0

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch analysis-icu
