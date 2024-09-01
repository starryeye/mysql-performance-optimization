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

-- Question,
-- users 테이블에서 가장 높은 급여을 구하고 그 값을 가지는 데이터가 department 조건에 맞는 데이터를 조회한다.
-- 실행 계획을 분석하면 salary 때문에 all type scan 을 두번한다. (서브 쿼리 + 외부 쿼리)
-- 따라서, salary 에 인덱스를 걸어주면 성능개선이 될것이다.
-- (+ department, salary 에 인덱스를 걸 수있는 선택지가 있다고 쿼리만 보면 알 수 있는데 salary 가 중복 데이터가 적으므로 salary 에 인덱스를 걸자고 빠른 결정을 내릴수 있기도함.)
explain analyze SELECT *
FROM users u
WHERE salary = (
    SELECT MAX(salary)
    FROM users
)
AND department IN ('Sales', 'Marketing', 'Information Technology');

-- 인덱스 생성 
CREATE index idx_salary on users(salary);

explain analyze SELECT *
FROM users u
WHERE salary = (
    SELECT MAX(salary)
    FROM users
)
AND department IN ('Sales', 'Marketing', 'Information Technology');


