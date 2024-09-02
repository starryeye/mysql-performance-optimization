DROP table if exists users;
DROP table if exists orders;

create table users (
	id int auto_increment primary key,
	name varchar(100),
	created_at timestamp default current_timestamp
);

CREATE table orders (
	id int auto_increment primary key,
	ordered_at timestamp default current_timestamp,
	user_id int,
	foreign key (user_id) references users(id)
);



-- 깊은 재귀를 허용하도록 설정
SET SESSION cte_max_recursion_depth = 1000000;

-- 더미데이터 100만개 생성
-- 100만개의 row 를 가지는 cte 라는 임시 테이블을 생성하고 해당 컬럼 값들은 랜덤 값으로 구성
-- cte 의 모든 데이터를 users 에 집어 넣는다.
INSERT INTO users (name, created_at)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	CONCAT('User', LPAD(n, 7, '0')), -- 'User' 다음에 7자리 숫자로 구성된 이름 생성 
	TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 날짜 생성 
FROM cte;

-- order 데이터 생성 
INSERT INTO orders (ordered_at, user_id)
WITH RECURSIVE cte (n) AS
(
	SELECT 1
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 1000000
)
SELECT 
	TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS ordered_at, -- 최근 10년 내의 날짜 생성 
	FLOOR(1 + RAND() * 1000000) AS user_id
FROM cte;


-- Question
explain analyze
select *
from orders
WHERE YEAR(ordered_at) = 2023
ORDER BY ordered_at
LIMIT 30;

-- all type scan 을 해결하기 위해 인덱스 생성
create index idx_ordered_at on orders(ordered_at);

-- 인덱스를 생성했음에도.. 실행시간이 오히려 더 느려지고.. where 문에 범위(부등호) 이므로 range type scan 이어야하나.. index type scan 이며 조회된 데이터가 전체 조회이다.
-- 문제는 where 문 컬럼을 가공했기 때문이다. YEAR(ordered_at) 
explain analyze
select *
from orders
WHERE YEAR(ordered_at) = 2023
ORDER BY ordered_at
LIMIT 30;

-- 따라서 아래와 같이 수정한다.
explain analyze
select *
from orders
WHERE ordered_at >= '2023-01-01 00:00:00'
	and ordered_at < '2024-01-01 00:00:00';