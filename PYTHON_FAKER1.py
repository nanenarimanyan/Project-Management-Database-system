import random
from faker import Faker
from datetime import timedelta, datetime

fake = Faker()

SQL_FILE = "Final_Refined_DML.sql"

# =========================================================
# CONFIG
# =========================================================

DEPT_LIST = [
    "Operations", "Finance", "Marketing", "Sales", "Human Resources",
    "IT Support", "Software Engineering", "Legal", "Product Management",
    "Customer Success", "Public Relations", "Research and Development",
    "Supply Chain", "Quality Assurance", "Creative Design",
    "Facilities", "Cybersecurity", "Data Analytics", "Training",
    "Administration", "Business Development", "Customer Support",
    "Logistics", "E-commerce", "Sustainability", "Accounting",
    "Risk Management", "Strategic Planning", "Community Relations",
    "Hardware Engineering", "Inventory", "Manufacturing",
    "Procurement", "Event Management", "Internal Audit"
]

DEPARTMENT_DESCRIPTIONS = {
    "Operations": "Business operations management",
    "Finance": "Financial planning and reporting",
    "Marketing": "Marketing and brand promotion",
    "Sales": "Sales and client acquisition",
    "Human Resources": "Employee management and recruitment",
    "IT Support": "Technical support services",
    "Software Engineering": "Software development",
    "Legal": "Legal compliance and consulting",
    "Product Management": "Product planning and strategy",
    "Customer Success": "Client relationship management",
    "Public Relations": "Public communication management",
    "Research and Development": "Innovation and research",
    "Supply Chain": "Supply chain coordination",
    "Quality Assurance": "Quality control and testing",
    "Creative Design": "Creative content and design",
    "Facilities": "Facility operations management",
    "Cybersecurity": "Security and threat prevention",
    "Data Analytics": "Data analysis and reporting",
    "Training": "Employee education and training",
    "Administration": "Administrative support",
    "Business Development": "Business growth strategy",
    "Customer Support": "Customer assistance services",
    "Logistics": "Logistics and transportation",
    "E-commerce": "Online business operations",
    "Sustainability": "Environmental sustainability initiatives",
    "Accounting": "Accounting and bookkeeping",
    "Risk Management": "Risk assessment and mitigation",
    "Strategic Planning": "Strategic business planning",
    "Community Relations": "Community engagement",
    "Hardware Engineering": "Hardware systems engineering",
    "Inventory": "Inventory management",
    "Manufacturing": "Manufacturing operations",
    "Procurement": "Purchasing and procurement",
    "Event Management": "Event planning and coordination",
    "Internal Audit": "Internal auditing services"
}

ROLE_POOL = {
    "Software Engineering": [
        ("Backend Developer", "Develops server-side application logic and APIs"),
        ("Frontend Developer", "Builds and maintains user-facing interfaces"),
        ("DevOps Engineer", "Maintains deployment pipelines and infrastructure")
    ],
    "Finance": [
        ("Financial Analyst", "Analyzes budgets and financial performance"),
        ("Accountant", "Maintains accounting records and reports"),
        ("Payroll Specialist", "Processes payroll and compensation")
    ],
    "Marketing": [
        ("Marketing Specialist", "Creates marketing campaigns"),
        ("SEO Analyst", "Optimizes search visibility"),
        ("Content Strategist", "Manages content planning")
    ]
}

DEFAULT_ROLES = [
    ("Project Coordinator", "Coordinates project activities"),
    ("Operations Manager", "Oversees operational processes"),
    ("Business Analyst", "Analyzes business requirements")
]

SKILLS = [
    ("Python", "Programming language for backend and automation"),
    ("SQL", "Database querying and management"),
    ("Project Management", "Planning and managing projects"),
    ("Data Analysis", "Analyzing and interpreting data"),
    ("Communication", "Professional communication skills"),
    ("Cybersecurity", "Protecting systems and networks"),
    ("UI Design", "Designing user interfaces"),
    ("Cloud Computing", "Managing cloud infrastructure"),
    ("Machine Learning", "Building intelligent systems"),
    ("Financial Reporting", "Preparing financial reports")
]

PROJECT_TYPES = [
    "E-commerce Platform",
    "Mobile Banking System",
    "Inventory Management System",
    "AI Analytics Dashboard",
    "Customer Support Portal",
    "Cybersecurity Monitoring System",
    "HR Management Platform",
    "Sales Reporting Dashboard",
    "Logistics Tracking System",
    "Cloud Migration Project"
]

MILESTONE_DESCRIPTIONS = [
    "Requirements gathering completed",
    "System architecture finalized",
    "Core functionality implemented",
    "Integration testing completed",
    "User acceptance testing approved",
    "Production deployment completed"
]

TASK_DESCRIPTIONS = [
    "Develop authentication module",
    "Design database schema",
    "Implement REST API endpoints",
    "Conduct integration testing",
    "Prepare technical documentation",
    "Fix reported software bugs",
    "Optimize database queries",
    "Configure cloud infrastructure",
    "Develop dashboard components",
    "Perform security assessment"
]

RISK_DESCRIPTIONS = [
    "Backend developers may face API integration delays",
    "Cybersecurity engineers identified security vulnerabilities",
    "Project managers reported scheduling conflicts",
    "Financial analysts detected budget overrun risks",
    "DevOps engineers reported deployment instability",
    "Quality assurance team identified testing gaps",
    "Database administrators warned about bottlenecks",
    "Frontend developers may experience UI issues"
]

EXPENSE_TYPES = [
    "Cloud Infrastructure",
    "Software Licensing",
    "Employee Training",
    "Hardware Procurement",
    "Marketing Campaign",
    "Security Audit",
    "Consulting Services",
    "Travel Expenses"
]

# =========================================================
# HELPERS
# =========================================================

def clean(text):
    return str(text).replace("'", "''")

def get_phone():
    return "".join([str(random.randint(0, 9)) for _ in range(10)])

def sql_date(date_obj):
    return date_obj.strftime("%Y-%m-%d")

# =========================================================
# MAIN GENERATOR
# =========================================================

def generate_dml():

    with open(SQL_FILE, "w", encoding="utf-8") as f:

        f.write("BEGIN;\n\n")

        # =====================================================
        # DEPARTMENTS / ROLES
        # =====================================================

        role_id = 1
        department_roles_map = {}
        role_id_to_name = {}

        for dept_id, dept_name in enumerate(DEPT_LIST, 1):

            building = random.randint(1, 15)
            floor = random.randint(1, 10)
            room = random.randint(100, 999)

            location = f"Building {building} Floor {floor} Room {room}"

            f.write(f"""
INSERT INTO departments (
    department_id,
    department_name,
    department_description,
    location
)
VALUES (
    {dept_id},
    '{clean(dept_name)}',
    '{clean(DEPARTMENT_DESCRIPTIONS[dept_name])}',
    '{location}'
);
""")

            department_roles_map[dept_id] = []

            role_set = ROLE_POOL.get(dept_name, DEFAULT_ROLES)

            for role_name, role_desc in role_set:

                department_roles_map[dept_id].append(role_id)
                role_id_to_name[role_id] = role_name

                f.write(f"""
INSERT INTO roles (
    roles_id,
    role_name,
    role_description
)
VALUES (
    {role_id},
    '{clean(role_name)}',
    '{clean(role_desc)}'
);
""")

                f.write(f"""
INSERT INTO department_roles (
    department_id,
    roles_id
)
VALUES (
    {dept_id},
    {role_id}
);
""")

                role_id += 1

        # =====================================================
        # SKILLS
        # =====================================================

        for i in range(1, 301):

            skill_name, skill_desc = random.choice(SKILLS)

            f.write(f"""
INSERT INTO skills (
    skill_id,
    skill_name,
    skill_description,
    profficiency_scale_max
)
VALUES (
    {i},
    '{clean(skill_name)}',
    '{clean(skill_desc)}',
    {random.randint(1,10)}
);
""")

        # =====================================================
        # CLIENTS
        # =====================================================

        for i in range(1, 501):

            f.write(f"""
INSERT INTO clients (
    client_id,
    company_name,
    contact_person_name,
    email,
    phone_number,
    address,
    industry
)
VALUES (
    {i},
    '{clean(fake.company())}',
    '{clean(fake.name())}',
    '{fake.company_email()}',
    '{get_phone()}',
    '{clean(fake.address())}',
    '{clean(fake.job())}'
);
""")

        # =====================================================
        # EMPLOYEES
        # =====================================================

        for i in range(1, 701):

            first = fake.first_name()
            last = fake.last_name()

            dept_id = random.randint(1, 35)
            dept_name = DEPT_LIST[dept_id - 1]

            role_id_choice = random.choice(
                department_roles_map[dept_id]
            )

            job_title = role_id_to_name[role_id_choice]

            email = (
                f"{first.lower()}."
                f"{last.lower()}@"
                f"{dept_name.lower().replace(' ', '')}.com"
            )

            hire_date = sql_date(
                fake.date_between(start_date='-10y', end_date='today')
            )

            f.write(f"""
INSERT INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    phone_number,
    job_title,
    employment_status,
    hire_date,
    hourly_rate,
    department_id,
    roles_id
)
VALUES (
    {i},
    '{clean(first)}',
    '{clean(last)}',
    '{email}',
    '{get_phone()}',
    '{clean(job_title)}',
    '{random.choice(['Active', 'Remote', 'On Leave'])}',
    '{hire_date}',
    {random.randint(15,120)},
    {dept_id},
    {role_id_choice}
);
""")

        f.write("\nCOMMIT;\n")

    print(f"SUCCESS: {SQL_FILE} generated successfully.")

if __name__ == "__main__":
    generate_dml()