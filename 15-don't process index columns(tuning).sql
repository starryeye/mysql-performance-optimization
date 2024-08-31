DROP table if exists users;

CREATE table users(
	id int auto_increment primary key,
	name varchar(100),
	salary int,
	created_at timestamp default current_timestamp
);


-- 깊은 재귀를 허용하도록 설정
SET SESSION cte_max_recursion_depth = 1000000;

-- 더미데이터 100만개 생성
-- 100만개의 row 를 가지는 cte 라는 임시 테이블을 생성하고 해당 컬럼 값들은 랜덤 값으로 구성
-- cte 의 모든 데이터를 users 에 집어 넣는다.
INSERT INTO users(name, salary, created_at)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	CONCAT('User', LPAD(n,7,'0')), -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
	FLOOR(1 + RAND() * 1000000) AS salary, -- 1부터 1000000 사이의 랜덤 값으로 급여 생성
	TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 날짜 생성 
FROM cte;


-- 인덱스 생성 
CREATE index idx_name on users(name);
CREATE index idx_salary on users(salary);

-- Question, 인덱스가 있음에도 all type scan..
explain SELECT * from users
	WHERE SUBSTRING(name, 1, 10) = 'User000000'; -- User000000 로 시작하는 name 을 가진 데이터 조회 
	
-- Question, 인덱스가 있음에도 all type scan..
explain SELECT * from users
	WHERE salary * 2 < 1000 -- 두달치 급여가 1000 이하인 데이터 조회 
	ORDER BY salary;
	
-- 이유..
-- 조건문에서 인덱스로 사용된 컬럼을 가공(함수를 사용하거나 연산을 하거나)했기 때문이다.
-- 따라서 아래와 같이 변경해주면 정상적으로 인덱스를 활용한다.
explain SELECT * from users
	WHERE name LIKE 'User000000%'; -- User000000 로 시작하는 name 을 가진 데이터 조회 

explain SELECT * from users
	WHERE salary < 1000 /2 -- 두달치 급여가 1000 이하인 데이터 조회 
	ORDER BY salary;
