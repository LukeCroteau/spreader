CREATE OR REPLACE VIEW view_agents_workers AS
  SELECT W.id, W.created, A.active AND W.active AND J.active AS active, W.lastping, W.agentid, A.name as agentname, A.netname, 
    W.jobid, J.name as jobname, W.version,
    (SELECT concat_with_semicolon_agg(A.code) 
       FROM agents_workers_access WA 
       JOIN jobs_access A ON A.id = WA.accessID 
       WHERE WA.workerid = W.id) as accesscodes
  FROM agents_workers W 
  JOIN agents A ON A.id = W.agentid
  JOIN jobs J ON J.id = W.jobid 
  ORDER BY id;

CREATE OR REPLACE VIEW view_tasks AS 
  SELECT 
    T.id as taskid,
    T.jobid, J.name as jobname, J.code as jobcode,
    JA.code AS accesscode,
    T.processed, T.processing, T.processed_with_errors,
    T.agentid, A.name as agentname,
    T.workerid, T.accessid,
    T.created,T.starttime,T.stoptime,
    CASE WHEN T.processing THEN now() - T.starttime ELSE T.stoptime - T.starttime END as duration,
    CASE WHEN T.processed THEN 'Processed' WHEN T.processing THEN 'Processing' ELSE 'Pending' END as status,
    T.taskkey,T.params
  FROM tasks T
  JOIN jobs J ON J.id = T.jobid
  LEFT JOIN agents A ON A.id = T.agentid
  LEFT JOIN jobs_access JA ON JA.jobid = T.jobid AND JA.id = T.accessid;
  
CREATE OR REPLACE VIEW view_agents_log AS
  SELECT 
    L.id, L.created,
    L.agentid, A.name as agentname,
    L.log_type, LT.name as log_type_dsc,
    L.message,
    L.jobid, J.name as jobname, L.taskid, T.taskkey, L.workerid
  FROM agents_log L
  LEFT JOIN agents A ON A.id = L.agentid
  LEFT JOIN agents_log_types LT ON L.log_type = LT.id
  LEFT JOIN jobs J ON L.jobid = J.id
  LEFT JOIN tasks T on L.taskid = T.id;
  
CREATE OR REPLACE VIEW view_jobs_log AS
  SELECT 
    L.id, L.created,
    L.log_type, LT.name as log_type_dsc,
    L.message,
    L.jobid, J.name as jobname
  FROM jobs_log L
  LEFT JOIN jobs_log_types LT ON L.log_type = LT.id
  LEFT JOIN jobs J ON L.jobid = J.id;
  
CREATE OR REPLACE VIEW view_jobs_cron AS 
  SELECT 
    C.id, C.created, C.active, C.description, C.daysofweek, C.dayofmonth, C.starttime, 
    C.jobid, J.name as jobname,
    C.accessid, JA.code AS accesscode,
    C.last_run, C.last_taskid,
    C.taskkey,C.params
  FROM jobs_cron C
  JOIN jobs J ON J.id = C.jobid
  LEFT JOIN jobs_access JA ON JA.jobid = C.jobid AND JA.id = C.accessid;
