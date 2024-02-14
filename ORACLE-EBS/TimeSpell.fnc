create FUNCTION time_spell(p_days VARCHAR2) RETURN VARCHAR2 IS 
v_y NUMBER; 
v_yd NUMBER; 
v_m NUMBER; 
v_md NUMBER; 
v_d NUMBER; 
v_w NUMBER; 
v_wd NUMBER; 
v_days NUMBER; 
v_yi NUMBER; 
v_mi NUMBER; 
v_wi  NUMBER; 
BEGIN 
SELECT p_days/365 INTO v_y FROM dual; 
if v_y not like '%.%' then 
SELECT trunc(v_y) INTO v_yi FROM dual; 
select substr(v_y||'.0',(select instr(v_y||'.0','.') from dual)) INTO v_yd from dual; 
SELECT v_yd * 12 INTO v_m FROM dual; 
SELECT trunc(v_m) INTO v_mi FROM dual; 
select substr(v_m,(select instr(v_m,'.') from dual)) INTO v_md from dual; 
SELECT v_md * 30 INTO v_d FROM dual; 
SELECT v_d / 7 INTO v_w FROM dual; 
SELECT trunc(v_w) INTO v_wi FROM dual; 
select substr(v_w,(select instr(v_w,'.') from dual)) INTO v_wd from dual; 
SELECT round(v_wd * 7) INTO v_days FROM dual; 
RETURN v_yi||' Year '||v_mi||' Month '||v_wi||' Week '||v_days||' Day '; 
else 
SELECT trunc(v_y) INTO v_yi FROM dual; 
select substr(v_y,(select instr(v_y,'.') from dual)) INTO v_yd from dual; 
SELECT v_yd * 12 INTO v_m FROM dual; 
SELECT trunc(v_m) INTO v_mi FROM dual; 
select substr(v_m,(select instr(v_m,'.') from dual)) INTO v_md from dual; 
SELECT v_md * 30 INTO v_d FROM dual; 
SELECT v_d / 7 INTO v_w FROM dual; 
SELECT trunc(v_w) INTO v_wi FROM dual; 
select substr(v_w,(select instr(v_w,'.') from dual)) INTO v_wd from dual; 
SELECT round(v_wd * 7) INTO v_days FROM dual; 
RETURN v_yi||' Year '||v_mi||' Month '||v_wi||' Week '||v_days||' Day '; 
end if; 
END; 
/