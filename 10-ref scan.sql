DROP table if exists users;

CREATE table users (
	id int auto_increment primary key,
	name varchar(100)
);

INSERT INTO users (name) values
('aaa'),
('bbb'),
('ccc'),
('aaa');

-- name 컬럼에 대한 인덱스 생성 
CREATE index idx_name on users(name);

-- ref scan, type = ref
-- 비고유 인덱스 (유니크 제약이 걸려있지 않은 컬럼에 대한 인덱스) 를 사용하면 사용되는 scan 이다.
explain select * from users
	where name = 'aaa';

explain select * from users
	where name in ('aaa', 'bbb'); -- range scan