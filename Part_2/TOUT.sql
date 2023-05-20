-- Expliquer à quoi sert un index en base de données
/*
Un index en base de données est une structure de données utilisée pour améliorer les performances de requêtes SQL.
Il permet d'accélérer les recherches dans une table en créant une copie partielle de cette dernière, contenant uniquement les colonnes nécessaires pour les requêtes.
Lorsqu'une requête est exécutée, l'index est utilisé pour trouver rapidement les enregistrements correspondants sans avoir besoin de parcourir l'ensemble de la table, ce qui permet de gagner du temps et d'optimiser les performances.
L'utilisation d'index est donc un moyen efficace d'optimiser les requêtes SQL et de garantir des temps de réponse rapides pour les utilisateurs.
*/

-- compter le nombre d'étudiants qui sont dans la maison "Gryffindor"
SELECT COUNT(*) AS nb_etudiants
FROM project
where house = 'Gryffondor';


-- mesurer le temps de la requête avec la commande SHOW PROFILE
SET profiling = 1;
SHOW PROFILE;



-- ajouter un index sur la colonne "house_id" de la table "students"
ALTER TABLE project ADD INDEX idx_house (house(255));


/*
 L'ajout de l'index sur la colonne "house_id" de la table "student_name" accélére un peu la requête pour compter le nombre d'étudiants dans une maison spécifique.
*/

/*
La requet est un peu plus longue sans l'index.
*/


/*
-- Requête a
-- Cette requête est sensé permet de compter le nombre d'étudiants pour chaque maison et chaque cours, et d'afficher les résultats en ordre décroissant en fonction du nombre d'étudiants.


SELECT houses.house_name, courses.course_name, COUNT(*) AS
num_students
FROM students
JOIN houses ON students.house_id = houses.house_id
JOIN courses ON students.course_id = courses.course_id
GROUP BY houses.house_name, courses.course_name
ORDER BY num_students DESC;


*/
-- L'architecture de la base de donnée ne correpond pas du tout à la requet demander. Voici la traduction dans notre base de donnée

ALTER TABLE student ADD INDEX idx_student_ID_house (ID_house);



SET profiling = 1;
SELECT house.name_house, registered_course.name_course, COUNT(*) AS num_students
FROM student
JOIN house ON student.ID_house = house.ID_house
JOIN study ON student.ID_student = study.ID_student
JOIN registered_course ON study.ID_course = registered_course.ID_course
GROUP BY house.name_house, registered_course.name_course
ORDER BY num_students DESC;
SHOW PROFILE;



-- Requête b

-- SELECT student_name, email
-- FROM students
-- WHERE course_id IS NULL;
-- Traduction dans notre base de donnée -----------------------------------------------------

ALTER TABLE study ADD INDEX idx_study_ID_student (ID_student);


SET profiling = 1;
SELECT student_name, email
FROM student
WHERE ID_student NOT IN (SELECT ID_student FROM study);
SHOW PROFILE ;

-- Cette requête utilise une sous-requête pour sélectionner les ID des étudiants qui sont inscrits à au moins un cours, 
-- et ensuite sélectionne les noms et emails des étudiants dont l'ID n'est pas dans cette liste.




-- Requête c
/*
SELECT houses.house_name, COUNT(*) AS num_students
FROM students
JOIN houses ON students.house_id = houses.house_id
WHERE EXISTS (
SELECT *
FROM courses
WHERE course_name IN ('Potions', 'Sortilèges', 'Botanique')
AND course_id = students.course_id
)
GROUP BY houses.house_name;
*/
-- Traduction dans notre base de donnée -----------------------------------------------------

ALTER TABLE study ADD INDEX idx_study_ID_course (ID_course);

SET profiling = 1;
SELECT house.name_house, COUNT(*) AS num_students
FROM student
JOIN house ON student.ID_house = house.ID_house
WHERE EXISTS (
SELECT *
FROM study
JOIN registered_course ON study.ID_course = registered_course.ID_course
WHERE registered_course.name_course IN ('Potions', 'Sortilèges', 'Botanique')
AND study.ID_student = student.ID_student
)
GROUP BY house.name_house;
SHOW PROFILE;
-- Cette requête joint les tables student et house pour récupérer les noms de maisons des étudiants, et utilise une sous-requête pour vérifier si l'étudiant est inscrit à l'un des cours de potions, sortilèges ou botanique.
-- La clause EXISTS retourne true si la sous-requête renvoie des résultats, ce qui signifie que l'étudiant est inscrit à l'un de ces cours.
-- Ensuite, la requête regroupe les résultats par maison et compte le nombre d'étudiants dans chaque maison.



/*
Requête d
SELECT s.student_name, s.email
FROM students s
JOIN (
SELECT student_id, year_id, COUNT(DISTINCT course_id) AS
num_courses
FROM students
GROUP BY student_id, year_id
) AS sub
ON s.student_id = sub.student_id AND s.year_id = sub.year_id
JOIN (
SELECT year_id, COUNT(DISTINCT course_id) AS num_courses
FROM students
GROUP BY year_id
) AS total
ON s.year_id = total.year_id AND sub.num_courses =
total.num_courses
WHERE sub.num_courses = total.num_courses;
*/

-- Traduction dans notre base de donnée -----------------------------------------------------

ALTER TABLE study ADD INDEX idx_study_ID_student_year_course (ID_student, ID_year, ID_course);


SET profiling = 1;
SELECT s.student_name, s.email
FROM student s
JOIN (
SELECT ID_student, ID_year, COUNT(DISTINCT ID_course) AS
num_courses
FROM study
GROUP BY ID_student, ID_year
) AS sub
ON s.ID_student = sub.ID_student AND s.ID_year = sub.ID_year
JOIN (
SELECT ID_year, COUNT(DISTINCT ID_course) AS num_courses
FROM study
GROUP BY ID_year
) AS total
ON s.ID_year = total.ID_year AND sub.num_courses =
total.num_courses
WHERE sub.num_courses = total.num_courses;
SHOW PROFILE;

/*Cette requête sélectionne les noms et les adresses e-mail des étudiants qui ont le même nombre de cours que tous les autres étudiants de leur année. Les résultats sont obtenus en rejoignant trois sous-requêtes. 
La première sous-requête sélectionne l'ID de l'étudiant, l'ID de l'année et le nombre de cours distincts suivis par chaque étudiant. 
La deuxième sous-requête sélectionne l'ID de l'année et le nombre de cours distincts suivis par tous les étudiants de chaque année. 
La troisième sous-requête relie les résultats de la première et de la deuxième sous-requête pour obtenir les noms et les adresses e-mail des étudiants qui ont le même nombre de cours que tous les autres étudiants de leur année.

*/


/*
-- 1
Une vue en base de données est une requête stockée en tant qu'objet dans la base de données, qui peut être utilisée comme une table. 
Une vue logique est une vue qui ne stocke pas les résultats de la requête, tandis qu'une vue matérialisée stocke physiquement les résultats dans la base de données.
*/

/*
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
*/
/*
-- 3

CREATE VIEW house_student_count AS
SELECT house.name_house AS house_name, COUNT(*) AS student_count
FROM student
INNER JOIN house ON student.ID_house = house.ID_house
GROUP BY house.name_house;

UPDATE house_student_count SET student_count = 10 WHERE house_name = 'Gryffondor';
Error Code: 1288. The target table house_student_count of the UPDATE is not updatable

Une vue est une représentation virtuelle des données stockées dans les tables sous-jacentes, et ne peut pas être modifiée directement. 
Si la vue house_student_count avait été une table normale, la requête UPDATE aurait fonctionné normalement.
*/

-- PARTIE 3 -----------------------------
/*
Les procédures stockées sont des programmes SQL précompilés et stockés dans la base de données pour être appelés par les applications ou par d'autres procédures. 
Elles permettent d'exécuter des instructions SQL complexes de manière répétée et efficace.

Les triggers sont des instructions SQL qui s'exécutent automatiquement en réponse à des événements spécifiques, tels que l'insertion, la mise à jour ou la suppression de données dans une table. 
Ils peuvent être utilisés pour appliquer des contraintes de données, effectuer des validations ou mettre à jour des tables de manière automatique.
*/


-- 2 ----------------------------
-- a
/*

CREATE TABLE house_student_count_materialized (
  house_name VARCHAR(255) NOT NULL,
  student_count INT NOT NULL,
  PRIMARY KEY (house_name)
);


-- b
DELIMITER //
CREATE PROCEDURE refresh_house_student_count_materialized()
BEGIN
  -- Vide la table house_student_count_materialized
  TRUNCATE TABLE house_student_count_materialized;

  -- Insère les données recalculées
  INSERT INTO house_student_count_materialized (house_name, student_count)
  SELECT house.name_house AS house_name, COUNT(student.ID_student) AS student_count
  FROM house
  LEFT JOIN student ON house.ID_house = student.ID_house
  GROUP BY house.name_house;
  
END //

DELIMITER ;


-- c 
CALL refresh_house_student_count_materialized();

-- Maintenant, la table house_student_count_materialized contient les mêmes informations que la vue house_student_count.
-- On peut exécuter des requêtes sur cette table comme on le ferait sur une vue matérialisée.
-- Exemple : 
SELECT * FROM house_student_count_materialized;


*/
/*
-- 3 --------

-- a Voici une requête pour ajouter un nouvel étudiant à la table students :

SELECT * FROM house_student_count_materialized; -- 8 à gryffondor
INSERT INTO student (student_name, email, ID_house, ID_year)
VALUES ('Ryan', 'ryan@hogwarts.edu', 1, 1);


-- b Affichez le contenu de la table house_student_count_materialized pour vérifier si le nouvel étudiant a été pris en compte

SELECT * FROM house_student_count_materialized;-- TOUJOURS 8 à gryffondor


-- c Exécutez la procédure stockée
CALL refresh_house_student_count_materialized();

-- d Affichez à nouveau le contenu de la vue matérialisée
SELECT * FROM house_student_count_materialized;-- 9 maintenant à gryffondor


*/
-- 4-----------------

-- a

/*
DELIMITER //
CREATE TRIGGER tr_student_insert
AFTER INSERT ON student
FOR EACH ROW
BEGIN
  CALL refresh_house_student_count_materialized();
END//
DELIMITER ;
-- Il est déclenché après chaque ajoue d'un enregistrement dans la table students grâce à l'instruction AFTER INSERT ON students FOR EACH ROW.


-- b

DELIMITER //
CREATE TRIGGER tr_student_delete
AFTER DELETE ON student
FOR EACH ROW
BEGIN
    CALL refresh_house_student_count_materialized();
END//
DELIMITER ;


 -- Il est déclenché après chaque suppression d'un enregistrement dans la table students grâce à l'instruction AFTER DELETE ON students FOR EACH ROW.

*/
-- 5 -----------------------------------

-- CALL refresh_house_student_count_materialized();
/*
SELECT * FROM house_student_count_materialized;
INSERT INTO student (student_name,email, ID_house,ID_year) VALUES ('Ginny Weasley','ginny.w@hogward.edu', 1, 3);
SELECT * FROM house_student_count_materialized; -- Error Code: 1422. Explicit or implicit commit is not allowed in stored function or trigger.
-- Pour résoudre ce problème, vous pouvez ajouter la ligne COMMIT à la fin de la procédure stockée refresh_house_student_count_materialized(). 
-- Cela permettra de terminer la transaction avant la fin de l'appel de la procédure stockée dans le trigger.

*/
/*
DROP TABLE house_student_count_materialized;
DROP PROCEDURE refresh_house_student_count_materialized;
DROP TRIGGER tr_student_insert;
DROP TRIGGER tr_student_delete;
DROP PROCEDURE add_student;

CREATE TABLE house_student_count_materialized (
  house_name VARCHAR(255) NOT NULL,
  student_count INT NOT NULL,
  PRIMARY KEY (house_name)
);


DELIMITER //
CREATE PROCEDURE refresh_house_student_count_materialized()
BEGIN
  -- Vide la table house_student_count_materialized
  TRUNCATE TABLE house_student_count_materialized;

  -- Insère les données recalculées
  INSERT INTO house_student_count_materialized (house_name, student_count)
  SELECT house.name_house AS house_name, COUNT(student.ID_student) AS student_count
  FROM house
  LEFT JOIN student ON house.ID_house = student.ID_house
  GROUP BY house.name_house;
  
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE add_student (
  IN student_name VARCHAR(255),
  IN email VARCHAR(255),
  IN ID_house INT,
  IN ID_year INT
)
BEGIN
  INSERT INTO student (student_name, email, ID_house, ID_year)
  VALUES (student_name, email, ID_house, ID_year);
  CALL refresh_house_student_count_materialized();
END;//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE supp_student (
  IN ID INT
)
BEGIN
  DELETE FROM student where ID_student = ID;
END;//
DELIMITER ;

CALL supp_student(58);
CALL refresh_house_student_count_materialized();

-- SELECT * FROM house_student_count_materialized;
CALL add_student('Ginny Weasley', 'ginny.w@hogward.edu', 1, 3);
SELECT * FROM house_student_count_materialized;
-- On ne peut pas utiliser de trigger sinon Explicit or implicit commit is not allowed in stored function or trigger.
*/