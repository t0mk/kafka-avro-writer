# Kafka consumer of Avro messages

This repo contains resources for Docker container wrapping a Kafka consumer of Avro messages. The consumer subscribes to a topic, and stores messages to Avro container files. The files can then be copied to S3 and subsequently loaded to Redshift with the COPY command.

## Usage

Before using this tool, you need to:

* Get the Docker image (`docker pull t0mk/kafka-avro-writer`) or build it yourself (`docker build -t t0mk/kafka-avro-writer ./`).
* Find out your Kafka broker's `hostname:port`, and your scheme registry URL.
* Know the topic of the messages that you want to store.
* Have Avro schema of the messages of the topic (something like [resources/Request.avsc](resources/Request.avsc))
* Know your way with simple Docker volumes at least a bit

### Configuration

The consumer container is configured via envrionment variables. There is

- `out_dir`: directory in the container fs, where it should output the avro files. Having `out_dir` to volume is probably a good idea.
- `topic`: which topic should the consumer subscribe to.
- `topic_schema_path`: Avro schema (avsc file) of the message for the topic. Examples are in resources dir in this repo.
- `rotate_interval`: how often should the avro files be rotated. In pytimeparse format (https://github.com/wroberts/pytimeparse).
- `librdkafka_config`: string containing yaml dict for config of librdkafka broker. It should at least contain keys for `bootstrap.servers` and `schema.registry.url`. All the possible keys are documented at https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md.

Example configuration is in [compose-example.yml](compose-example.yml) in this repo. It defines 2 services which dump Avro messages from localhost broker to files in specified directory. The Avro files are rotated in specified intervals. All the files with `.avro` suffices can be copied to S3, and then loaded to Redshift as described below.

The two consumer can be run as:

```
$ docker compose -f compose-example.yml up
```

## Loading to Redshift

The Avro container files created by `kafka_avro_writer` can be loaded from S3 to Redshift with the COPY command.

To load Avro data to Redshift, we first need to get psql console to Redshift cluster. Find out your hostname and port in Redshift web console, and your username/password for the database. Getting a psql console then can be similar to:

```
psql -h aaa.cq5qghejvqym.us-west-2.Redshift.amazonaws.com -U tomk -p 5439 dev
```

If this is the first time uploading the data to the cluster, we first need to create the tables in Redshift. According to the Request schema in [resources/Request.avsc](resources/request.avsc), the create SQL can be like [resources/Request.sql](resources/Request.sql) in this repo.

If the field names in your schema contain upper-case letters, we need to supply JSONPaths file to tell Redshift which field is which column. The order in the JSONPaths list must be the same as the order in the columns in the database table.
For illustration, you can see [resources/Request.avropath](resources/Request.avropath) in this repo.

The COPY command can then be something like

```
copy request from 's3://<bucket>/<file>' with credentials 'aws_access_key_id=<your_access_key_id>;aws_secret_access_key=<your_secret_access_key>' region as '<region_where_your_bucket_is>' format as avro 's3://<bucket>/<JSONPaths_file>';
```

## References

AVRO with JSONPaths: http://docs.aws.amazon.com/redshift/latest/dg/r_COPY_command_examples.html#copy-from-avro-examples-using-avropaths

COPY: http://docs.aws.amazon.com/Redshift/latest/dg/r_COPY.html
