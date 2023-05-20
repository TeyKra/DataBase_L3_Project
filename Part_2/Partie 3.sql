-- PARTIE 3 -----------------------------
/*
Les procédures stockées sont des programmes SQL précompilés et stockés dans la base de données pour être appelés par les applications ou par d'autres procédures. 
Elles permettent d'exécuter des instructions SQL complexes de manière répétée et efficace.

Les triggers sont des instructions SQL qui s'exécutent automatiquement en réponse à des événements spécifiques, tels que l'insertion, la mise à jour ou la suppression de données dans une table. 
Ils peuvent être utilisés pour appliquer des contraintes de données, effectuer des validations ou mettre à jour des tables de manière automatique.
*/


-- 2 ----------------------------
-- a


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



-- 4-----------------

-- a


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


-- 5 -----------------------------------

-- CALL refresh_house_student_count_materialized();

SELECT * FROM house_student_count_materialized;
INSERT INTO student (student_name,email, ID_house,ID_year) VALUES ('Ginny Weasley','ginny.w@hogward.edu', 1, 3);
SELECT * FROM house_student_count_materialized; -- Error Code: 1422. Explicit or implicit commit is not allowed in stored function or trigger.
-- Pour résoudre ce problème, vous pouvez ajouter la ligne COMMIT à la fin de la procédure stockée refresh_house_student_count_materialized(). 
-- Cela permettra de terminer la transaction avant la fin de l'appel de la procédure stockée dans le trigger.



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
