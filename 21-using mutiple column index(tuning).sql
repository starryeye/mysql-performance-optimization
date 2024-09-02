drop table if exists posts;
DROP table if exists users;

create table users (
	id int auto_increment primary key,
	name varchar(100),
	department varchar(100),
	salary int,
	created_at timestamp default current_timestamp
);


-- 깊은 재귀를 허용하도록 설정
SET SESSION cte_max_recursion_depth = 1000000;

-- 더미데이터 100만개 생성
-- 100만개의 row 를 가지는 cte 라는 임시 테이블을 생성하고 해당 컬럼 값들은 랜덤 값으로 구성
-- cte 의 모든 데이터를 users 에 집어 넣는다.
INSERT INTO users (name, department, salary, created_at)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	CONCAT('User', LPAD(n, 7, '0')), -- 'User' 다음에 7자리 숫자로 구성된 이름 생성 
	CASE
		WHEN n % 10 = 1 THEN 'Engineering'
		WHEN n % 10 = 2 THEN 'Marketing'
		WHEN n % 10 = 3 THEN 'Sales'
		WHEN n % 10 = 4 THEN 'Finance'
		WHEN n % 10 = 5 THEN 'Human Resourcs'
		WHEN n % 10 = 6 THEN 'Operations'
		WHEN n % 10 = 7 THEN 'Information Technology'
		WHEN n % 10 = 8 THEN 'Customer Service'
		WHEN n % 10 = 9 THEN 'Research and Development'
		ELSE 'Product Management'
	END AS department, -- 부서이름 생성 
	FLOOR(1 + RAND() * 1000000) AS salary, -- 1부터 1000000 사이의 랜덤 값으로 급여 생성
	TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 날짜 생성 
FROM cte;



-- Question
-- 부서별로 최대 급여를 가지는 데이터 조회
-- 서브 쿼리 : 부서별로 group by 하여 최대의 급여와 부서이름을 조회한다.
explain analyze
select u.*
from users u
join (
	select department, MAX(salary) as max_salary
	from users
	group by department
) as max_salaries 
on u.department = max_salaries.department 
	and u.salary = max_salaries.max_salary;


-- 인덱스 생성
-- 멀티 컬럼인덱스를 활용한다. department 로 우선 정렬후 salary 로 정렬되도록하면 서브쿼리 수행속도가 매우 좋아진다. 
create index idx_department_salary on users(department, salary);

explain analyze
select u.*
from users u
join (
	select department, MAX(salary) as max_salary
	from users
	group by department
) as max_salaries 
on u.department = max_salaries.department 
	and u.salary = max_salaries.max_salary;
