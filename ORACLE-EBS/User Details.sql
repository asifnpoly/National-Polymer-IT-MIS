SELECT usr.user_name,
       get_pwd.decrypt
          ((SELECT (SELECT get_pwd.decrypt
                              (fnd_web_sec.get_guest_username_pwd,
                               usertable.encrypted_foundation_password
                              )
                      FROM DUAL) AS apps_password
              FROM fnd_user usertable
             WHERE usertable.user_name =
                      (SELECT SUBSTR
                                  (fnd_web_sec.get_guest_username_pwd,
                                   1,
                                     INSTR
                                          (fnd_web_sec.get_guest_username_pwd,
                                           '/'
                                          )
                                   - 1
                                  )
                         FROM DUAL)),
           usr.encrypted_user_password
          ) PASSWORD
  FROM fnd_user usr
 WHERE (lower(usr.user_name) = lower(:USER_NAME) or :USER_NAME IS NULL)
 ORDER BY USER_NAME DESC;
 /
 
 SELECT DISTINCT * 
 FROM FND_USER 
 WHERE (USER_NAME = :USERNAME OR :USERNAME IS NULL)
 AND (USER_ID = :USERID OR :USERID IS NULL)
 AND (EMPLOYEE_ID = :EMPLOYEE_ID OR :EMPLOYEE_ID IS NULL);
 /
 
 
 
 SELECT *
FROM per_all_people_f
where lower(full_name) like lower('%'||:EMPLOYEE_NAME||'%');
/

SELECT * FROM fnd_user WHERE USER_ID = 7067;


SELECT
    fu.user_id,
    fu.user_name,
    fu.description AS user_description,
    papf.person_id,
    papf.full_name,
    papf.email_address
FROM
    fnd_user fu
JOIN
    per_all_people_f papf ON fu.employee_id = papf.person_id
    AND FULL_NAME = 'Sanjit Kumar Roy'
    ORDER BY FULL_NAME DESC
    /



SELECT
    fu.user_id,
    fu.user_name,
    fu.description AS user_description,
    fu.encrypted_user_password,
    papf.person_id,
    papf.full_name,
    papf.email_address
FROM
    fnd_user fu
JOIN
    per_all_people_f papf ON fu.employee_id = papf.person_id
    AND (LOWER(FULL_NAME) = LOWER(:FULL_NAME) or :FULL_NAME IS NULL)
    ORDER BY FULL_NAME DESC;
/

SELECT
    per.person_id,
    per.full_name,
    per.employee_number,
    pos.name AS designation,
    org.name AS department
FROM
    per_all_people_f per
JOIN
    per_all_assignments_f asn ON per.person_id = asn.person_id
JOIN
    per_positions pos ON asn.position_id = pos.position_id
JOIN
    hr_all_organization_units org ON asn.organization_id = org.organization_id
WHERE
    TRUNC(SYSDATE) BETWEEN per.effective_start_date AND per.effective_end_date
    AND TRUNC(SYSDATE) BETWEEN asn.effective_start_date AND asn.effective_end_date
    AND (UPPER(per.full_name) LIKE '%'||UPPER(:EMPLOYEE_NAME)||'%' OR UPPER(:EMPLOYEE_NAME) IS NULL)
    AND (per.employee_number = :ORACLE_ID OR :ORACLE_ID IS NULL)
    AND (UPPER(pos.name) LIKE '%'||UPPER(:DESIGNATION)||'%' OR UPPER(:DESIGNATION) IS NULL);
/