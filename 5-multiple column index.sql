DROP table if exists users;

CREATE table users (
	id int auto_increment primary key,
	name varchar(100),
	department varchar(100),
	age int
);

INSERT INTO users (name, department, age) values
('박미나', '회계', 26),
('김미현', '회계', 23),
('김민재', '회계', 21),
('이재현', '운영', 24),
('조민규', '운영', 23),
('하재원', '인사', 22),
('최지우', '인사', 22);

-- 멀티 컬럼 인덱스 생성, department 1순위 name 2순위로 정렬되는 인덱스이다. 
CREATE index idx_department_name on users(department, name);

show index from users;