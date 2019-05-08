CREATE INDEX agents_netname ON agents (netname);

CREATE INDEX agents_log_agentid_created ON agents_log (agentid,created);
CREATE INDEX agents_log_created ON agents_log (created);
CREATE INDEX agents_log_created_log_type ON agents_log (created) WHERE log_type >= 2;
CREATE INDEX agents_log_log_type ON agents_log (log_type);
CREATE INDEX agents_log_jobid ON agents_log (jobid);
CREATE INDEX agents_log_jobid_created ON agents_log (jobid,created);
CREATE INDEX agents_log_jobid_created_log_type ON agents_log (jobid,created) WHERE log_type >= 2;
CREATE INDEX agents_log_taskid ON agents_log (taskid);
CREATE INDEX agents_log_workerid ON agents_log (workerid);
CREATE INDEX agents_log_workerid_created ON agents_log (workerid,created);

CREATE INDEX tasks_processed ON tasks (processed);
CREATE INDEX tasks_processing ON tasks (processing);
CREATE INDEX tasks_process_with_errors ON tasks (processed_with_errors) WHERE processed;
CREATE INDEX tasks_stoptime_processed_without_errors ON tasks (stoptime) WHERE processed AND NOT processed_with_errors;
CREATE INDEX tasks_stoptime_processed_with_errors ON tasks (stoptime) WHERE processed AND processed_with_errors;
CREATE INDEX tasks_taskkey ON tasks (taskkey) WHERE NOT processed;

CREATE INDEX jobs_cron_jobid ON jobs_cron(jobid);
