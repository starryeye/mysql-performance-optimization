DROP table if exists users;

CREATE table users (
	id int primary key,
	name varchar(100)
);

-- 셈플 데이터 생성 
INSERT INTO users (id, name) values
(1, 'a'),
(3, 'b'),
(5, 'c'),
(7, 'd');

SELECT * FROM users;

-- pk 변경 
UPDATE users
	SET id = 2
	WHERE id = 7;

-- 변경된 pk 로 인해 row 순서가 바뀌었다. -> row 는 pk 기준으로 정렬되어있다. pk 는 인덱스이다. (클러스터링 인덱스)
SELECT * FROM users;

show index from users;