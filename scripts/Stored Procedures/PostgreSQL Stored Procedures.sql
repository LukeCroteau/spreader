CREATE OR REPLACE FUNCTION agent_check(ANetName TEXT) RETURNS integer AS $$
  DECLARE
    err_code TEXT = '';
    err_msg TEXT := '';
    result INTEGER;
    agentid INTEGER = -1;
  BEGIN
    BEGIN
      SELECT id INTO result FROM agents WHERE netname = ANetName LIMIT 1;
      IF FOUND AND NOT result ISNULL THEN
        UPDATE agents SET lastping = Now() WHERE id = result;
      ELSE
        INSERT INTO agents (name, netname,lastping) VALUES (ANetName, ANetName,Now());
        SELECT id INTO result FROM agents WHERE netname = ANetName LIMIT 1;
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
    result = agent_check(ANetName);
    UPDATE agents SET lastping = Now(), version = AVersion, cpucount = ACPUCount, totalmemory = ATotalMemory WHERE id = result;
    RETURN result;
  END;
$$ LANGUAGE 'plpgsql';
