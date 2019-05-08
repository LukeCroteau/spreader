DROP TABLE IF EXISTS jobs CASCADE;
CREATE TABLE jobs (
  id SERIAL UNIQUE PRIMARY KEY,
  created TIMESTAMP DEFAULT Now(),
  active BOOLEAN DEFAULT True,
  code VARCHAR UNIQUE,
  name VARCHAR,
  uri VARCHAR,
  params TEXT
);

DROP TABLE IF EXISTS jobs_access CASCADE;
CREATE TABLE jobs_access (
  id SERIAL UNIQUE,
  jobid INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
  created TIMESTAMP DEFAULT Now(),
  code VARCHAR NOT NULL,
  name VARCHAR,
  primary key (jobid,code)
);

DROP TABLE IF EXISTS jobs_log_types CASCADE;
CREATE TABLE jobs_log_types (
  id INTEGER UNIQUE,
  name VARCHAR,
  primary key (id)
);

DROP TABLE IF EXISTS jobs_log CASCADE;
CREATE TABLE jobs_log (
  id SERIAL UNIQUE,
  created TIMESTAMP DEFAULT Now(),
  jobid INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
  log_type INTEGER REFERENCES jobs_log_types(id) ON DELETE CASCADE,
  message TEXT,
  primary key (id)
);

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

DROP TABLE IF EXISTS agents_workers CASCADE;
CREATE TABLE agents_workers (
  id SERIAL UNIQUE,
  created TIMESTAMP DEFAULT Now(),
  active BOOLEAN DEFAULT True,
  lastping TIMESTAMP,
  agentid INTEGER REFERENCES agents(id) ON DELETE CASCADE,
  jobid INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
  version VARCHAR,
  primary key (id)
);

DROP TABLE IF EXISTS agents_workers_access CASCADE;
CREATE TABLE agents_workers_access (
  workerid INTEGER REFERENCES agents_workers(id) ON DELETE CASCADE,
  accessid INTEGER REFERENCES jobs_access(id) ON DELETE CASCADE,
  created TIMESTAMP DEFAULT Now(),
  primary key (workerid, accessid)
);

DROP TABLE IF EXISTS tasks CASCADE;
CREATE TABLE tasks (
  id SERIAL UNIQUE PRIMARY KEY,
  created timestamp DEFAULT Now(),
  jobid INTEGER NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  taskkey VARCHAR,
  params TEXT,
  processed BOOLEAN DEFAULT False,
  processing BOOLEAN DEFAULT False,
  processed_with_errors BOOLEAN DEFAULT False,
  starttime TIMESTAMP,
  stoptime TIMESTAMP,
  agentid integer REFERENCES agents(id) ON DELETE SET NULL,
  workerid integer REFERENCES agents_workers(id) ON DELETE SET NULL,
  accessid integer REFERENCES jobs_access(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS agents_log_types CASCADE;
CREATE TABLE agents_log_types (
  id INTEGER UNIQUE,
  name VARCHAR,
  primary key (id)
);

DROP TABLE IF EXISTS agents_log CASCADE;
CREATE TABLE agents_log (
  id SERIAL UNIQUE,
  created TIMESTAMP DEFAULT Now(),
  agentid INTEGER REFERENCES agents(id) ON DELETE SET NULL,
  jobid INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
  taskid INTEGER REFERENCES tasks(id) ON DELETE CASCADE,
  workerid INTEGER REFERENCES agents_workers(id) ON DELETE SET NULL,
  log_type INTEGER REFERENCES agents_log_types(id) ON DELETE CASCADE,
  message TEXT,
  primary key (id)
);

DROP TABLE IF EXISTS jobs_cron CASCADE;
CREATE TABLE jobs_cron (
  id SERIAL UNIQUE,
  jobid INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
  created TIMESTAMP DEFAULT Now(),
  active BOOLEAN DEFAULT True,
  description VARCHAR NOT NULL DEFAULT '',
  daysofweek CHAR(7) NOT NULL DEFAULT '       ',
  dayofmonth INTEGER NOT NULL DEFAULT 0,
  starttime TIME NOT NULL,
  accessid integer REFERENCES jobs_access(id) ON DELETE RESTRICT,
  taskkey VARCHAR,
  params VARCHAR NOT NULL,
  last_run TIMESTAMP,
  last_taskid INTEGER REFERENCES tasks(id) ON DELETE SET NULL,
  primary key (id)
);
