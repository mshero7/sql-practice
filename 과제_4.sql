-- 문제1.
-- 현재 평균 연봉보다 많은 월급을 받는 직원은 몇 명이나 있습니까?

-- 해결
select count(*) from employees a , salaries b 
	where a.emp_no = b.emp_no
    and b.to_date = '9999-01-01'
    and salary > (select avg(salary) from salaries where to_date='9999-01-01');

-- 문제2. 
-- 현재, 각 부서별로 최고의 급여를 받는 사원의 사번, 이름, 부서 연봉을 조회하세요. 단 조회결과는 연봉의 내림차순으로 정렬되어 나타나야 합니다. 

-- 해결
select a.emp_no, a.first_name, c.dept_name, d.salary from employees a, dept_emp b, departments c, salaries d
	where a.emp_no = b.emp_no
    and a.emp_no = d.emp_no
    and b.dept_no = c.dept_no
    and d.to_date = '9999-01-01'
    group by c.dept_name
    having max(d.salary)
    order by d.salary desc;

-- 문제3.
-- 현재, 자신의 부서 평균 급여보다 연봉(salary)이 많은 사원의 사번, 이름과 연봉을 조회하세요 

-- 자신의 부서 평균 급여
select a.dept_no, avg(b.salary)
		from dept_emp a, salaries b
			where a.emp_no = b.emp_no
            and a.to_date = '9999-01-01'
            and b.to_date = '9999-01-01'
            group by a.dept_no 
            having avg(b.salary);

-- 가상테이블을 만들어서 각각 매칭시킴.

-- 해결
select a.emp_no , a.first_name, b.salary, d.avg_salary, c.dept_no from employees a, salaries b, dept_emp c, (
	select a.dept_no as dept_no, avg(b.salary) as avg_salary
		from dept_emp a, salaries b
			where a.emp_no = b.emp_no
            and a.to_date = '9999-01-01'
            and b.to_date = '9999-01-01'
            group by a.dept_no 
            having avg(b.salary)) d
	where a.emp_no = b.emp_no
    and c.dept_no = d.dept_no
    and b.to_date = '9999-01-01'
    and c.to_date = '9999-01-01'
    and b.salary > d.avg_salary;
	

-- 문제4.
-- 현재, 사원들의 사번, 이름, 매니저 이름, 부서 이름으로 출력해 보세요.
-- 매니저 이름
select a.first_name as 'manager_name', b.dept_no as 'manager_dept_no' from employees a, dept_manager b
	where a.emp_no = b.emp_no
    and b.to_date = '9999-01-01';

-- 직원들의 매니저 여부 확인.
select * from employees a, dept_emp b, departments c
	where a.emp_no = b.emp_no
    and b.dept_no = c.dept_no
    and b.to_date='9999-01-01';

-- 해결
select a.emp_no, a.first_name, d.manager_name, c.dept_name from employees a, dept_emp b, departments c, 
						(select a.first_name as 'manager_name', b.dept_no as 'manager_dept_no' from employees a, dept_manager b
							where a.emp_no = b.emp_no
						and b.to_date = '9999-01-01') d
	where b.dept_no = c.dept_no
    and a.emp_no = b.emp_no
    and d.manager_dept_no = c.dept_no
    and b.to_date = '9999-01-01';

    
-- 문제5.
-- 현재, 평균연봉이 가장 높은 부서의 사원들의 사번, 이름, 직책, 연봉을 조회하고 연봉 순으로 출력하세요.
-- 부서별 평균 연봉
select a.emp_no, a.first_name, b.title, c.salary from employees a, titles b, salaries c, dept_emp d
	where a.emp_no = b.emp_no
    and a.emp_no = c.emp_no
    and a.emp_no = d.emp_no
    and b.to_date = '9999-01-01'
    and c.to_date = '9999-01-01'
    and d.to_date = '9999-01-01'
    and d.dept_no = (select c.dept_no from employees a, salaries b, dept_emp c
						where a.emp_no = b.emp_no
							and a.emp_no = c.emp_no
							and b.to_date = '9999-01-01'
							and c.to_date = '9999-01-01'
						group by c.dept_no
							having avg(b.salary)
						limit 0,1);

select c.dept_no from employees a, salaries b, dept_emp c
	where a.emp_no = b.emp_no
    and a.emp_no = c.emp_no
    and b.to_date = '9999-01-01'
    and c.to_date = '9999-01-01'
    group by c.dept_no
    having avg(b.salary)
    limit 0,1;
    


-- 문제6.
-- 평균 연봉이 가장 높은 부서는? 
-- TOP-K 활용
select avg(a.salary) from salaries a, dept_emp b
	where a.emp_no = b.emp_no
    group by b.dept_no
    having avg(a.salary)
    order by avg(a.salary) desc limit 0,1;

-- 서브쿼리 활용
select max(a.avg_salary) from (
			select avg(a.salary) as avg_salary from salaries a, dept_emp b
			where a.emp_no = b.emp_no
			group by b.dept_no) a;

-- 문제7.
-- 평균 연봉이 가장 높은 직책?

select avg(a.salary) from salaries a, titles b
	where a.emp_no = b.emp_no
    group by b.title
    having avg(a.salary)
    order by avg(a.salary) desc limit 0,1;

select max(a.avg_salary) from (
			select avg(a.salary) as avg_salary from salaries a, titles b
			where a.emp_no = b.emp_no
			group by b.title) a;

-- 문제8.
-- 현재 자신의 매니저보다 높은 연봉을 받고 있는 직원은?
-- 부서이름, 사원이름, 연봉, 매니저 이름, 메니저 연봉 순으로 출력합니다.

-- 부서별 매니저가 받는 급여들에 대한 쿼리
select a.dept_no, b.salary, c.first_name from dept_manager a, salaries b, employees c
	where a.emp_no = b.emp_no
    and a.to_date = '9999-01-01'
    and b.to_date = '9999-01-01'
    and c.emp_no = a.emp_no;

select d.dept_name, a.first_name, b.salary, e.manager_name, e.manager_salary
	from employees a, salaries b, dept_emp c, departments d, 
					(select a.dept_no as 'dept_no', b.salary as 'manager_salary', c.first_name as 'manager_name' 
								from dept_manager a, salaries b, employees c
									where a.emp_no = b.emp_no
									and a.to_date = '9999-01-01'
									and b.to_date = '9999-01-01'
									and c.emp_no = a.emp_no) e
	where a.emp_no = b.emp_no
    and b.emp_no = c.emp_no
    and c.dept_no = d.dept_no
    and c.dept_no = e.dept_no
    and b.to_date = '9999-01-01'
    and c.to_date = '9999-01-01'
    and b.salary > e.manager_salary;