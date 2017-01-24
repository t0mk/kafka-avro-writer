create table Request (
  "requestID" varchar(36) not null distkey sortkey,
  "queryString" varchar(512) not null,
  "host" varchar(512) not null,
  "path" varchar(512) not null,
  "bytesSize" int not null,
  /* occuredAt must be bigint, 4 bytes is not enough */
  "occurredAt" bigint not null,
  "headers" varchar(8192) not null,
  "method" varchar(4) not null,
  "trafficType" varchar(4) not null
);
