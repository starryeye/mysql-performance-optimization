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
INSERT INTO users (name, age)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	CONCAT('User', LPAD(n, 7, '0')), -- 'User' 다음에 7자리 숫자로 구성된 이름 생성 
	FLOOR(1 + RAND() * 1000) AS age -- 1부터 1000 사이의 랜덤 값으로 나이 생성
FROM cte;

-- 너무 많은 데이터를 한번에 조회하고 있다. 
SELECT * from users limit 10000;

-- 한번에 모든 데이터를 조회하지말고 적은양의 데이터를 조회하도록하고 필요하면 추가로 조회하는 식으로 바꾸자 (api 레벨에서의 조회를 뜻함, 하나의 요청에서 여러번의 조회는 그것 또한 성능의 악영향임) 
-- 조회하는 데이터의 개수가 성능에 지대한 영향을 끼친다. 
SELECT * from users limit 10;