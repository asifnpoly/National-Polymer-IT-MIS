SELECT fcpl.user_concurrent_program_name, 
       fcpl.concurrent_program_name, 
       fcpl.application_id, 
       fa.application_short_name
FROM   fnd_concurrent_programs_vl fcpl
JOIN   fnd_application fa
ON     fcpl.application_id = fa.application_id
WHERE  UPPER(fcpl.user_concurrent_program_name) LIKE '%'||UPPER(:REPORT_FULL_NAME)||'%';
/
