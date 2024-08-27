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


-- Question, 조회 시간 단축해보자. 
SELECT * from users
	WHERE created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY); 


-- 실행계획 조회, type = all 이고 rows 가 전체 row 갯수이다. 
-- table 스캔을 하고 있고, 범위(부등호) 로 조회 중이므로 인덱스를 도입하면 성능이 향상될 것 같다! 
explain SELECT * from users
	WHERE created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY); 

-- created_at 컬럼에 대한 인덱스 생성 
CREATE index idx_created_at on users(created_at);

-- 성능 향상됨!
SELECT * from users
	WHERE created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY); 
	
-- 실행계획 조회, type = range 
explain SELECT * from users
	WHERE created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY); 