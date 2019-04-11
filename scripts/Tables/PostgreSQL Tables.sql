DROP TABLE IF EXISTS agents CASCADE;
CREATE TABLE agents (
  id SERIAL UNIQUE PRIMARY KEY,
  created TIMESTAMP DEFAULT Now(),
  active BOOLEAN DEFAULT False,
  lastping TIMESTAMP,
  name VARCHAR NOT NULL,
  netname VARCHAR UNIQUE NOT NULL,
  version VARCHAR,
  cpucount INTEGER,
  totalmemory INTEGER
);

CREATE INDEX agents_netname ON agents (netname);
