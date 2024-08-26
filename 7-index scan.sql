DROP table if exists users;

CREATE table users (
	id int auto_increment primary key,
	name varchar(100),
	age int
);

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


CREATE index idx_name on users (name);

-- index scan, type = index
-- 인덱스 시작점 부터 필요한 만큼 스캔한다. (조건에 따라 인덱스를 처음부터 끝까지 스캔할 수도 있으므로 유의해야한다. 이런 경우 풀스캔보다야 낫지만 비효율적인 쿼리이다.) 
-- 아래의 경우는 처음부터 10개 까지만 스캔함. 
explain analyze select * from users
	order by name
	limit 10;

