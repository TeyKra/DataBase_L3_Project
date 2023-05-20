
-- 1
/*
Une vue en base de données est une requête stockée en tant qu'objet dans la base de données, qui peut être utilisée comme une table. 
Une vue logique est une vue qui ne stocke pas les résultats de la requête, tandis qu'une vue matérialisée stocke physiquement les résultats dans la base de données.
*/


-- 2

CREATE VIEW view_potions_students AS
SELECT student_name, email, name_house
FROM student 
INNER JOIN study ON student.ID_student = study.ID_student
INNER JOIN registered_course ON study.ID_course = registered_course.ID_course
INNER JOIN house ON student.ID_house = house.ID_house
WHERE name_course = 'potion';

-- SELECT * FROM view_potions_students;


INSERT INTO student (ID_student, student_name, email, ID_house, ID_year) VALUES
('80','Hugo p', 'hugo.doe@example.com', 2, 1),
('81','Morgan s', 'morgan.smith@example.com', 3, 2);

INSERT INTO study (ID_student, ID_course) VALUES
(80 , 1),
(81 , 1);

-- SELECT * from student;
SELECT * FROM view_potions_students;


-- 3

CREATE VIEW house_student_count AS
SELECT house.name_house AS house_name, COUNT(*) AS student_count
FROM student
INNER JOIN house ON student.ID_house = house.ID_house
GROUP BY house.name_house;

UPDATE house_student_count SET student_count = 10 WHERE house_name = 'Gryffondor';
-- Error Code: 1288. The target table house_student_count of the UPDATE is not updatable
/*
Une vue est une représentation virtuelle des données stockées dans les tables sous-jacentes, et ne peut pas être modifiée directement. 
Si la vue house_student_count avait été une table normale, la requête UPDATE aurait fonctionné normalement.
*/