DROP table if exists users;

CREATE table users (
	id int auto_increment primary key,
	name varchar(100),
	department varchar(100),
	created_at timestamp default current_timestamp
);

-- 깊은 재귀를 허용하도록 설정
SET SESSION cte_max_recursion_depth = 1000000;



-- 더미데이터 100만개 생성
-- 100만개의 row 를 가지는 cte 라는 임시 테이블을 생성하고 해당 컬럼 값들은 랜덤 값으로 구성
-- cte 의 모든 데이터를 users 에 집어 넣는다.
INSERT INTO users (name, department, created_at)
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
	TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 날짜 생성 
FROM cte;


-- 정상 생성 되었는지 확인 
SELECT count(*) from users;
SELECT * FROM users limit 10;


-- Question, 실행시간 단축해보자.
SELECT * FROM users
	WHERE department = 'Sales'
		AND created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY);
		

-- 실행 계획
-- type = all, 접근 row 100 만 (= 1e+6)
explain analyze SELECT * FROM users
	WHERE department = 'Sales'
		AND created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY);
		

-- department, created_at 두개의 컬럼을 가지고 모든 경우의 수로 인덱스를 생성해보면 ...
-- 1. department 만 할 경우, sales 인 모든 데이터를 모두 조회 하고 created_at 을 필터링하기 때문에 시간이 좀 걸림
-- 2. created_at 만 할 경우, created_at 조건을 만족하는 데이터를 조회 (department 만 한 경우 보다 적은 데이터를 조회해서 필터링한다.) 1번보다 시간 단축됨
-- 3. department, created_at 두개의 인덱스를 생성, 옵티마이저가 created_at 인덱스만 사용하여 실행계획을 세웠기 때문에 department 인덱스가 필요 없게됨.
-- 4. 멀티 컬럼 인덱스(순서 두가지 경우 모두) 2번과 실행 시간이 비슷함, 인덱스는 적을 수록 좋기 때문에 (CUD 시간 단축) 2번으로 최종 결정 

-- 인덱스 생성
CREATE index idx_created_at on users(created_at);