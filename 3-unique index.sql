-- users table 생성 
DROP TABLE IF EXISTS users;

-- name 컬럼에 유니크 제약조건 설정 
CREATE TABLE users(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) UNIQUE,
	age INT
);

-- 유니크 제약조건을 건 컬럼은 자동으로 인덱스가 생성된다. 유니크 제약조건의 동작 원리가 인덱스이기 때문이다.
show index from users;

