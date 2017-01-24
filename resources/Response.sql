create table Response (
  "responseID" varchar(36) not null distkey sortkey,
  "requestID" varchar(36),
  "bytesSize" int not null,
  /* occuredAt must be bigint, 4 bytes is not enough */
  "occurredAt" bigint not null,
);

