-- users table 생성
DROP TABLE IF EXISTS users;

CREATE TABLE users(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100),
	age INT
);

SELECT * FROM users;

-- 깊은 재귀를 허용하도록 설정
SET SESSION cte_max_recursion_depth = 1000000;

-- 더미데이터 100만개 생성
-- 100만개의 row 를 가지는 cte 라는 임시 테이블을 생성하고 해당 컬럼 값들은 랜덤 값으로 구성
-- cte 의 모든 데이터를 users 에 집어 넣는다.
INSERT INTO users(name, age)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	CONCAT('User', LPAD(n,7,'0')), -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
	FLOOR(1 + RAND() * 1000) AS age -- 1부터 1000 사이의 랜덤 값으로 나이 생성
FROM cte;

SELECT * FROM users;

-- 소요시간 확인
SELECT * FROM users
	WHERE age = 23;

-- 인덱스 생성
CREATE INDEX idx_age ON users(age);

-- 생성된 인덱스 확인
SHOW INDEX FROM users;

-- 소요시간 확인
SELECT * FROM users
	WHERE age = 23;

