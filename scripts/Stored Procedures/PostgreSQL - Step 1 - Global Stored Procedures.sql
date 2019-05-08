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
