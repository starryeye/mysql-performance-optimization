DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS posts;


CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);


-- 높은 재귀(반복) 횟수를 허용하도록 설정
-- (아래에서 생성할 더미 데이터의 개수와 맞춰서 작성하면 된다.)
SET SESSION cte_max_recursion_depth = 1000000; 

-- posts 테이블에 더미 데이터 삽입
INSERT INTO posts (title, created_at)
WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
    CONCAT('Post', LPAD(n, 7, '0')) AS name,  -- 'Post' 다음에 7자리 숫자로 구성된 이름 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

-- users 테이블에 더미 데이터 삽입
INSERT INTO users (name, created_at)
WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
    CONCAT('User', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;

-- likes 테이블에 더미 데이터 삽입
INSERT INTO likes (post_id, user_id, created_at)
WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
    FLOOR(1 + RAND() * 1000000) AS post_id,    -- 1부터 1000000 사이의 난수
    FLOOR(1 + RAND() * 1000000) AS user_id,    -- 1부터 1000000 사이의 난수
    TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3650) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND) AS created_at -- 최근 10년 내의 임의의 날짜와 시간 생성
FROM cte;


-- Question,
-- 분석해보니, inner join 을 한 임시테이블에서 group by 로 집계하는 과정에서 가장 많은 시간이 걸렸다.
-- 집계를 빠르게 하고 싶은데.. 임시테이블이라. 인덱스 생성이 어렵다. 
-- 그렇다면, 집계자체를 인덱스가 잘 적용되도록 하면 좋고.. inner join 결과(임시테이블) 데이터 수를 줄이는 방향으로 해결해보도록하면 좋을 것 같다. 
explain analyze
SELECT
    p.id,
    p.title,
    p.created_at,
    COUNT(l.id) AS like_count
FROM
    posts p
INNER JOIN
    likes l ON p.id = l.post_id
GROUP BY
    p.id, p.title, p.created_at
ORDER BY
    like_count DESC
LIMIT 30;

-- 해결,
-- 아래와 같이 inner join 을 위한 서브 쿼리에서 30개 만 결과로 나오도록 하였고 집계 자체도 서브쿼리 내에서 하도록 하였다. 
-- 서브 쿼리를 수행할 땐, post_id 가 likes 테이블의 외래키 이므로 자동으로 인덱스로 생성이 되어있어서 group by 자체도 빠르다. 
explain analyze
SELECT 
	p.id,
	p.title,
	p.created_at,
	l.like_count
from
	posts p
inner join
	(
		select post_id, count(*) as like_count
		from likes
		group by post_id
		order by like_count desc
		limit 30
	) as l on p.id = l.post_id;