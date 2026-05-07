CREATE INDEX idx_task_assignments_employee_task ON task_assignments(employee_id, task_id);
CREATE INDEX idx_projects_active ON projects(status) WHERE status = 'Active';
CREATE INDEX idx_milestones_project_id ON milestones(project_id);
CREATE INDEX idx_project_risks_project_id ON project_risks(project_id);
CREATE INDEX idx_project_expenses_project_id ON project_expenses(project_id);
CREATE INDEX idx_time_logs_task_id ON time_logs(task_id);
CREATE INDEX idx_time_logs_employee_id ON time_logs(employee_id);
CREATE INDEX idx_project_employee_employee_id ON project_employee(employee_id);