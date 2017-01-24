FROM python:3.5

ENV LIBRDKAFKA_VERSION 0.9.1
RUN curl -Lk -o /root/librdkafka-${LIBRDKAFKA_VERSION}.tar.gz https://github.com/edenhill/librdkafka/archive/${LIBRDKAFKA_VERSION}.tar.gz && \
    tar -xzf /root/librdkafka-${LIBRDKAFKA_VERSION}.tar.gz -C /root && \
    cd /root/librdkafka-${LIBRDKAFKA_VERSION} && \
    ./configure && make && make install && make clean && ./configure --clean

ENV CPLUS_INCLUDE_PATH /usr/local/include
ENV LIBRARY_PATH /usr/local/lib
ENV LD_LIBRARY_PATH /usr/local/lib

RUN pip install avro-python3 PyYAML requests fastavro pytimeparse argh

ADD ./ /kafka-avro-writer
RUN git clone https://github.com/confluentinc/confluent-kafka-python /tmp/c
RUN cd /tmp/c && python setup.py build
RUN cd /tmp/c && pip install -e ./

WORKDIR /kafka-avro-writer

ENTRYPOINT ["/kafka-avro-writer/kafka_avro_writer"]

