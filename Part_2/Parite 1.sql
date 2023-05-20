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
La requet est un peu plus longue sans l'index.
USE INDEX();
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
