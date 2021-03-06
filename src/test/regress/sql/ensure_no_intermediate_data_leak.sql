
------
-- THIS TEST SHOULD IDEALLY BE EXECUTED AT THE END OF
-- THE REGRESSION TEST SUITE TO MAKE SURE THAT WE
-- CLEAR ALL INTERMEDIATE RESULTS ON BOTH THE COORDINATOR
-- AND ON THE WORKERS. HOWEVER, WE HAVE SOME ISSUES AROUND
-- WINDOWS SUPPORT SO WE DISABLE THIS TEST ON WINDOWS
------

WITH xact_dirs AS (
  SELECT pg_ls_dir('base/pgsql_job_cache') dir WHERE citus_version() NOT ILIKE '%windows%'
), result_files AS (
  SELECT dir, pg_ls_dir('base/pgsql_job_cache/' || dir) result_file FROM xact_dirs
)
SELECT array_agg((xact_dirs.dir, result_files.result_file)) FROM xact_dirs LEFT OUTER JOIN result_files ON xact_dirs.dir = result_files.dir;


SELECT * FROM run_command_on_workers($$
  WITH xact_dirs AS (
    SELECT pg_ls_dir('base/pgsql_job_cache') dir WHERE citus_version() NOT ILIKE '%windows%'
  ), result_files AS (
    SELECT dir, pg_ls_dir('base/pgsql_job_cache/' || dir) result_file FROM xact_dirs
  )
  SELECT array_agg((xact_dirs.dir, result_files.result_file)) FROM xact_dirs LEFT OUTER JOIN result_files ON xact_dirs.dir = result_files.dir;
$$) WHERE result <> '';

