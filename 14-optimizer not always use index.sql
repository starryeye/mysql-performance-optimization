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


-- name 컬럼에 대한 인덱스 생성
CREATE index idx_name on users(name);

-- Question, 인덱스를 생성해줬음에도 왜 all scan 일까?
explain SELECT * from users
	order by name desc;
	
-- 위 sql 은 모든 데이터를 조회한다.(반드시 모든 데이터이지 않아도 all scan 임)
-- 옵티마이저가 인덱스를 사용해서 정렬된 데이터를 바탕으로 원본 테이블에 하나씩 접근해서 데이터를 조회하기 보다는.. 
-- 처음부터 원본 테이블에 접근해서 조회하고 조회된 데이터를 한번에 정렬해서 반환하는게 빠르다고 판단하여 인덱스를 사용하지 않은 것이다. (실제로도 인덱스를 사용하지 않는게 빠름..) 