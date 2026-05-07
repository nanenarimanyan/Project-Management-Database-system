DROP TABLE IF EXISTS role_skills CASCADE; 
DROP TABLE IF EXISTS employee_skills CASCADE; 
DROP TABLE IF EXISTS milestone_tasks CASCADE; 
DROP TABLE IF EXISTS department_roles CASCADE; 
DROP TABLE IF EXISTS project_employee CASCADE; 
DROP TABLE IF EXISTS task_assignments CASCADE; 
DROP TABLE IF EXISTS time_logs CASCADE; 
DROP TABLE IF EXISTS tasks CASCADE; 
DROP TABLE IF EXISTS milestones CASCADE; 
DROP TABLE IF EXISTS project_expenses CASCADE; 
DROP TABLE IF EXISTS project_risks CASCADE; 
DROP TABLE IF EXISTS projects CASCADE; 
DROP TABLE IF EXISTS employees CASCADE; 
DROP TABLE IF EXISTS skills CASCADE; 
DROP TABLE IF EXISTS roles CASCADE; 
DROP TABLE IF EXISTS departments CASCADE; 
DROP TABLE IF EXISTS clients CASCADE; 

CREATE TABLE clients ( 
	client_id INT PRIMARY KEY, 
	company_name VARCHAR(255) NOT NULL, 
	contact_person_name VARCHAR(100), 
	email VARCHAR(100), phone_number VARCHAR(25), 
	address TEXT, industry VARCHAR(100), 
	CONSTRAINT chk_client_email 
		CHECK (email LIKE '%@%'), 
	CONSTRAINT chk_client_phone 
		CHECK (length(phone_number) = 10) ); 
		
CREATE TABLE departments ( 
	department_id INT PRIMARY KEY, 
	department_name VARCHAR(100) NOT NULL UNIQUE, 
	department_description TEXT, 
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	location VARCHAR(100), 
	CONSTRAINT chk_department_name 
		CHECK (length(trim(department_name)) > 0) ); 
		
CREATE TABLE roles ( 
	roles_id INT PRIMARY KEY, 
	role_name VARCHAR(100) NOT NULL, 
	role_description TEXT, 
	CONSTRAINT chk_role_name 
		CHECK (length(trim(role_name)) > 0) ); 
		
CREATE TABLE skills ( 
	skill_id INT PRIMARY KEY, 
	skill_name VARCHAR(100) NOT NULL, 
	skill_description TEXT, 
	profficiency_scale_max INT, 
	CONSTRAINT chk_skill_scale 
		CHECK (profficiency_scale_max BETWEEN 1 AND 10) ); 
		
CREATE TABLE employees ( 
	employee_id INT PRIMARY KEY, 
	first_name VARCHAR(50) NOT NULL, 
	last_name VARCHAR(50) NOT NULL, 
	email VARCHAR(100), 
	phone_number VARCHAR(25), 
	job_title VARCHAR(100), 
	employment_status VARCHAR(20) DEFAULT 'Active', 
	hire_date DATE, 
	hourly_rate DECIMAL(10,2), 
	department_id INT 
		REFERENCES departments(department_id) ON DELETE SET NULL, 
	roles_id INT 
		REFERENCES roles(roles_id) ON DELETE SET NULL, 
	CONSTRAINT chk_employee_email 
		CHECK (email LIKE '%@%'), 
	CONSTRAINT chk_employee_phone 
		CHECK (length(phone_number) = 10), 
	CONSTRAINT chk_employee_rate 
		CHECK (hourly_rate > 0), 
	CONSTRAINT chk_employee_status 
		CHECK ( employment_status IN ( 
				'Active', 
				'Remote', 
				'On Leave' ) 
				), 
	CONSTRAINT chk_employee_names 
		CHECK ( length(trim(first_name)) > 0 AND length(trim(last_name)) > 0 ) ); 
		
CREATE TABLE projects ( 
	project_id INT PRIMARY KEY, 
	project_name VARCHAR(255) NOT NULL, 
	project_manager_id INT REFERENCES 
	employees(employee_id) ON DELETE SET NULL, 
	client_id INT NOT NULL 
		REFERENCES clients(client_id) ON DELETE CASCADE, 
	budget DECIMAL(15,2), 
	status VARCHAR(20) DEFAULT 'Planning', 
	priority VARCHAR(20), 
	project_description TEXT, 
	start_date DATE, 
	end_date DATE, 
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	CONSTRAINT chk_project_budget 
		CHECK (budget > 0), CONSTRAINT chk_project_dates 
		CHECK (end_date >= start_date), 
	CONSTRAINT chk_project_status 
		CHECK ( status IN ( 
				'Planning', 
				'Active', 
				'Completed', 
				'On Hold', 
				'Cancelled'
				) 
			), 
	CONSTRAINT chk_project_priority 
		CHECK ( priority IN ( 
				'Low', 
				'Medium', 
				'High', 
				'Critical'
				) 
			), 
	CONSTRAINT chk_project_name 
		CHECK (length(trim(project_name)) > 0) ); 
		
CREATE TABLE milestones ( 
	milestone_id INT PRIMARY KEY, 
	project_id INT NOT NULL 
		REFERENCES projects(project_id) ON DELETE CASCADE, 
	milestone_name VARCHAR(255) NOT NULL, 
	milestone_description TEXT, 
	due_date DATE, 
	completion_percentage INT DEFAULT 0, 
	status VARCHAR(50), 
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	CONSTRAINT chk_milestone_completion 
		CHECK (completion_percentage BETWEEN 0 AND 100), 
	CONSTRAINT chk_milestone_status 
		CHECK ( status IN (
				'Not Started', 
				'In Progress',
				'Pending',
				'Completed', 
				'Delayed' 
				) 
			) 
		); 
		
CREATE TABLE tasks ( 
	task_id INT PRIMARY KEY, 
	task_description TEXT NOT NULL, 
	estimated_hours INT, status VARCHAR(20) DEFAULT 'Not Started', 
	CONSTRAINT chk_task_hours 
		CHECK (estimated_hours > 0), 
	CONSTRAINT chk_task_status 
		CHECK ( status IN ( 
				'Not Started', 
				'In Progress', 
				'Completed', 
				'Blocked'
				) 
			) 
		); 
		
CREATE TABLE project_risks ( 
	risk_id INT PRIMARY KEY, 
	project_id INT NOT NULL 
		REFERENCES projects(project_id) ON DELETE CASCADE, 
	risk_description TEXT NOT NULL, 
	risk_level DECIMAL(3,2), 
	risk_probability DECIMAL(3,2), 
	status VARCHAR(50), 
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	CONSTRAINT chk_risk_level 
		CHECK (risk_level BETWEEN 0 AND 100), 
	CONSTRAINT chk_risk_probability 
		CHECK (risk_probability BETWEEN 0 AND 1), 
	CONSTRAINT chk_risk_status 
		CHECK ( status IN ( 
				'Open', 
				'Mitigated', 
				'Closed' )
			)
		); 
		
CREATE TABLE project_expenses ( 
	expense_id INT PRIMARY KEY, 
	project_id INT NOT NULL 
		REFERENCES projects(project_id) ON DELETE CASCADE, 
	expense_name VARCHAR(255) NOT NULL, 
	amount DECIMAL(15,2), 
	expense_date DATE, 
	payment_status VARCHAR(20) DEFAULT 'Pending', 
	CONSTRAINT chk_expense_amount 
		CHECK (amount > 0), 
	CONSTRAINT chk_payment_status 
		CHECK ( payment_status IN ( 
				'Pending', 
				'Paid', 
				'Cancelled',
				'Not Paid'
			)
		)
	); 
	
CREATE TABLE time_logs ( 
	time_log_id INT PRIMARY KEY, 
	task_id INT NOT NULL 
		REFERENCES tasks(task_id) ON DELETE CASCADE, 
	employee_id INT NOT NULL 
		REFERENCES employees(employee_id) ON DELETE CASCADE, 
	hours_logged DECIMAL(5,2), 
	billable BOOLEAN DEFAULT TRUE, 
	CONSTRAINT chk_hours_logged 
		CHECK ( hours_logged > 0 AND hours_logged <= 24 ) ); 
		
CREATE TABLE task_assignments ( 
	task_id INT NOT NULL, 
	employee_id INT NOT NULL, 
	assigned_date DATE, PRIMARY KEY (task_id, employee_id), 
	FOREIGN KEY (task_id) 
		REFERENCES tasks(task_id) ON DELETE CASCADE, 
	FOREIGN KEY (employee_id) 
		REFERENCES employees(employee_id) ON DELETE CASCADE ); 
		
CREATE TABLE employee_skills ( 
	employee_id INT NOT NULL, 
	skill_id INT NOT NULL, 
	proficiency_level INT, 
	acquired_date DATE, 
	certified BOOLEAN, 
	PRIMARY KEY (employee_id, skill_id), 
	FOREIGN KEY (employee_id)
		REFERENCES employees(employee_id) ON DELETE CASCADE, 
	FOREIGN KEY (skill_id) 
		REFERENCES skills(skill_id) ON DELETE CASCADE, 
	CONSTRAINT chk_employee_skill_level 
		CHECK (proficiency_level BETWEEN 1 AND 10) ); 
		
CREATE TABLE role_skills ( 
	roles_id INT NOT NULL, 
	skill_id INT NOT NULL, 
	required_proficiency INT, 
	PRIMARY KEY (roles_id, skill_id), 
	FOREIGN KEY (roles_id) 
		REFERENCES roles(roles_id) ON DELETE CASCADE, 
	FOREIGN KEY (skill_id) 
		REFERENCES skills(skill_id) ON DELETE CASCADE, 
	CONSTRAINT chk_role_skill_level 
		CHECK (required_proficiency BETWEEN 1 AND 10) ); 
		
CREATE TABLE project_employee (
	project_id INT NOT NULL, 
	employee_id INT NOT NULL, 
	PRIMARY KEY (project_id, employee_id), 
	FOREIGN KEY (project_id) 
		REFERENCES projects(project_id) ON DELETE CASCADE, 
	FOREIGN KEY (employee_id) 
		REFERENCES employees(employee_id) ON DELETE CASCADE ); 
		
CREATE TABLE milestone_tasks ( 
	milestone_id INT NOT NULL, 
	task_id INT NOT NULL, 
	PRIMARY KEY (milestone_id, task_id), 
	FOREIGN KEY (milestone_id) 
		REFERENCES milestones(milestone_id) ON DELETE CASCADE, 
	FOREIGN KEY (task_id) 
		REFERENCES tasks(task_id) ON DELETE CASCADE ); 
		
CREATE TABLE department_roles ( 
	department_id INT NOT NULL, 
	roles_id INT NOT NULL, 
	PRIMARY KEY (department_id, roles_id), 
	FOREIGN KEY (department_id) 
		REFERENCES departments(department_id) ON DELETE CASCADE, 
	FOREIGN KEY (roles_id) 
		REFERENCES roles(roles_id) ON DELETE CASCADE );

		