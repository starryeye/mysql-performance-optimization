DROP table if exists users;

create table users (
	id int auto_increment primary key,
	name varchar(100),
	age int,
	department varchar(100),
	salary int,
	created_at timestamp default current_timestamp
);


-- 깊은 재귀를 허용하도록 설정
SET SESSION cte_max_recursion_depth = 1000000;

-- 더미데이터 100만개 생성
-- 100만개의 row 를 가지는 cte 라는 임시 테이블을 생성하고 해당 컬럼 값들은 랜덤 값으로 구성
-- cte 의 모든 데이터를 users 에 집어 넣는다.
INSERT INTO users (name, age, department, salary, created_at)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	CONCAT('User', LPAD(n, 7, '0')), -- 'User' 다음에 7자리 숫자로 구성된 이름 생성 
	FLOOR(1 + RAND() * 1000) AS age, -- 1부터 1000 사이의 랜덤 값으로 나이 생성
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

-- 인덱스 생성
CREATE index idx_age on users(age);


-- Question
-- index type scan 이지만, 전체 데이터를 조회한다. 
-- age 를 기준으로 20살에서 29살 까지의 데이터만 조회해서 최고 급여를 찾으면 될 것 같은데.. 왜 전체 데이터를 조회할까.. 
explain analyze select age, MAX(salary) from users -- 20 살 부터 29 살 까지의 데이터 중 각 나이별 최고 급여를 조회한다. 
	group by age
	HAVING age >= 20 and age < 30;

-- 이유.. 
-- 일단 group by 문이 존재하므로 age 인덱스를 사용하여 age 로 그룹화 한다. 그룹화를 하면서 원본 테이블의 salary 를 접근해서 집계함수(max)도 함께 계산된다.  (-> 그 결과로 1000개의 데이터가 만들어짐 )
-- 그 이후, 1000개의 데이터로 having 조건에 따른 나이 필터링(20 ~ 29) 를 수행하고 최종 결과가 만들어진다. 
-- 결국.. 
-- 전체 인덱스 스캔: GROUP BY age가 있기 때문에 MySQL은 age 값을 기준으로 모든 데이터를 스캔하여 그룹화를 수행했다.
-- 		이 과정에서 인덱스가 사용되었으나, 여전히 전체 인덱스 범위를 스캔해야 각 나이 그룹을 형성할 수 있다. 
-- 필터링의 순서: HAVING 절은 그룹화된 결과에 대해 나중에 적용되므로, MySQL은 먼저 전체 데이터를 그룹화하고 나서 필터링을 수행한다. 
-- 따라서, 전체 데이터를 인덱스를 사용해 스캔한 후, 필요한 부분만 필터링하게 된다. 


-- 해결
-- 위 sql 의 문제는 group by 를 하고 having 을 적용하기 때문에 발생한 문제이다.
-- 따라서, where 문으로 group by 를 하기 전에 데이터를 먼저 필터링을 하면 해결이된다. (이 과정에서 index 가 사용되며 range type scan 이 적용된다. )
-- 전체 데이터를 조회하지 않고 where 문 조건에 맞는 애들로만 group by 를 수행하게 됨. 
explain analyze select age, MAX(salary) from users
	where age >= 20 and age < 30
	group by age;
