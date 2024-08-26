DROP table if exists users;

CREATE table users (
	id int auto_increment primary key,
	name varchar(100),
	age int
);

-- 더미 데이터 생성 
INSERT into users (name, age) values
('alice', 30),
('bob', 23),
('charlie', 35);


-- 인덱스를 사용하지 않는 풀 테이블 스캔 탐색을 한다. type = all
explain select * from users where age = 23;