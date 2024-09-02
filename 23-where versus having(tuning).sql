DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    age INT
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE scores (
    score_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    year INT,
    semester INT,
    score INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- 높은 재귀(반복) 횟수를 허용하도록 설정
-- (아래에서 생성할 더미 데이터의 개수와 맞춰서 작성하면 된다.)
SET SESSION cte_max_recursion_depth = 1000000; 

-- students 테이블에 더미 데이터 삽입
INSERT INTO students (name, age)
WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
    CONCAT('Student', LPAD(n, 7, '0')) AS name,  -- 'User' 다음에 7자리 숫자로 구성된 이름 생성
    FLOOR(1 + RAND() * 100) AS age -- 1부터 100 사이의 랜덤한 점수 생성
FROM cte;

-- subjects 테이블에 과목 데이터 삽입
INSERT INTO subjects (name)
VALUES
    ('Mathematics'),
    ('English'),
    ('History'),
    ('Biology'),
    ('Chemistry'),
    ('Physics'),
    ('Computer Science'),
    ('Art'),
    ('Music'),
    ('Physical Education'),
    ('Geography'),
    ('Economics'),
    ('Psychology'),
    ('Philosophy'),
    ('Languages'),
    ('Engineering');

-- scores 테이블에 더미 데이터 삽입
INSERT INTO scores (student_id, subject_id, year, semester, score)
WITH RECURSIVE cte (n) AS
(
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 1000000 -- 생성하고 싶은 더미 데이터의 개수
)
SELECT 
    FLOOR(1 + RAND() * 1000000) AS student_id,  -- 1부터 1000000 사이의 난수로 학생 ID 생성
    FLOOR(1 + RAND() * 16) AS subject_id,             -- 1부터 16 사이의 난수로 과목 ID 생성
    YEAR(NOW()) - FLOOR(RAND() * 5) AS year,   -- 최근 5년 내의 임의의 연도 생성
    FLOOR(1 + RAND() * 2) AS semester,                -- 1 또는 2 중에서 랜덤하게 학기 생성
    FLOOR(1 + RAND() * 100) AS score -- 1부터 100 사이의 랜덤한 점수 생성
FROM cte;



-- Question
-- 2024년 1학기 평균성적이 100점인 데이터 조회 
explain analyze
SELECT 
    st.student_id,
    st.name,
    AVG(sc.score) AS average_score
FROM 
    students st
JOIN 
    scores sc ON st.student_id = sc.student_id
GROUP BY 
    st.student_id,
    st.name,
    sc.year,
    sc.semester
HAVING 
    AVG(sc.score) = 100
    AND sc.year = 2024
    AND sc.semester = 1;
   
-- 해결, having 은 group by 이후에 수행되고 where 문으로 하면 group by 이전에 수행된다.
-- 적은 양의 데이터로 연산을 수행하는게 시간상 이득이므로 where 문으로 옮길 수 있는건 옮기자.
explain analyze
SELECT 
    st.student_id,
    st.name,
    AVG(sc.score) AS average_score
FROM 
    students st
JOIN 
    scores sc ON st.student_id = sc.student_id
WHERE 
    sc.year = 2024
    AND sc.semester = 1
GROUP BY 
    st.student_id,
    st.name
HAVING 
    AVG(sc.score) = 100;