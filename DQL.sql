-- Q1
SELECT 
    e.employee_id,
    e.first_name, 
    e.last_name,
    COUNT(t.task_id) AS active_task_count
FROM 
    employees e
LEFT JOIN 
    task_assignments ta ON e.employee_id = ta.employee_id
LEFT JOIN 
    tasks t ON ta.task_id = t.task_id 
    AND t.status IN ('Not Started', 'In Progress', 'Blocked') 
GROUP BY 
    e.employee_id, 
    e.first_name, 
    e.last_name
HAVING 
    COUNT(t.task_id) < 5;

-- Q2
SELECT
    p.project_id,
    p.project_name,
    p.status,
    p.priority,
    p.budget,
    COALESCE(SUM(pe.amount), 0) AS total_expenses,
    p.budget - COALESCE(SUM(pe.amount), 0) AS remaining_budget,
    ROUND(
        COALESCE(SUM(pe.amount), 0) / p.budget * 100, 2
    )AS budget_used_percentage,
    CASE
        WHEN COALESCE(SUM(pe.amount), 0) >= p.budget 
            THEN 'BUDGET EXCEEDED'
        WHEN COALESCE(SUM(pe.amount), 0) >= p.budget * 0.9 
            THEN 'CLOSE TO LIMIT'
        ELSE 'OK'
    END  AS budget_status
FROM projects p
LEFT JOIN project_expenses pe 
    ON p.project_id = pe.project_id
GROUP BY
    p.project_id,
    p.project_name,
    p.status,
    p.priority,
    p.budget
ORDER BY budget_used_percentage DESC;

--Q3
SELECT
    c.client_id,
    c.company_name,
    c.industry,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COUNT(DISTINCT CASE 
        WHEN p.status = 'Active' THEN p.project_id 
    END) AS active_projects,
    COALESCE(SUM(p.budget), 0) AS total_budget,
    ROUND(AVG(m.completion_percentage), 2) AS avg_milestone_completion,
    COUNT(DISTINCT m.milestone_id) AS total_milestones
FROM clients c
LEFT JOIN projects p ON c.client_id = p.client_id
LEFT JOIN milestones m ON p.project_id = m.project_id
GROUP BY
    c.client_id,
    c.company_name,
    c.industry
ORDER BY total_budget DESC;


--Q4
SELECT
    p.project_id,
    p.project_name,
    p.status,
    p.budget,
    COALESCE(revenue.total_revenue, 0) AS total_revenue,
    COALESCE(expenses.total_expenses, 0) AS total_expenses,
    COALESCE(revenue.total_revenue, 0) 
        - COALESCE(expenses.total_expenses, 0) AS profit,
    CASE
        WHEN COALESCE(revenue.total_revenue, 0) 
           - COALESCE(expenses.total_expenses, 0) > 0 
            THEN 'Profitable'
        WHEN COALESCE(revenue.total_revenue, 0) 
           - COALESCE(expenses.total_expenses, 0) = 0 
            THEN 'Break Even'
        ELSE 'Loss'
    END AS profitability_status
FROM projects p
LEFT JOIN (
    SELECT
        pe_emp.project_id,
        SUM(tl.hours_logged * e.hourly_rate) AS total_revenue
    FROM project_employee pe_emp
    INNER JOIN time_logs tl ON pe_emp.employee_id = tl.employee_id
    INNER JOIN employees e ON tl.employee_id = e.employee_id
    WHERE tl.billable = TRUE
    GROUP BY pe_emp.project_id
) revenue ON p.project_id = revenue.project_id

LEFT JOIN (
    SELECT
        project_id,
        SUM(amount) AS total_expenses
    FROM project_expenses
    GROUP BY project_id
) expenses ON p.project_id = expenses.project_id
ORDER BY profit DESC;


--Q5
SELECT
    p.priority,
    COUNT(DISTINCT p.project_id) AS total_projects,
    COUNT(r.risk_id) AS total_risks,
    ROUND(AVG(r.risk_probability * r.risk_level), 4) AS avg_risk_score,
    ROUND(MAX(r.risk_probability * r.risk_level), 4) AS max_risk_score,
    ROUND(SUM(r.risk_probability * r.risk_level), 4) AS total_risk_score,
    COALESCE(SUM(p.budget), 0) AS total_budget,
  
    ROUND(
        SUM(r.risk_probability * r.risk_level) * SUM(p.budget), 2
    ) AS total_risk_exposure,
    COUNT(CASE 
        WHEN r.risk_probability * r.risk_level > 0.7 
        THEN 1 
    END) AS high_risk_count
FROM projects p
LEFT JOIN project_risks r ON p.project_id = r.project_id
GROUP BY p.priority
ORDER BY
    CASE p.priority
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low'THEN 4
        ELSE 5
    END;


--Q6
SELECT 
    d.department_name,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    COUNT(DISTINCT es.employee_id) AS employees_with_certified_skills,
    COUNT(es.skill_id) AS total_certified_skills,
    ROUND(AVG(es.proficiency_level), 2) AS avg_proficiency_level
FROM departments d
JOIN employees e ON d.department_id = e.department_id
LEFT JOIN employee_skills es ON e.employee_id = es.employee_id AND es.certified = TRUE 
GROUP BY d.department_id, d.department_name
ORDER BY total_certified_skills DESC, avg_proficiency_level DESC;


--Q7
SELECT 
    r.role_name,
    s.skill_name,
    rs.required_proficiency,
    COUNT(DISTINCT e.employee_id) AS employees_meeting_requirement
FROM roles r
JOIN role_skills rs ON r.roles_id = rs.roles_id
JOIN skills s ON rs.skill_id = s.skill_id
LEFT JOIN employee_skills es ON rs.skill_id = es.skill_id AND es.proficiency_level >= rs.required_proficiency
LEFT JOIN employees e ON es.employee_id = e.employee_id
GROUP BY r.roles_id, r.role_name, s.skill_id, s.skill_name, rs.required_proficiency
ORDER BY r.role_name, employees_meeting_requirement DESC;



--Q8
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    r.role_name,
    s.skill_name,
    rs.required_proficiency,
    COALESCE(es.proficiency_level, 0) AS current_proficiency,
    CASE 
        WHEN es.skill_id IS NULL THEN 'Skill Not Acquired'
        WHEN es.proficiency_level < rs.required_proficiency THEN 'Below Required Proficiency'
    END AS gap_reason
FROM employees e
JOIN roles r ON e.roles_id = r.roles_id
JOIN role_skills rs ON r.roles_id = rs.roles_id
JOIN skills s ON rs.skill_id = s.skill_id
LEFT JOIN employee_skills es ON e.employee_id = es.employee_id AND rs.skill_id = es.skill_id
WHERE es.skill_id IS NULL OR es.proficiency_level < rs.required_proficiency
ORDER BY e.employee_id, s.skill_name;


--Q9
SELECT 
    m.milestone_id,
    m.milestone_name,
    m.due_date,
    m.status AS milestone_status,
    COUNT(mt.task_id) AS total_tasks,
    COUNT(CASE WHEN t.status = 'Completed' THEN mt.task_id END) AS completed_tasks,
    ROUND(
        COUNT(CASE WHEN t.status = 'Completed' THEN mt.task_id END) * 100.0 
        / NULLIF(COUNT(mt.task_id), 0), 2
    ) AS task_completion_pct
FROM milestones m
LEFT JOIN milestone_tasks mt ON m.milestone_id = mt.milestone_id
LEFT JOIN tasks t ON mt.task_id = t.task_id
WHERE m.due_date < CURRENT_DATE 
  AND m.status NOT IN ('Completed', 'Achieved')
GROUP BY m.milestone_id, m.milestone_name, m.due_date, m.status
ORDER BY m.due_date ASC;


--Q10
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(tl.time_log_id) AS total_time_logs,
    COALESCE(SUM(tl.hours_logged), 0) AS total_hours_logged,
    CASE
        WHEN COUNT(tl.time_log_id) = 0 THEN 'No Activity'
        WHEN COUNT(tl.time_log_id) < 5 THEN 'Low Activity'
        ELSE 'Active'
    END AS activity_status
FROM employees e
LEFT JOIN time_logs tl ON e.employee_id = tl.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_hours_logged DESC;


--Q11
SELECT
    e1.employee_id AS employee_1_id,
    CONCAT(e1.first_name, ' ', e1.last_name) AS employee_1,
    e2.employee_id AS employee_2_id,
    CONCAT(e2.first_name, ' ', e2.last_name) AS employee_2,
    d.department_name
FROM employees e1
JOIN employees e2 ON e1.department_id = e2.department_id AND e1.employee_id < e2.employee_id
JOIN departments d ON e1.department_id = d.department_id
ORDER BY d.department_name;



--Q12
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(ta.task_id) AS total_tasks,
    CASE
        WHEN COUNT(ta.task_id) = 0 THEN 'No Workload'
        WHEN COUNT(ta.task_id) BETWEEN 1 AND 3 THEN 'Light Load'
        WHEN COUNT(ta.task_id) BETWEEN 4 AND 7 THEN 'Moderate Load'
        ELSE 'High Load'
    END AS workload_level
FROM employees e
LEFT JOIN task_assignments ta ON e.employee_id = ta.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_tasks DESC;


--Q13
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.hourly_rate,
    d.department_name,
    ROUND(dep_avg.avg_salary, 2) AS department_avg_salary,
    CASE
        WHEN e.hourly_rate > dep_avg.avg_salary THEN 'Above Average'
        WHEN e.hourly_rate = dep_avg.avg_salary THEN 'Average'
        ELSE 'Below Average'
    END AS salary_status
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN (
    SELECT department_id, AVG(hourly_rate) AS avg_salary
    FROM employees
    GROUP BY department_id
) dep_avg
    ON e.department_id = dep_avg.department_id
ORDER BY d.department_name, e.hourly_rate DESC;




