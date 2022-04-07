-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
		dept_no varchar(4) not null,
		dept_name varchar(40) not null,
		primary key (dept_no),
		unique (dept_name)
);

CREATE TABLE employees (
emp_no int not null,
birth_date date not null,
first_name varchar not null,
last_name varchar not null,
gender varchar not null,
hire_date date not null, 
primary key (emp_no)
);

CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

CREATE TABLE dept_emp (
    emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
    emp_no INT NOT NULL,
	title varchar not null,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
    PRIMARY KEY (emp_no,from_date)
)

SELECT * FROM titles; 

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');


-- creating retirement list 
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM retirement_info;

drop table retirement_info;

-- Create new table for retiring employees
select emp_no, first_name, last_name
into retirement_info
from employees
where (birth_date between '1952-01-01' and '1955-12-31')
and (hire_date between '1985-01-01' and '1988-12-31');
-- Check the table
select * from retirement_info;

-- Joining departments and dept_manager tables
select departments.dept_name,
		dept_manager.emp_no,
		dept_manager.from_Date,
		dept_manager.to_date
From departments
inner join dept_manager
on departments.dept_no = dept_manager.dept_no;

-- Joining retirement_info and dept_emp tables
select ri.emp_no,
		ri.first_name,
		ri.last_name,
		de.to_date
into current_emp
from retirement_info as ri
left join dept_emp as de
on ri.emp_no = de.emp_no
where de.to_date = ('9999-01-01');

select * from current_emp

-- Employee count by department number
select count(ce.emp_no),
			de.dept_no
into count_dept
from current_emp as ce
left join dept_emp as de 
on ce.emp_no = de.emp_no
group by de.dept_no
order by de.dept_no;

-- Create Employee Information table
select e.emp_no,
		e.first_name,
		e.last_name,
		e.gender,
		s.salary,
		de.to_date 
into emp_info
from employees as e
inner join salaries as s 
on (e.emp_no = s.emp_no)
inner join dept_emp as de 
on (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	 and (de.to_date = '9999-01-01');
	 
-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);


-- List of Department Retirees
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);


-- Create retirement list for sales dep
select ri.emp_no,
		ri.first_name,
		ri.last_name,
		di.dept_name
into sales_dept
from retirement_info as ri
inner join dept_info as di
on (ri.emp_no = di.emp_no)
where (di.dept_name = 'Sales');

-- Create retirement list for sales and development dep
select ri.emp_no,
		ri.first_name,
		ri.last_name,
		di.dept_name
into sales_development
from retirement_info as ri
inner join dept_info as di
on (ri.emp_no = di.emp_no)
where di.dept_name in ('Development','Sales');

--The Number of Retiring Employees by Title.
select e.emp_no,
	   e.first_name,
	   e.last_name,
	   ti.title,
	   ti.from_date,
	   ti.to_date
into retirement_titles
from employees as e 
inner join titles as ti
on (e.emp_no = ti.emp_no)
where (e.birth_date between '1952-01-01' and '1955-12-31')
order by e.emp_no;

-- The Number of Retiring Employees by Title (No Duplicates).
select distinct on (rt.emp_no)
					rt.emp_no,
					rt.first_name,
					rt.last_name,
					rt.title
into unique_titles
from retirement_titles as rt
order by rt.emp_no, rt.to_date desc;

-- The number of employees by their most recent job title who are about to retire.
select count(ut.title), ut.title
into retiring_title
from unique_titles as ut
group by ut.title
order by count desc;

--The Employees Eligible for the Mentorship Program.
SELECT DISTINCT ON (e.emp_no)
	e.emp_no,
	e.first_name, 
	e.last_name, 
	e.birth_date,
	de.from_date,
	de.to_date,
	ti.title
INTO mentorship_eligibilty
FROM employees as e
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
INNER JOIN titles as ti
ON (e.emp_no = ti.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
AND (de.to_date = '9999-01-01')
ORDER BY e.emp_no, ti.from_date DESC;

--Roles per Staff and Departament: 
SELECT DISTINCT ON (rt.emp_no) 
	rt.emp_no,
	rt.first_name,
	rt.last_name,
	rt.title,
	d.dept_name,
	rt.to_Date
INTO unique_titles_department
FROM retirement_titles as rt
INNER JOIN dept_emp as de
ON (rt.emp_no = de.emp_no)
INNER JOIN departments as d
ON (d.dept_no = de.dept_no)
ORDER BY rt.emp_no, rt.to_date DESC;

-- How many roles will need to be fill per title and department?
SELECT ut.dept_name, ut.title, COUNT(ut.title) 
INTO roles_to_fill
FROM (SELECT title, dept_name from unique_titles_department) as ut
GROUP BY ut.dept_name, ut.title
ORDER BY ut.dept_name DESC;

-- Qualified staff, retirement-ready to mentor next generation.
SELECT ut.dept_name, ut.title, COUNT(ut.title) 
INTO qualified_staff
FROM (SELECT title, dept_name from unique_titles_department) as ut
WHERE ut.title IN ('Senior Engineer', 'Senior Staff', 'Technique Leader', 'Manager')
GROUP BY ut.dept_name, ut.title
ORDER BY ut.dept_name DESC;


	 