create OR REPLACE FUNCTION METE(p_number VARCHAR, p_parent VARCHAR, p_child VARCHAR) RETURN VARCHAR
IS
v___left VARCHAR2(4000);
v___right VARCHAR2(4000);
v___number VARCHAR2(4000);
BEGIN
SELECT p_number INTO v___number FROM DUAL WHERE p_number LIKE '%,%';
IF v___number IS NOT NULL THEN

select rtrim((select rtrim(p_number,(select substr(p_number,(select instr(p_number,',')from dual)+1) from dual)) from dual),',') 
into v___left
from dual;
select substr(p_number,(select instr(p_number,',')from dual)+1)
INTO v___right
from dual;

RETURN NVL(v___left,'0')||' '||p_parent||' '||NVL(v___right,'0')||' '||p_child;
ELSIF v___number IS NULL THEN
select substr(p_number,(select instr(p_number,',')from dual)+1) 
INTO v___right
from dual;
RETURN NVL(v___right,'0')||' '||p_parent;
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
select substr(p_number,(select instr(p_number,',')from dual)+1) 
INTO v___right
from dual;
RETURN NVL(v___right,'0')||' '||p_parent;
END;
/
