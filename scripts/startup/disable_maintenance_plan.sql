WHENEVER SQLERROR EXIT SQL.SQLCODE
SET SERVEROUTPUT ON

DECLARE
  PROCEDURE disable_window(p_window VARCHAR2) IS
  BEGIN
    DBMS_SCHEDULER.DISABLE(
      name  => 'SYS.' || p_window,
      force => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('Janela desabilitada: ' || p_window);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE NOT IN (-27477) THEN
        DBMS_OUTPUT.PUT_LINE('Falha ao desabilitar ' || p_window || ': ' || SQLERRM);
        RAISE;
      ELSE
        DBMS_OUTPUT.PUT_LINE('Janela já estava desabilitada: ' || p_window);
      END IF;
  END;
BEGIN
  FOR wnd IN (
    SELECT window_name
      FROM dba_scheduler_windows
     WHERE window_name IN (
       'MONDAY_WINDOW','TUESDAY_WINDOW','WEDNESDAY_WINDOW','THURSDAY_WINDOW',
       'FRIDAY_WINDOW','SATURDAY_WINDOW','SUNDAY_WINDOW','WEEKNIGHT_WINDOW'
     )
  ) LOOP
    disable_window(wnd.window_name);
  END LOOP;

  BEGIN
    DBMS_SCHEDULER.DISABLE(
      name  => 'SYS.MAINTENANCE_WINDOW_GROUP',
      force => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('Grupo SYS.MAINTENANCE_WINDOW_GROUP desabilitado.');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE NOT IN (-27476) THEN
        DBMS_OUTPUT.PUT_LINE('Falha ao desabilitar grupo: ' || SQLERRM);
        RAISE;
      ELSE
        DBMS_OUTPUT.PUT_LINE('Grupo já estava desabilitado.');
      END IF;
  END;
END;
/

ALTER SYSTEM SET RESOURCE_MANAGER_PLAN = '' SCOPE=BOTH;
PROMPT Resource Manager desabilitado.
EXIT;
