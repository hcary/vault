
CREATE DATABASE vault;


CREATE USER vault_dba WITH ENCRYPTED PASSWORD 'jx2gWs4duitr3kmdcz$RTma9';
GRANT ALL PRIVILEGES ON DATABASE vault TO vault_dba;

CREATE ROLE vault_user WITH ENCRYPTED PASSWORD 'B$LaCgsBjKcS0PQF9QcAlBTB' LOGIN;


CREATE TABLE vault_kv_store (
  parent_path TEXT COLLATE "C" NOT NULL,
  path        TEXT COLLATE "C",
  KEY         TEXT COLLATE "C",
  value       BYTEA,
  CONSTRAINT pkey PRIMARY KEY (path, key)
);

CREATE INDEX parent_path_idx ON vault_kv_store (parent_path);


CREATE TABLE vault_ha_locks (
  ha_key                                      TEXT COLLATE "C" NOT NULL,
  ha_identity                                 TEXT COLLATE "C" NOT NULL,
  ha_value                                    TEXT COLLATE "C",
  valid_until                                 TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT ha_key PRIMARY KEY (ha_key)
);

GRANT SELECT, INSERT, UPDATE, DELETE ON vault_kv_store TO vault_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON vault_ha_locks TO vault_user;
