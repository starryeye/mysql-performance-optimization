DROP table if exists users;

CREATE table users (
	id int auto_increment primary key, -- pk 는 원래 유니크 제약 조건이 있고 인덱스도 생성됨 
	account varchar(100) unique -- 유니크 제약 조건에 따라 account 컬럼에 대해 자동으로 인덱스 생성 
);

show index from users;

insert into users (account) values
('user1@example.com'),
('user2@example.com'),
('user3@example.com');

-- const scan, type = const
-- 인덱스도 존재하고 유니크 제약조건도 걸려있을 경우에 단건 조회를 하면 const scan 이다. 
explain select * from users where id = 3;
explain select * from users where account = 'user3@example.com';