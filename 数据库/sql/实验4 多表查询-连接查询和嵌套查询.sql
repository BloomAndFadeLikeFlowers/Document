/*实验4 多表查询-连接查询和嵌套查询*/


/*1．求学号为‘20022037’ 的同学的每门课的成绩，输出格式为：学号，课程名，课程成绩*/

SELECT SNO AS 学号,
	CNAME AS 课程名,
	GRADE AS 课程成绩
FROM sc,course
WHERE sc.CNO = course.CNO AND SNO = '20022037'

/*也可以使用连接表达式实现查询，格式如下：*/

SELECT SNO AS 学号, CNAME AS 课程名 ,GRADE AS 课程成绩
FROM sc INNER JOIN course ON sc.CNO=course.CNO
WHERE SNO='20022037'

/*2．查询每个学生的每门课程的成绩，要求输出学号，课程名，成绩*/

SELECT SNO,CNAME,GRADE
FROM sc, course
WHERE sc.CNO=course.CNO

/*也可以使用连接表达式实现查询，格式如下：*/.

SELECT SNO,CNAME,GRADE
FROM sc INNER JOIN course ON sc.CNO=course.CNO

/*3．查询每个学生的每门课程的成绩，要求输出学号，姓名，课程号 ，成绩*/

SELECT student.SNO,SNAME,CNO,GRADE
FROM student, sc
WHERE student.SNO=sc.SNO

/*也可以使用连接表达式实现查询，格式如下：*/

SELECT student.SNO,SNAME,CNO,GRADE
FROM student INNER JOIN sc ON student.SNO=sc.SNO

/*以上查询中如果学生没有选课，查询结果中不显示该学生的信息,
如果要查询每个学生的信息及其选课信息，如要求输出学号，姓名，
课程号，成绩，则可用外连接实现。*/

SELECT student.SNO,SNAME,CNO,GRADE
FROM student LEFT OUTER JOIN sc ON student.SNO=sc.SNO

/*思考：比较以上两个查询的结果有何不同？为什么？
左外连接可以找到并未选课的学生的选课信息，
内连接只找到了选了课的学生的选课信息*/

/*4．查询选修了'线性代数'课程的学生学号、姓名*/

SELECT student.SNO, SNAME
FROM sc, course,student
WHERE sc.SNO=student.SNO AND sc.CNO=course.CNO
AND course.CNAME='线性代数'

select student.sno,sname
from student
where sno in
	(select sno
	from sc
	where cno in
	 (select cno from course where cname = '线性代数')
	 )

/*5．查询'线性代数'的所有授课班级的平均成绩，
并列出授课班号、教师名、平均成绩，且按平均成绩排序*/

SELECT sc.CNO,course.TNAME,AVG(GRADE) AS 平均成绩
FROM sc,course
WHERE sc.CNO=course.CNO AND CNAME='线性代数'
GROUP BY sc.CNO,course.TNAME
ORDER BY AVG(GRADE)

/*6．使用多表连接方法，查询和学号为‘20000156’的同学同年同月同日出生
的所有学生的学号、姓名、生日。*/

SELECT a.SNO,a.SNAME,a.BIRTHDAY
FROM student AS a, student b
WHERE a.BIRTHDAY =b.BIRTHDAY AND b.SNO='20000156'

7．使用嵌套查询方法，查询和学号为‘20000156’的同学同年同月出生的
所有学生的学号、姓名、生日。*/

SELECT SNO,SNAME,BIRTHDAY
FROM student
WHERE YEAR(BIRTHDAY)+MONTH(BIRTHDAY)=
	(SELECT YEAR(BIRTHDAY)+MONTH(BIRTHDAY) 
	FROM student
	WHERE SNO='20000156')

/*说明：该嵌套子查询只执行一次，整个查询效率比第 6 题快*/

/*8．使用嵌套查询方法，查询“赵蓉”教师任课的学生成绩，
并按成绩递增排列*/

SELECT CNO,SNO,GRADE
FROM sc
WHERE CNO IN
	( SELECT CNO 
	FROM course
	WHERE TNAME='赵蓉' )
ORDER BY GRADE

/*说明：该嵌套子查询只执行一次，执行效率比多表连接查询效率高*/

/*9. 使用嵌套查询方法，查询课程最低分大于70，
最高分小于90的学生学号和姓名*/

SELECT SNO,SNAME
FROM student
WHERE SNO IN
	( SELECT SNO
	FROM sc
	GROUP BY sc.SNO
	HAVING MIN(GRADE)>70 AND MAX(GRADE)<90 )

/*10．用嵌套法查询选修了“线性代数“的学生学号和姓名*/

SELECT SNO,SNAME
FROM student
WHERE SNO IN
	(SELECT SNO 
	FROM sc
	WHERE CNO IN
		( SELECT CNO 
		FROM course
		WHERE CNAME='线性代数' )
	)

/*说明：该查询使用了两层嵌套查询，查询次序为从里向外执行*/

/*11．从选修’ 218801’课程的同学中，选出成绩高于’季莹 ’的
学生的学号和成绩*/

SELECT SNO,GRADE
FROM sc
WHERE CNO='218801' AND GRADE >
	(SELECT GRADE 
	FROM sc
	WHERE CNO='218801' AND SNO=
		(SELECT SNO 
		FROM student
		WHERE SNAME='季莹 ' )
	)

/*说明：先执行子查询，再执行主查询，该子查询只执行一次*/

/*12．查询成绩比该课程平均成绩低的学生成绩表*/

SELECT SNO,CNO,GRADE
FROM sc AS a
WHERE GRADE<
	( SELECT AVG(GRADE)
	FROM sc AS b
	WHERE a.CNO=b.CNO
	)

/*说明：主查询在判断每个待选行时，唤醒子查询，
告诉它该学生选修的课程号，并由子查询计算该课程的平均成绩，
然后将该学生的成绩与平均成绩进行比较，找出符合条件的记录，
这种子查询称为相关子查询。*/

/*13．查询选修了'线性代数'这门课程的学生学号*/

SELECT SNO,SNAME
FROM student
WHERE EXISTS
	( SELECT *
	FROM sc ,course
	WHERE sc.CNO=course.CNO AND student.SNO=sc.SNO AND
		course.CNAME='线性代数'
	)

/*说明：主查询在判断每个学生时，执行子查询，
根据主查询中的当前行的学号，在子查询
中，从头到尾进行扫描，判断是否存在该学生的选课记录，
如果存在这样的行， EXISTS子句返回真，主查询选中当前行；
如果子查询未找到这样的行，EXISTS子句返回假， 主查询不选中当前行。*/

/*14．查询所有学生都选修的课程名*/

SELECT CNAME
FROM course
WHERE not EXISTS
	(
	SELECT * FROM student
	WHERE not EXISTS
		( SELECT * FROM sc
		WHERE SNO=student.SNO AND CNO=course.CNO )
	)

/*15．查询选修了'线性代数'课程或'英语口语'课程的学生学号、姓名。*/

SELECT DISTINCT student.SNO,SNAME
FROM sc,course,student
WHERE sc.SNO=student.SNO AND sc.CNO=course.CNO AND
	(course.CNAME='线性代数' OR course.CNAME='英语口语')

/*16. 用集合操作符UNION查询选修了'线性代数'课程或'英语口语'课程的
学生学号、姓名。*/

SELECT student.SNO,SNAME 
FROM sc,course,student
WHERE sc.SNO=student.SNO AND sc.CNO=course.CNO 
	AND course.CNAME='线性代数'
UNION
SELECT student.SNO,SNAME 
FROM sc,course,student
WHERE sc.SNO=student.SNO AND sc.CNO=course.CNO
	AND course.CNAME='英语口语'

/*本查询也可以用以下查询实现：*/

SELECT student.SNO,SNAME 
FROM sc,course,student
WHERE sc.SNO=student.SNO AND sc.CNO=course.CNO
	AND course.CNAME='线性代数' OR course.CNAME='英语口语'

/*17．查询选修了'218801'课程但没有选修'216301'课程的学生学号。
此查询可通过集合差 EXCEPT 实现。*/

SELECT STUDENT.SNO,SNAME
FROM STUDENT,SC
WHERE SC.SNO=STUDENT.SNO AND CNO='218801'
EXCEPT
SELECT STUDENT.SNO, SNAME
FROM STUDENT,sc
WHERE STUDENT.SNO=SC.SNO AND CNO='216301'

/*本查询也可以用以下子查询实现：*/

SELECT STUDENT.SNO, SNAME 
FROM student
WHERE SNO IN
	( SELECT SNO FROM sc
		WHERE CNO='218801' )
	AND SNO NOT IN
	( SELECT SNO FROM sc
		WHERE CNO='216301' )

/*18．求同时选修'218801'课程和'216301'课程的学生学号、姓名。
此查询可通过集合交 INTERSECT 实现。*/

SELECT STUDENT.SNO,SNAME
FROM SC,STUDENT
WHERE SC.SNO = STUDENT.SNO AND CNO = '218801'
INTERSECT
SELECT STUDENT.SNO,SNAME
FROM SC,STUDENT
WHERE SC.SNO = STUDENT.SNO AND CNO = '216301'

/*本查询也可以用以下子查询实现：*/
SELECT STUDENT.SNO,SNAME
FROM STUDENT
WHERE SNO IN
	(SELECT SNO
	FROM SC
	WHERE CNO = '218801' AND SNO IN
		(SELECT SNO
		FROM SC
		WHERE CNO = '216301')	
	)

/*19．查询所有学生及其选课信息*/

SELECT STUDENT.SNO,SNAME,CNO,GRADE
FROM STUDENT LEFT OUTER JOIN SC
ON STUDENT.SNO = SC.SNO

/*20．创建课程平均分视图*/

CREATE VIEW 课程平均分
AS
SELECT CNAME,AVG(GRADE) AS 平均分
FROM SC,COURSE
WHERE SC.CNO = COURSE.CNO
GROUP BY CNAME

/*21．以列的方式统计每门课程的分数段人数。分数段为：
不及格、 60-70、 70-80、 80-90、90-100*/

(SELECT CNAME ,'不及格' AS fsd ,COUNT(*) AS rs
FROM sc,course
WHERE sc.CNO=course.CNO AND GRADE <60
GROUP BY CNAME)
UNION
(SELECT CNAME ,'60-70' AS fsd , COUNT (*)
FROM sc,course
WHERE sc.CNO=course.CNO AND GRADE BETWEEN 60 AND 70
GROUP BY CNAME)
UNION
(SELECT CNAME ,'70-80' AS fsd , COUNT (*)
FROM sc,course
WHERE sc.CNO=cCourse.CNO AND GRADE BETWEEN 70 AND 80
GROUP BY CNAME)
UNION9
(SELECT CNAME ,'80-90' AS fsd , COUNT (*)
FROM sc,course
WHERE sc.CNO=course.CNO AND GRADE BETWEEN 80 AND 90
GROUP BY CNAME)
UNION
(SELECT CNAME ,'90-100' AS fsd , COUNT (*)
FROM sc,course
WHERE sc.CNO=course.CNO AND GRADE BETWEEN 90 AND 100
GROUP BY CNAME)

/*思考模仿题：*/

/*1．查询所有选课学生的姓名*/

SELECT SNAME
FROM STUDENT
WHERE EXISTS
	(SELECT *
	FROM SC
	WHERE STUDENT.SNO = SC.SNO)

SELECT SNAME
FROM STUDENT
WHERE SNO IN
	(SELECT SNO
	FROM SC
	WHERE STUDENT.SNO = SC.SNO)

/*2．查询所有未选课的学生的姓名*/

SELECT SNAME
FROM STUDENT
WHERE NOT EXISTS
	(SELECT *
	FROM SC
	WHERE STUDENT.SNO = SC.SNO)


SELECT SNAME
FROM STUDENT
WHERE SNO NOT IN
	(SELECT SNO
	FROM SC
	WHERE STUDENT.SNO = SC.SNO)

/*3．按学生分类查询其选修课程的平均分，输出学号、姓名和平均成绩*/

SELECT student.SNO,student.SNAME,AVG(GRADE)
FROM student,sc
WHERE student.SNO=sc.SNO
GROUP BY student.SNO,student.SNAME

SELECT STUDENT.SNO,SNAME,AVG(GRADE) AS 平均成绩
FROM STUDENT,SC
WHERE STUDENT.SNO = SC.SNO
GROUP BY STUDENT.SNO,SNAME

/*4．查询所有课程的平均分，输出课程名和平均成绩，并按平均成绩递增*/

SELECT CNAME,AVG(GRADE)
FROM sc,course
WHERE sc.CNO=course.CNO
GROUP BY CNAME
ORDER BY AVG(GRADE)

/*5. 查询少于10名同学选修的课程名称，授课班号，教师名，选课人数*/

SELECT CNAME,SC.CNO,TNAME,COUNT(*)
FROM SC,COURSE
WHERE SC.CNO=COURSE.CNO
GROUP BY CNAME,SC.CNO,TNAME
HAVING COUNT(*) <10
ORDER BY AVG(GRADE)

/*6．按学号显示信息学院，‘通信专业 ’或‘电子科学专业 ’的
每个学生的每门课程的成绩明细，并统计每个学生的总成绩，平均成绩*/

SELECT SNO,CNO,GRADE
FROM sc
WHERE SUBSTRING(SNO,5,2) IN('22','24')
ORDER BY SNO
COMPUTE SUM(GRADE),AVG(GRADE),MAX(GRADE) BY SNO

/*7．统计每门课的不及格人数，列出课程名和不及格人数*/

SELECT CNAME ,'不及格分数段' AS fsd ,COUNT(*) AS rs
FROM sc, course
WHERE sc.CNO= course.CNO AND GRADE<60
GROUP BY CNAME

/*思考题*/

/*1、在学生管理数据库中，完成以下查询：*/

/*（1） 使用嵌套方法查询存在有95分以上成绩的课程 CNO*/

SELECT CNO,CNAME
FROM COURSE
WHERE cno in
	(SELECT CNO 
	FROM SC
	GROUP BY CNO,SC.GRADE
	HAVING SC.GRADE > 95)

/*（2） 查询成绩比该课程平均成绩低的学生成绩表*/

SELECT SNO,CNO,GRADE
FROM SC AS a
WHERE GRADE<
	( SELECT AVG(GRADE)
	FROM SC AS b
	WHERE a.CNO=b.CNO
	group by cno
	)

/*（3） 按课程名称统计每一门课程的平均分，输出课程名称和平均分*/

SELECT CNAME,AVG(GRADE) AS 平均成绩
FROM SC,COURSE
WHERE SC.CNO = COURSE.CNO
GROUP BY CNAME

/*（4）按学生姓名统计其选修课程的总学分，输出学生姓名和总学分*/

SELECT SNAME,SUM(CREDIT) AS 总学分
FROM STUDENT,SC,COURSE
WHERE STUDENT.SNO = SC.SNO AND SC.CNO = COURSE.CNO
GROUP BY SNAME


/*（5） 查询同时选修了‘203402’ 和 ‘244501’ 课程的同学名称*/

SELECT STUDENT.SNO,SNAME
FROM SC,STUDENT
WHERE SC.SNO = STUDENT.SNO AND CNO = '203402'
INTERSECT
SELECT STUDENT.SNO,SNAME
FROM SC,STUDENT
WHERE SC.SNO = STUDENT.SNO AND CNO = '244501'

/*子查询实现：*/
SELECT STUDENT.SNO,SNAME
FROM STUDENT
WHERE SNO IN
	(SELECT SNO
	FROM SC
	WHERE CNO = '203402' AND SNO IN
		(SELECT SNO
		FROM SC
		WHERE CNO = '244501')	
	)


/*（6） 求最高分学生的学号*/

/*错误*/
/*SELECT A.SNO,A.CNO,GRADE
FROM SC AS A
WHERE A.GRADE = (
	SELECT MAX(GRADE)
	FROM SC AS B
	WHERE A.CNO = B.CNO
	GROUP BY B.CNO
	)*/  
SELECT A.SNO,A.CNO,GRADE
FROM SC AS A
WHERE A.GRADE = (
	SELECT MAX(GRADE)
	FROM SC AS B
	WHERE A.CNO = B.CNO
	GROUP BY B.CNO
	)
ORDER BY A.CNO

/*（7）查询“线性代数”的所有授课班级的平均成绩，列出课程名和平均成绩*/

SELECT SC.CNO,CNAME,AVG(GRADE) AS AVG
FROM SC,COURSE
WHERE CNAME = '线性代数' AND SC.CNO = COURSE.CNO
GROUP BY SC.CNO,CNAME

/*（8） 查询“线性代数”成绩最高的前5名学生的姓名及成绩,结果按成绩降序*/

SELECT TOP 5 SC.SNO,SNAME,GRADE
FROM SC,STUDENT,COURSE
WHERE SC.SNO = STUDENT.SNO AND SC.CNO = COURSE.CNO 
	AND CNAME = '线性代数'
GROUP BY SC.SNO,SNAME,GRADE
ORDER BY GRADE DESC


/*（9） 查询学生 “20002059”选修课程的总学分数*/

SELECT SUM(CREDIT) AS 总学分
FROM SC,COURSE
WHERE SC.CNO = COURSE.CNO AND SNO = '20002059'

/*（10） 对每个同学，查找其获得最高成绩的课程号*/

SELECT *
FROM SC AS sc1
WHERE GRADE = (
		SELECT MAX(GRADE)
		FROM SC AS sc2
		WHERE sc2.SNO = sc1.SNO
		GROUP BY SNO
)

