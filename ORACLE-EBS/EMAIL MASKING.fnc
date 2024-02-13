CREATE OR REPLACE FUNCTION MASKING (p__input IN VARCHAR2)
RETURN VARCHAR2
IS
v__mailmasking VARCHAR2(32767);
BEGIN
SELECT RPAD(SUBSTR( SUBSTR(p__input,1,INSTR(p__input,'@')-1) ,1,1),LENGTH(SUBSTR(p__input,1,INSTR(p__input,'@')-1) ),'*')||SUBSTR(p__input,INSTR(p__input,'@'),100)
INTO v__mailmasking
FROM DUAL;
RETURN v__mailmasking;
END;




SELECT MASKING('mid.asifjamil5@hotmail.com')
FROM DUAL;
--------------------------------------------------
----------------documentation---------------------
--------------------------------------------------
SELECT RTRIM('md.asifjamil5@gmail.com','@gmail.com')
FROM DUAL;


SELECT TRIM(TRAILING '@' FROM 'Tech1@abc.com')
FROM DUAL;

SELECT SUBSTR('md.asifjamil5@gmail.com',1,14-1)     --md.asifjamil5
FROM DUAL;

SELECT SUBSTR('md.asifjamil5@gmail.com',14,100)     --gmail.com
FROM DUAL;

SELECT INSTR('md.asifjamil5@gmail.com','@')             --POSITION 14
FROM DUAL;


SELECT RPAD(SUBSTR( SUBSTR('md.asifjamil5@gmail.com',1,14-1) ,1,1),LENGTH(SUBSTR('md.asifjamil5@gmail.com',1,INSTR('md.asifjamil5@gmail.com','@')-1) ),'X')||SUBSTR('md.asifjamil5@gmail.com',INSTR('md.asifjamil5@gmail.com','@'),100)    --mXXXXXXXXXX
FROM DUAL;


SELECT RPAD(substr('md.asifjamil5',1,1),LENGTH('md.asifjamil5'),'X')
FROM DUAL;



