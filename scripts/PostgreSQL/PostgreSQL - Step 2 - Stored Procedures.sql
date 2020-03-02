CREATE OR REPLACE FUNCTION concat_with_semicolon(text, text) RETURNS text AS $$
    SELECT CASE WHEN $1 IS NULL OR $1 = '' THEN $2
            WHEN $2 IS NULL OR $2 = '' THEN $1
            ELSE $1 || ';' || $2
            END; 
$$ LANGUAGE SQL;

CREATE AGGREGATE concat_with_semicolon_agg (
  sfunc = concat_with_semicolon,
  basetype = text,
  stype = text,
  initcond = ''
);

CREATE OR REPLACE FUNCTION public.gettableid(text, text) RETURNS int AS $$
    SELECT CAST(relfilenode AS int) FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE (c.relkind = 'r') AND (Lower(n.nspname) = Lower($1)) AND (Lower(relname) = Lower($2))
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION agent_addjob(integer,integer) RETURNS void AS $$
  INSERT INTO agents_workers (agentid, jobid) VALUES ($1,$2);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_check(ANetName TEXT) RETURNS agents AS $$
  DECLARE
    err_code TEXT = '';
    err_msg TEXT := '';
    result agents;
    agentid INTEGER = -1;
  BEGIN
    BEGIN
      SELECT * INTO result FROM agents WHERE netname = ANetName LIMIT 1;
      IF FOUND AND NOT result.id ISNULL THEN
        UPDATE agents SET lastping = Now() WHERE id = result.id;
      ELSE
        SELECT id INTO agentid FROM agents WHERE netname = ANetName LIMIT 1;
        IF agentid IsNull THEN
          INSERT INTO agents (name, netname,lastping) VALUES (ANetName, ANetName,Now());
          SELECT * INTO result FROM agents WHERE netname = ANetName LIMIT 1;
        END IF;
      END IF;
    EXCEPTION WHEN others THEN 
      err_code = SQLSTATE;
      err_msg = SQLERRM;
    END;
    IF err_msg <> '' THEN
      RAISE EXCEPTION 'Exception in agent_check: %', err_msg;
    ELSE
      RETURN result;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION agent_init(ANetName TEXT, AVersion TEXT, ACPUCount INTEGER, ATotalMemory INTEGER) RETURNS integer AS $$
  DECLARE
    result integer = 0;
  BEGIN
    PERFORM agent_check(ANetName);
    UPDATE agents SET lastping = Now(), version = AVersion, cpucount = ACPUCount, totalmemory = ATotalMemory WHERE netname = ANetName RETURNING id INTO result;
    RETURN result;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION agent_log(integer,integer,text) RETURNS void AS $$
  INSERT INTO agents_log (agentid, log_type, message) VALUES ($1,$2,$3);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_log(integer,integer,integer,text) RETURNS void AS $$
  INSERT INTO agents_log (agentid, jobid, log_type, message) VALUES ($1,$2,$3,$4);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_logdebug(integer,text) RETURNS void AS $$
  SELECT agent_log($1,0,$2);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_logerror(integer,text) RETURNS void AS $$
  SELECT agent_log($1,3,$2);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_logmessage(integer,text) RETURNS void AS $$
  SELECT agent_log($1,1,$2);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_logwarning(integer,text) RETURNS void AS $$
  SELECT agent_log($1,2,$2);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_toggle(AAgentID integer) RETURNS void AS $$
  UPDATE agents SET active = not active WHERE id = $1
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_workers_log(integer,integer,integer,integer,integer,text) RETURNS void AS $$
  INSERT INTO agents_log (agentid, workerid, jobid, taskid, log_type, message) VALUES ($1,$2,$3,$4,$5,$6);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION agent_workers(integer) RETURNS SETOF view_agents_workers AS $$
  SELECT * FROM view_agents_workers WHERE agentid = $1 ORDER BY id;
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION agent_worker(integer) RETURNS view_agents_workers AS $$
  SELECT * FROM view_agents_workers WHERE id = $1 LIMIT 1;
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION job_getaccessid(AJobID INTEGER, AAccessCode TEXT) RETURNS integer AS $$
  DECLARE
    result INTEGER;
  BEGIN
    SELECT id INTO result FROM jobs_access WHERE jobid = AJobID AND code = AAccessCode;
    IF (AAccessCode IS NOT NULL AND AAccessCode != '') AND result IS NULL THEN
      RAISE EXCEPTION 'Access Code not found for Job #% (%)',AJobID, AAccessCode;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION job_getid(text) RETURNS INTEGER AS $$
  SELECT id FROM jobs WHERE code = $1;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION job_log(integer,integer,text) RETURNS void AS $$
  INSERT INTO jobs_log (jobid, log_type, message) VALUES ($1,$2,$3);
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION jobs_cron_check(AAgentID integer) RETURNS VOID AS $$
  DECLARE
    err_code TEXT = '';
    err_msg TEXT := '';
    crondata record;
    crontableid integer;
    newtaskid integer;
  BEGIN
    crontableid = gettableid('public','jobs_cron');
    IF pg_try_advisory_lock(crontableid,0) THEN
      BEGIN
        FOR crondata IN SELECT C.id, C.jobid,C.description,C.taskkey,C.params,C.accessid FROM jobs_cron C JOIN jobs J on C.jobid = J.id WHERE J.active AND C.active AND COALESCE(C.last_run, C.created) < current_date + starttime AND now() >= current_date + starttime AND ((substr(C.daysofweek, EXTRACT(DOW FROM now())::int+1,1) not in ('', ' ')) or ((C.dayofmonth <> 0) and (make_date(cast(extract(year from now()) as int), cast(extract(month from now()) as int), C.dayofmonth) > COALESCE(C.last_run, C.created)))) FOR UPDATE LOOP
          BEGIN 
            SELECT task_add(crondata.jobid,crondata.taskkey,crondata.params,crondata.accessid) INTO newtaskid;
            UPDATE jobs_cron SET last_taskid=newtaskid,last_run = now() WHERE id = crondata.id;
            PERFORM agent_log(AAgentID, crondata.jobid, 1, 'Executed Cron Job: ' || crondata.description);
            NOTIFY AGENTCHECK;
          EXCEPTION WHEN others THEN 
            PERFORM job_log(crondata.jobid, 3, 'Unable to execute Cron Job: ' || crondata.description || ': ' || SQLERRM);
            PERFORM agent_log(AAgentID, crondata.jobid, 3, 'Unable to execute Cron Job: ' || crondata.description || ': ' || SQLERRM);
          END;
        END LOOP;
      EXCEPTION WHEN others THEN 
        err_code = SQLSTATE;
        err_msg = SQLERRM;
      END;
      PERFORM pg_advisory_unlock(crontableid,0);
    END IF;
    IF err_msg <> '' THEN
      RAISE EXCEPTION 'Exception in jobs_cron_check: %', err_msg;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION jobs_cron_run(ACronID integer) RETURNS integer AS $$
  DECLARE
    err_code TEXT = '';
    err_msg TEXT := '';
    crondata record;
    crontableid integer;
    newtaskid integer;
  BEGIN
    crontableid = gettableid('public','jobs_cron');
    IF pg_try_advisory_lock(crontableid,0) THEN
      BEGIN
        SELECT C.id, C.jobid,C.description,C.taskkey,C.params,C.accessid INTO crondata FROM jobs_cron C JOIN jobs J on C.jobid = J.id WHERE J.active AND C.active AND C.id = ACronID;
        IF FOUND THEN
          BEGIN 
            SELECT task_add(crondata.jobid,crondata.taskkey,crondata.params,crondata.accessid) INTO newtaskid;
            UPDATE jobs_cron SET last_taskid=newtaskid,last_run = now() WHERE id = crondata.id;
            PERFORM job_log(crondata.jobid, 1, 'Executed Cron Job: ' || crondata.description);
            NOTIFY AGENTCHECK;
          EXCEPTION WHEN others THEN 
            PERFORM job_log(crondata.jobid, 3, 'Unable to execute Cron Job: ' || crondata.description || ': ' || SQLERRM);
          END;
        ELSE
          RAISE EXCEPTION 'Exception in jobs_cron_run: Cron Job not found or not active.';
        END IF;
      EXCEPTION WHEN others THEN 
        err_code = SQLSTATE;
        err_msg = SQLERRM;
      END;
      PERFORM pg_advisory_unlock(crontableid,0);
    END IF;
    IF err_msg <> '' THEN
      RAISE EXCEPTION 'Exception in jobs_cron_run: %', err_msg;
    END IF;
    return newtaskid;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION worker_add(AJobID integer, AAgentID integer) RETURNS integer AS $$
  INSERT INTO agents_workers (jobid, agentid,active) VALUES ($1,$2,true) RETURNING id;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION worker_remove(AWorkerID integer) RETURNS void AS $$
  DELETE FROM agents_workers WHERE id = $1;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION worker_toggle(AWorkerID integer) RETURNS void AS $$
  UPDATE agents_workers SET active = not active WHERE id = $1
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION worker_addaccess(AWorkerID INTEGER, AAccessCode TEXT) RETURNS boolean AS $$
  DECLARE
    WorkerJobID integer;
    CurrAccessID integer;
    result BOOLEAN = False;
  BEGIN
    BEGIN
      SELECT jobid INTO WorkerJobID FROM agents_workers WHERE id = AWorkerID;
      SELECT id INTO CurrAccessID FROM jobs_access WHERE jobid = WorkerJobID AND code = AAccessCode;
      IF CurrAccessID IS NOT NULL THEN
        INSERT INTO agents_workers_access (workerid, accessid) VALUES (AWorkerID, CurrAccessID);
        result = True;
      END IF;
    EXCEPTION WHEN others THEN
      result = False;
    END;
    RETURN result;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION worker_removeaccess(AWorkerID INTEGER, AAccessCode TEXT) RETURNS boolean AS $$
  DECLARE
    WorkerJobID integer;
    CurrAccessID integer;
    result BOOLEAN = False;
  BEGIN
    BEGIN
      SELECT jobid INTO WorkerJobID FROM agents_workers WHERE id = AWorkerID;
      SELECT id INTO CurrAccessID FROM jobs_access WHERE jobid = WorkerJobID AND code = AAccessCode;
      IF CurrAccessID IS NOT NULL THEN
        DELETE FROM agents_workers_access WHERE workerid = AWorkerID AND accessID = CurrAccessID;
        result = True;
      END IF;
    EXCEPTION WHEN others THEN
      result = False;
    END;
    RETURN result;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION worker_hasaccess(AWorkerID INTEGER, AJobID INTEGER, AAccessID INTEGER) RETURNS boolean AS $$
  DECLARE
    CurrAccessID INTEGER;
  BEGIN
    IF AAccessID IS NULL THEN
      RETURN True;
    ELSE
      SELECT W.accessid INTO CurrAccessID FROM agents_workers_access W JOIN jobs_access A ON A.id = W.accessid WHERE W.workerid = AWorkerID AND A.jobid = AJobID AND W.accessid = AAccessID;
      RETURN CurrAccessID IS NOT NULL;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION worker_hasaccess(AWorkerID INTEGER, AJobID INTEGER, AAccessCode TEXT) RETURNS boolean AS $$
  DECLARE
    CurrAccessID INTEGER;
  BEGIN
    IF AAccessCode IS NULL OR AAccessCode = '' THEN
      RETURN True;
    ELSE
      SELECT W.accessid INTO CurrAccessID FROM agents_workers_access W JOIN jobs_access A ON A.id = accessid WHERE W.workerid = AWorkerID AND A.jobid = AJobID AND A.code = AAccessCode;
      RETURN CurrAccessID IS NOT NULL;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION worker_ping(integer) RETURNS void AS $$
  UPDATE agents_workers SET lastping = Now() WHERE id = $1;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION worker_info(integer, text) RETURNS void AS $$
  UPDATE agents_workers SET lastping = Now(), version = $2 WHERE id = $1;
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION task_add(AJobID integer, ATaskKey text, AParams text, AAccessID integer) RETURNS INTEGER AS $$
  DECLARE
    err_code TEXT = '';
    err_msg TEXT := '';
    TaskKeyValue TEXT;
    jobtableid integer;
    taskkeyactive boolean = False;
    taskid integer;
  BEGIN
    TaskKeyValue = ATaskKey;
    IF TaskKeyValue = '' OR TaskKeyValue IS NULL THEN
      TaskKeyValue = NULL;
    ELSE
      jobtableid = gettableid('public','jobs');
      PERFORM pg_advisory_lock(jobtableid,AJobID);
      BEGIN
        PERFORM id FROM tasks WHERE jobid = AJobID AND taskkey = TaskKeyValue AND (NOT processed AND processed_with_errors) LIMIT 1;
        IF FOUND THEN
          RAISE EXCEPTION 'Task Key in use for Job #%: %', AJobID, TaskKeyValue;
        END IF;
      EXCEPTION WHEN others THEN 
        err_code = SQLSTATE;
        err_msg = SQLERRM;
      END;
      PERFORM pg_advisory_unlock(jobtableid,AJobID);
    END IF;
    IF err_msg <> '' THEN
      RAISE EXCEPTION 'Exception in task_add: %',err_msg;
    ELSE
      INSERT INTO tasks (jobid,taskkey,params,accessid) VALUES (AJobID,TaskKeyValue,AParams,AAccessID) RETURNING id INTO taskid;
      RETURN taskid;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION task_add(AJobID integer, ATaskKey text, AParams text, AAccessID text) RETURNS INTEGER AS $$
  SELECT task_add($1, $2, $3, job_getaccessid($1, $4));
$$ LANGUAGE sql VOLATILE;

CREATE OR REPLACE FUNCTION task_getnext(AWorkerID integer, ASessionID TEXT) RETURNS tasks AS $$
  DECLARE
    err_code TEXT = '';
    err_msg TEXT := '';
    taskdata tasks;
    result tasks;
    worker agents_workers;
    jobtableid integer;
  BEGIN
    BEGIN
      SELECT * INTO STRICT worker FROM agents_workers WHERE id = AWorkerID;
      IF worker.active THEN
        jobtableid = gettableid('public','jobs');
        PERFORM pg_advisory_lock(jobtableid,0);
        BEGIN
          SELECT * INTO taskdata FROM tasks WHERE jobid = worker.jobid AND NOT processed AND NOT processing AND worker_hasaccess(worker.id,worker.jobid,accessid) AND ((workerid IS NULL) OR (workerid != AWorkerID) OR (now() >= stoptime + interval '1 minute')) ORDER BY id LIMIT 1 FOR UPDATE;
          IF FOUND AND NOT taskdata.id ISNULL THEN
            UPDATE tasks SET processed = False, processing = True, starttime = Now(), stoptime = Null, agentid = worker.agentid, workerid = worker.id WHERE id = taskdata.id;
            result = taskdata;
          END IF;
        EXCEPTION WHEN others THEN 
          err_code = SQLSTATE;
          err_msg = SQLERRM;
        END;
        PERFORM pg_advisory_unlock(jobtableid,0);
      END IF;
    EXCEPTION WHEN others THEN 
      err_code = SQLSTATE;
      err_msg = SQLERRM;
    END;
    IF err_msg <> '' THEN
      RAISE EXCEPTION 'Exception in task_getnext: %', err_msg;
    ELSE
      IF NOT result.id ISNULL THEN
        PERFORM agent_logdebug(worker.agentid, 'Task ' || result.id || ' was acquired by Worker ' || AWorkerID);
      END IF;
      RETURN result;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION task_stop(AWorkerID INTEGER, ATaskID INTEGER, ASuccess BOOLEAN, ASessionID TEXT) RETURNS boolean AS $$
  DECLARE
    err_code TEXT = '';
    err_msg TEXT := '';
    result BOOLEAN := False;
    jobtableid integer;
    worker agents_workers;
  BEGIN
    jobtableid = gettableid('public','jobs');
    SELECT * INTO STRICT worker FROM agents_workers WHERE id = AWorkerID;
    PERFORM pg_advisory_lock(jobtableid,0);
    BEGIN
      UPDATE tasks SET processed = CASE WHEN now() - created <= interval '1 minute' THEN worker.active AND ASuccess ELSE worker.active END, processing = False, processed_with_errors = NOT ASuccess, stoptime = Now()
        WHERE workerid = AWorkerid AND id = ATaskID RETURNING id = ATaskID INTO result;
      IF result IS NULL THEN
        result = False;
      END IF;
    EXCEPTION WHEN others THEN 
      err_code = SQLSTATE;
      err_msg = SQLERRM;
    END;
    PERFORM pg_advisory_unlock(jobtableid,0);
    IF err_msg <> '' THEN
      RAISE EXCEPTION 'Exception in task_stop: %', err_msg;
    ELSE
      PERFORM agent_logdebug(worker.agentid, 'Task ' || ATaskID || ' was finished by Worker ' || AWorkerID);
      RETURN result;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';
