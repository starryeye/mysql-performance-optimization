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


-- Question, all type scan
-- where 문과 order by 문을 고려하여 어떻게 인덱스를 만들면 좋을까..
explain analyze SELECT * from users
	WHERE created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY)
		AND department = 'Sales'
	ORDER BY salary
	LIMIT 100;
	
-- 해결
-- where 문에 있는 컬럼들을 기준으로 인덱스를 생각하면 created_at 을 인덱스로 만들면 좋다.. (criteria for creating index 참고) 
-- order by 를 생각하면 salary 컬럼을 인덱스로 만들면 좋다..
-- 그럼 where 문과 order by 문을 고려하여 어떻게 인덱스를 만들면 좋을까..
-- 1. order by 에 있는 salary 로 인덱스를 만들어 조회 하면 index type scan 이 적용된다.
-- 		주의, salary 정렬 인덱스를 활용하는데 100 개만 조회해서 그중에 where 문을 적용시키는 것이 아니다. (where 문 조건에 부합하는 애들중에 정렬해서 100 개 이다.)
-- 		따라서, index type scan 이지만, 거의 전체 데이터를 조회한 후 where 문을 따진다.
-- 2. where 문에 있는 created_at 으로 인덱스를 만들어 조회하면 범위이므로 range type scan 이 적용된다.
-- 		조건에 따라 조회된 데이터가 1000 개 정도가 있다. (이건 데이터가 어떻게 존재하냐에 따라 다르다.) 
-- 		1000개 데이터로 department 만족하는 애들을 필터링하고 salary 로 정렬해서 100개를 추린다.

-- 결론, where 문에 있는 컬럼을 활용해 인덱스를 만드는게 보통 성능에 좋다. 그러나, 데이터가 어떻게 존재하냐에 따라 다를 수 있으므로 항상 성능 측정 및 실행 계획을 분석하여 어떤 컬럼에 인덱스를 걸지 결정해야함
create index idx_created_at on users(created_at);

explain analyze SELECT * from users
	WHERE created_at >= DATE_SUB(NOW(), INTERVAL 3 DAY)
		AND department = 'Sales'
	ORDER BY salary
	LIMIT 100;