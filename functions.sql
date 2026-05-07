-- Function 1: calculate_project_completion

CREATE OR REPLACE FUNCTION calculate_project_completion(p_project_id INT)
RETURNS NUMERIC AS $$
DECLARE
    weighted_task_amount NUMERIC;
BEGIN
    WITH milestone_stats AS (
        SELECT 
            m.completion_percentage,
            COUNT(mt.task_id) AS task_count
        FROM milestones m
        LEFT JOIN milestone_tasks mt ON m.milestone_id = mt.milestone_id
        WHERE m.project_id = p_project_id
        GROUP BY m.milestone_id, m.completion_percentage
    )
    SELECT COALESCE(
        SUM(completion_percentage * task_count) * 1.0 / NULLIF(SUM(task_count), 0), 0
    ) INTO weighted_task_amount
    FROM milestone_stats;

    RETURN weighted_task_amount;
END;
$$ LANGUAGE plpgsql;


-- Function 2: 

CREATE OR REPLACE FUNCTION get_task_time_efficiency(task_id_1 INT)
RETURNS VARCHAR(20) AS $$
DECLARE
  estimated INT;
  task_logged NUMERIC;
  ratio NUMERIC;
BEGIN
  SELECT estimated_hours INTO estimated 
  FROM tasks WHERE task_id = task_id_1;
  
  IF estimated IS NULL OR estimated = 0 THEN 
    RETURN 'No Estimate'; 
  END IF;

  SELECT COALESCE(SUM(hours_logged), 0) INTO task_logged 
  FROM time_logs WHERE task_id = task_id_1;

  ratio := (task_logged / estimated) * 100;

  IF ratio <= 80 THEN RETURN 'Efficient';
  ELSIF ratio <= 100 THEN RETURN 'On Track';
  ELSIF ratio <= 150 THEN RETURN 'Over Estimate';
  ELSE RETURN 'Critical';
  END IF;
END;
$$ LANGUAGE plpgsql;


-- Function 3: get_employee_workload_status 

CREATE OR REPLACE FUNCTION get_employee_workload_status(p_employee_id INT)
RETURNS VARCHAR(20) AS $$
DECLARE
  workload_count INT;
BEGIN 
  SELECT COUNT(*)
  INTO workload_count
  FROM task_assignments ta
  JOIN tasks t ON ta.task_id = t.task_id
  WHERE ta.employee_id = p_employee_id AND t.status IN ('Not Started', 'In Progress');

  IF workload_count < 5 THEN
    RETURN 'Available';
  ELSIF workload_count <= 8 THEN
    RETURN 'At Capacity';
  ELSE
    RETURN 'Overloaded';
  END IF;
END;
$$ LANGUAGE plpgsql;
