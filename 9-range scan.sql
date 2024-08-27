DROP table if exists users;

CREATE table users (
	id int auto_increment primary key,
	age int
);

-- 깊은 재귀를 허용하도록 설정
SET SESSION cte_max_recursion_depth = 1000000;

-- 더미데이터 100만개 생성
-- 100만개의 row 를 가지는 cte 라는 임시 테이블을 생성하고 해당 컬럼 값들은 랜덤 값으로 구성
-- cte 의 모든 데이터를 users 에 집어 넣는다.
INSERT INTO users(age)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	FLOOR(1 + RAND() * 1000) AS age -- 1부터 1000 사이의 랜덤 값으로 나이 생성
FROM cte;

-- age 컬럼에 대한 index 생성 
CREATE index idx_age on users(age);


-- range scan, type = range
-- 인덱스를 범위 형태로 조회한다.
-- 보통 between, 부등호, in, like 을 활용하면 해당 스캔이 사용된다.
explain select * from users
	where age between 10 and 20; -- age 로 정렬된 인덱스(b tree) 를 활용하여 10을 찾고 20까지 순차 스캔
explain select * from users
	where age in (10, 20, 30); -- 나이가 10, 20, 30 인 애들이 각 1명이 아니고 여러명이라 범위이다. 
explain select * from users
	where age < 20;