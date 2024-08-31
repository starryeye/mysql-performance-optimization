DROP table if exists users;
DROP table if exists posts;

create table users(
	id int auto_increment primary key,
	name varchar(50) not null,
	created_at timestamp default current_timestamp
);

create table posts(
	id int auto_increment primary key,
	title varchar(255) not null,
	created_at timestamp default current_timestamp,
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

INSERT INTO posts(title, created_at, user_id)
with recursive cte (n) as
(
	select 1
	union all
	select n + 1 from cte WHERE n < 1000000
)
SELECT 
	CONCAT('Post', LPAD(n, 7, '0')) as name,
	timestamp(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at,
	FLOOR(1 + RAND() * 50000) as user_id 
from cte;

-- 데이터 정상 생성 체크
SELECT count(*) from users;
SELECT count(*) from posts;

-- Question, users 테이블을 기준으로 all type scan 을 하고 있다.
explain analyze SELECT p.id, p.title, p.created_at
from posts p
join users u on p.user_id = u.id 
where u.name = 'User0000046'
	and p.created_at BETWEEN '2022-01-01' and '2024-08-31';
	
-- 외래키도 자동으로 인덱스가 만들어짐을 알수있음. 
show index from posts;

-- 해결, 전체 데이터를 조회하게 한 users.name 을 기준으로 인덱스 생성
CREATE index idx_users_name on users(name);
-- users 테이블을 기준으로 ref type scan 으로 변경되며 성능 개선
explain analyze SELECT p.id, p.title, p.created_at
from posts p
join users u on p.user_id = u.id 
where u.name = 'User0000046'
	and p.created_at BETWEEN '2022-01-01' and '2024-08-31';

