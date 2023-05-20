USE projetbdd;
DESCRIBE project_tab;
SHOW tables;
SELECT * from project_tab;
SHOW COLUMNS FROM project_tab;
SELECT Count(distinct student_name)from project_tab;
SELECT distinct registered_course from project_tab;
SELECT distinct house from project_tab;
SELECT distinct prefet from project_tab;
SELECT distinct prefet, house from project_tab;
SELECT count(distinct student_name) as nb_éudiant,year from project_tab group by year;  
SELECT distinct student_name, email from project_tab where (SELECT registered_course='potion'); 
SELECT distinct student_name,year from project_tab where year>2;
SELECT distinct student_name from project_tab order by student_name;
SELECT count(distinct student_name) as nb_étudiant_of_eache_house_that_follow_potion_course, house 
from project_tab where registered_course='potion' group by house;
SELECT count(distinct student_name) as nb_étudiant,house from project_tab group by house; 
SELECT count(distinct registered_course) as nb_course, year from project_tab group by year;
SELECT count(distinct student_name) as nb_étudiant, registered_course from project_tab group by registered_course;
SELECT distinct registered_course,house from project_tab order by house;
SELECT COUNT(distinct student_name) as student_count,house, year FROM project_tab GROUP BY house, year ORDER BY year; 
SELECT distinct registered_course, student_name, year from project_tab group by student_name order by year;
SELECT count(distinct student_name) as nb_étudiant, house from project_tab group by house order by house DESC; 
SELECT count(distinct student_name) as nb_étudiant, registered_course 
from project_tab group by registered_course order by registered_course DESC;
SELECT distinct prefet,house from project_tab group by house order by house;