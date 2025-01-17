/*简单查询—单表查询和视图*/

/*1.求学院编号为“0001”的学生的学号，姓名，性别*/
SELECT SNO,SNAME,SEX 
FROM STUDENT 
WHERE DNO = '0001';

/*2.求学院编号为“0001”的男生的学号，姓名，性别*/
SELECT SNO,SNAME,SEX
FROM STUDENT
WHERE DNO = '0001' AND SEX = '男';

/*3.求选修授课班号为‘327401’切成绩在80-90之间的学生学号和成绩乘以系数0.8输出，切将SNO列更名为学号，成绩列更名为处理成绩*/
SELECT SNO AS 学号,0.8*GRADE AS 处理成绩
FROM SC
WHERE CNO = '327401' AND GRADE BETWEEN 80 AND 90;

/*4.求每个学生的年龄，并输出年龄和姓名*/
SELECT SNAME AS 姓名 ,YEAR(GETDATE()) - YEAR(BIRTHDAY) AS 年龄
FROM STUDENT;

/*5.求选修了课程的学生的学号*/
SELECT DISTINCT SNO 
FROM SC;

/*6.求选修授课班号为 327401 的学生学号和成绩，并要求对查询结果按成绩降序排列，如果成绩相同，则按学号升序排列*/
SELECT SNO ,GRADE
FROM SC
WHERE CNO = '327401'
ORDER BY GRADE DESC,SNO ASC;

/*7.求缺少了成绩的学生学号和课程号*/
SELECT SNO ,CNO
FROM SC
WHERE GRADE IS NULL;

/*8.统计选课学生人数及最高分成绩与最低分成绩*/
SELECT COUNT(DISTINCT SNO) AS学生人数,
		MAX(GRADE) AS 最高分,
		MIN(GRADE) AS 最低分
FROM SC;

/*9.求学院编号为 0001 或 0002 中姓张的学生的信息*/
SELECT *
FROM STUDENT
WHERE (DNO = '0001' OR DNO = '0002') AND SNAME LIKE '张%'; 

/*10.求姓名中包含 丽 的学生信息*/
SELECT *
FROM STUDENT
WHERE SNAME LIKE '%丽%'; 

/*11.求姓名只有两个字，切第二个字为  丽 的学生信息*/
SELECT *
FROM STUDENT
WHERE SNAME LIKE '_丽'; 

/*12.求信息学院计算机专业的学生名单*/
SELECT *
FROM STUDENT
WHERE SUBSTRING(SNO,5,2) = '28';

/*13.统计各个学院的人数*/
SELECT COUNT(SNO) AS 学院总人数,
		DNO AS 部门编号
FROM STUDENT
GROUP BY DNO;

/*14.按授课班号统计选修该课程的人数，并按照人数升序排列*/
SELECT COUNT(SNO) AS 人数统计,
		CNO
FROM SC
GROUP BY CNO
ORDER BY 人数统计;

/*15.统计平均成绩超过 80 分的学生的学号及平均成绩*/
SELECT SNO,
	AVG(GRADE) AS 平均成绩
FROM SC
GROUP BY SNO
HAVING AVG(GRADE) >= 80
ORDER BY AVG(GRADE);

/*16.求选修课程超过6门课的学生学号，并按选修课程数目升序排列*/
SELECT SNO,
	COUNT(*)
FROM SC
GROUP BY SNO
HAVING COUNT(SNO) > 6
ORDER BY COUNT(SNO);

/*17.求每个学院学生的平均年龄，并把结果存入当前数据库  “系平均年龄” 临时表中*/
SELECT DNO,
	AVG(AGE) AS 平均年龄
	INTO 系平均年龄
FROM STUDENT
GROUP BY DNO

/*18.分页浏览数据方法：*/
     /*（1）查询学生库中的第1-10名学生的信息*/
	SELECT TOP 10 *
	FROM STUDENT;

     /*（2）查询学生库中的第11-20名学生的信息*/
	SELECT TOP 10 *
	FROM STUDENT
	WHERE SNO NOT IN (SELECT TOP 10 SNO FROM STUDENT);

/*19.查询 1987-1-1 号以后出生的女生的学生信息*/
SELECT *
FROM STUDENT
WHERE BIRTHDAY > '1987-1-1' AND SEX = '女';

/*20.创建 计算机系学生 视图，用于浏览计算机系学生的学号，姓名，年龄*/
CREATE VIEW 计算机系学生
AS SELECT SNO,SNAME,AGE
	FROM STUDENT 
	WHERE SUBSTRING(SNO,5,2) = '28';


/****思考模仿题：***/
/*1.查询分数在 70 和 90 之间的学生学号*/
SELECT SNO
FROM sc
GROUP BY SNO
HAVING MIN(GRADE)>70 AND MAX(GRADE)<90
/*2.查询少于 10 名同学选修的授课班号*/
SELECT CNO
FROM sc
GROUP BY CNO
HAVING COUNT(*)<10
ORDER BY CNO
/*3.查询选课表中的最高分*/
SELECT MAX(GRADE) AS 最高分
FROM sc
/*4.查询授课编号为‘153701’的课程的平均分*/
SELECT AVG(GRADE) AS '课程平均分'
FROM sc
WHERE CNO='153701'
/*5.查询课程平均分超过 85 的授课班号，输出结果按课程平均分升序排列*/
SELECT CNO,AVG(GRADE)
FROM sc
GROUP BY CNO
HAVING AVG(GRADE)>85
ORDER BY AVG(GRADE)
/*6.查询课程名称为’线性代数’的排课情况*/
SELECT *
FROM course
WHERE CNAME='线性代数'
/*7.查询选修授课班号为‘218801’的学生学号*/
SELECT SNO
FROM sc
WHERE CNO='218801'
ORDER BY SNO
/*8.按授课班号查询课程的平均分，输出授课班号和平均成绩*/
SELECT CNO,AVG(GRADE)
FROM sc
GROUP BY CNO
/*9.在 sc 中输出成绩在 90-100 之间的学生信息*/
SELECT * 
FROM sc 
WHERE CONVERT(char(20),GRADE) LIKE '9%'


/*思考题*/
1.查询 周芬 老师，这个学期的上课安排情况
SELECT *
FROM course
WHERE TNAME = '周芬'

2.查询姓周的老师的排课情况
SELECT *
FROM course
WHERE TNAME LIKE '周%'

3.按教室分组统计排课门数情况
SELECT COUNT(CNO) AS 排课门数,
		ROOM
FROM course
GROUP BY ROOM;

4.查询排课门数超过8门的教室名单及排课门数
SELECT COUNT(CNO) AS 排课门数,
		ROOM
FROM course
GROUP BY ROOM
HAVING COUNT(CNO) >8 

5.创建机电学院女生的视图
CREATE VIEW 机电学院女生
AS 
(SELECT * FROM student
 WHERE SUBSTRING(SNO,5,1)='1' AND SEX = '女')

6.查询学分超过4分的课程，输出课程名和学分，并要求按学分升序
SELECT CNAME,CREDIT
FROM course
WHERE CREDIT >4
ORDER BY CREDIT

7.按教室明细并汇总排课情况
SELECT CNAME,ROOM
FROM course
GROUP BY ROOM,CNAME
HAVING ROOM IS NOT NULL

8.查询课程号为 203402 的成绩最高的前5名学生的学号和成绩，结果按成绩降序
SELECT TOP 5 SNO,GRADE
FROM sc
WHERE CNO = '203402'
ORDER BY GRADE DESC

9.查询年龄小于20岁的学生学号
SELECT SNO
FROM student
WHERE (YEAR(GETDATE())-YEAR(BIRTHDAY)) < 20

10.查询有90人以上选修的课程号
SELECT CNO
FROM sc
GROUP BY CNO
HAVING COUNT(SNO)>90

11.查询全体男生的姓名，要求查询结果按所在系升序排列，对相同系的学生按姓名升序排列
SELECT SNAME
FROM student
WHERE SEX = '男'
ORDER BY DNO ASC,SNAME ASC

12.查询成绩在70-90范围内的学生学号
SELECT SNO
FROM sc
GROUP BY SNO
HAVING MIN(GRADE)>70 AND MAX(GRADE)<90

/*错误*/
/*
SELECT SNO
FROM sc
WHERE GRADE>70 AND GRADE<90
GROUP BY SNO;
*/