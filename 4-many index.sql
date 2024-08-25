-- 인덱스가 없는 테이블 
CREATE table test_table_no_index (
	id int auto_increment primary key,
	column1 int,
	column2 int,
	column3 int,
	column4 int,
	column5 int,
	column6 int,
	column7 int,
	column8 int,
	column9 int,
	column10 int
);

-- 인덱스가 많은 테이블 
CREATE table test_table_many_indexes (
	id int auto_increment primary key,
	column1 int,
	column2 int,
	column3 int,
	column4 int,
	column5 int,
	column6 int,
	column7 int,
	column8 int,
	column9 int,
	column10 int
);

-- 각 컬럼에 인덱스 추가  
CREATE index idx_column1 on test_table_many_indexes (column1);
CREATE index idx_column2 on test_table_many_indexes (column2);
CREATE index idx_column3 on test_table_many_indexes (column3);
CREATE index idx_column4 on test_table_many_indexes (column4);
CREATE index idx_column5 on test_table_many_indexes (column5);
CREATE index idx_column6 on test_table_many_indexes (column6);
CREATE index idx_column7 on test_table_many_indexes (column7);
CREATE index idx_column8 on test_table_many_indexes (column8);
CREATE index idx_column9 on test_table_many_indexes (column9);
CREATE index idx_column10 on test_table_many_indexes (column10);

show index from test_table_many_indexes;


-- 데이터 삽입 성능 테스트
SET SESSION cte_max_recursion_depth = 100000;

-- 인덱스가 없는 테이블에 데이터 10만개 삽입 
-- 일정한 속도로 삽입이 진행된다. 
INSERT INTO test_table_no_index(column1, column2, column3, column4, column5, column6, column7, column8, column9, column10)
WITH RECURSIVE cte AS
(
	SELECT 1 AS n
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 100000
)
SELECT 
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000)
FROM cte;

-- 인덱스가 있는 테이블에 데이터 10만개 삽입 
-- 최초 시도부터 인덱스가 없는 테이블 보다 느리고 삽입하면 할 수록 점점더 오랜시간이 걸린다. 
INSERT INTO test_table_many_indexes(column1, column2, column3, column4, column5, column6, column7, column8, column9, column10)
WITH RECURSIVE cte AS
(
	SELECT 1 AS n
	UNION ALL
	SELECT n + 1 FROM cte WHERE n < 100000
)
SELECT 
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000),
	FLOOR(RAND() * 1000)
FROM cte;
