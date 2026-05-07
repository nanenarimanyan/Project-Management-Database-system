-- Trigger 1

CREATE OR REPLACE FUNCTION check_budget_before_expense()
RETURNS TRIGGER AS $$
DECLARE
    new_budget         DECIMAL(15, 2);
    total_expenses DECIMAL(15, 2);
BEGIN
    SELECT budget
    INTO new_budget
    FROM projects
    WHERE project_id = NEW.project_id;

    SELECT COALESCE(SUM(amount), 0)
    INTO total_expenses
    FROM project_expenses
    WHERE project_id = NEW.project_id;

    IF (total_expenses + NEW.amount) > new_budget THEN
        RAISE EXCEPTION 
            'Budget exceeded for project ID %. Budget: %, Already spent: %, New expense: %, Remaining: %',
            NEW.project_id,
            new_budget,
            total_expenses,
            NEW.amount,
            (new_budget - total_expenses);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



-- Trigger 2
CREATE OR REPLACE FUNCTION block_time_on_finished_tasks() 
RETURNS TRIGGER AS $$
DECLARE
    task_status VARCHAR(20);
BEGIN
    SELECT status INTO task_status 
    FROM tasks 
    WHERE task_id = NEW.task_id;
    IF task_status IN ('Completed', 'Blocked') THEN RAISE EXCEPTION 'Cannot log time. Task % is already %.', NEW.task_id, task_status;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_block_time_on_finished_tasks
    BEFORE INSERT ON time_logs
    FOR EACH ROW EXECUTE FUNCTION block_time_on_finished_tasks();



-- Trigger 3
CREATE OR REPLACE FUNCTION task_hour_limit() RETURNS TRIGGER AS $$
DECLARE
  total_logged DECIMAL(5,2);
  estimated INT;
  max_limit DECIMAL(5,2);
BEGIN
  SELECT COALESCE(SUM(hours_logged), 0) INTO total_logged
  FROM time_logs
  WHERE task_id = NEW.task_id;

  SELECT estimated_hours INTO estimated
  FROM tasks
  WHERE task_id = NEW.task_id;

  IF estimated IS NULL THEN
    RETURN NEW;
  END IF;

  max_limit := estimated * 1.5;

  IF total_logged > max_limit THEN
    RAISE EXCEPTION 'Task % exceeds 150%% of estimated hours. Logged: %, Limit: %',
      NEW.task_id, total_logged, max_limit;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_enforce_task_hour_limit
  AFTER INSERT OR UPDATE OF hours_logged ON time_logs
  FOR EACH ROW EXECUTE FUNCTION task_hour_limit();


