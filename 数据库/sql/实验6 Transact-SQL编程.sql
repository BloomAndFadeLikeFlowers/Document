

/*实验内容*/

/*1．定义一个实型变量，并将其值输出*/

DECLARE @f float
SET @f=456.256
PRINT CAST( @f AS varchar(12))

/*2．定义一个字符变量，并将其处理后输出*/

DECLARE @mynumber char(20)
SET @mynumber='test'
SELECT 'COMPUTER'+@mynumber AS '计算结果'

/*3．根据授课班号自定义变量，查询符合要求的学生成绩*/

DECLARE @cn char(6),@f float
SET @cn='218801'
SET @f=857
SELECT * FROM sc WHERE CNO=@cn AND GRADE>=@f

/*4． BEGIN… …END……的使用*/

BEGIN
DECLARE @myval float
SET @myval=456.234
BEGIN
PRINT '变 量@myval 的 值 为'
PRINT CAST(@myval AS char(12))
END
END

/*5．利用 CASE 查看学生的成绩等级*/


SELECT SNO, CNO,GRADE,
	CASE
		WHEN GRADE>=80 THEN 'A'
		WHEN GRADE>=70 THEN 'B'
		WHEN GRADE>=60 THEN 'C'
		ELSE 'D'
		END
	AS 等级
FROM sc

/*说明：SELECT后的列表值 ， 也可以来源于一个判断结构*/

/*6.创建一个视图，统计每个学生的学习情况。
若其平均成绩超过 90，则其学习情况为优秀；
若其平均成绩在 80 和 90 之间，则其学习情况为优秀良好；
依次类推。*/

CREATE VIEW student_grade
AS
SELECT SNO,SNAME,
	CASE
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>90 THEN '优秀'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>80 THEN '良好'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>70 THEN '中等'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>60 THEN '合格'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)<60 THEN '不合格'
		END
	AS '成绩等级'
FROM student

/*7．利用 WHILE 结构，求:1+2+3+..+100 的值*/

DECLARE @s int,@i int
SET @i=0
SET @s=0
WHILE @i<=100
BEGIN
SET @s=@s+@i
SET @i=@i+1
END
PRINT '1+2+3+…+100='+CAST(@s AS char)

/*8.利用 IF…ELSE，查询课程号为'234901'的学生的总平均成绩,
如果大于90，输出优秀，在 80-90 之间，输出优良， 其它输出一般*/

DECLARE @chegji int
SELECT @chegji=AVG(GRADE) FROM sc WHERE CNO='234901'
IF @chegji>90
 PRINT '优秀'
ELSE
 BEGIN
  IF @chegji>80
	PRINT '优良'
  ELSE
	PRINT '一般'
 END

/*9．定义一函数，实现如下功能，对于一给定的学号studentSNO，
查询该值在student中是否存在，存在返回 1，不存在返回 0。*/

CREATE FUNCTION check_id
(@studentSNO char(8))
RETURNS integer
AS
BEGIN9
DECLARE @num int
IF(EXISTS(SELECT * FROM student WHERE SNO=@studentSNO))
SET @num=1
ELSE
SET @num=0
return @num
END

/*10．使用下面的SQL语句调用第9题的函数。
要求当向表 student 中插入一条记录时，
首先调用函数check_id，检查该记录的学号在表 student 中是否存在，
不存在，才可以插入 。*/

DECLARE @num int
SET @num=dbo.check_id('20081200')
IF @num=0
INSERT INTO student(SNO,SNAME) values('20081200','张 文')

/*11．求学生选课的门数，列出其姓名及选课门数*/

SELECT SNAME,(SELECT COUNT(*) FROM sc WHERE SNO=student.SNO) AS 选课门数
FROM student

/*说明： SELECT 后的列表值，可以来源于内嵌sql语句,
但必须保证内嵌sql语句只能返回一个值*/

/*12．根据课程号动态查询学生的选课人数*/

DECLARE @cno char(8)
DECLARE @sql varchar(8000)
SET @cno='218801'
--动 态 生 成 SQL 语 句
SET @sql='SELECT COUNT(*) FROM sc WHERE CNO='''+@cno+''''
EXEC(@sql)
SET @cno='203402'
SET @sql='SELECT COUNT(*) FROM sc WHERE CNO='''+@cno+''''
EXEC (@sql)

/*说明：可以利用变量以及字符串连接字符‘＋’，动态生成SQL语句，
达到依据条件，进行数据库动态查询目的。其中，
连接字符串中若包含单引号’字符，则必须用两 个’’,表示一个单引号’字符。*/

/*13．用游标结合循环，输出全校各种姓氏及其人数10*/

--记录数
DECLARE @count int
--循环变量
DECLARE @i int
--各种姓氏和人数
DECLARE @xing char(6),@rs int
--定义游标
DECLARE @name_cursOR CURSOR
--给游标赋值
SET @name_cursOR =CURSOR LOCAL SCROLL FOR
SELECT DISTINCT SUBSTRING(SNAME,1,1) AS xing, count(*) AS rs
FROM student
GROUP BY SUBSTRING(SNAME ,1,1)
--循环变量初始化
SET @i=0
--打开游标
OPEN @name_cursOR
SET @count=@@CURSOR_ROWS
--@@CURSOR_ROWS 表示游标对应的记录集中的记录个数
PRINT @count
--判断游标中是否有记录
IF @count<= 0 --没有纪录
BEGIN
PRINT '没有记录'
END
--存在记录
ELSE BEGIN
--循环处理每一条记录
WHILE(@i<@count)
BEGIN
FETCH NEXT FROM @name_cursOR INTO @xing,@rs
PRINT CONVERT(CHAR(20),@i)+@xing+CAST(@rs AS CHAR(20))
SET @i=@i+1
END
CLOSE @name_cursOR --关闭游标
END

/*说明：本例中用游标存放全校各种姓氏的人数统计结果，然后，通过循环的方式，
进行输出。游标更具体的应用请看下一题的三维透视表的查询。*/

/*14．利用游标结合循环，统计学院各种姓氏的人数*/

DECLARE @count int
DECLARE @i int
DECLARE @xing char(6)
DECLARE @rs int
DECLARE @sql varchar(8000)
SET @sql=''
SET @i=0
DECLARE @name_cursOR CURSOR
SET @name_cursOR =CURSOR LOCAL SCROLL FOR
SELECT DISTINCT SUBSTRING(SNAME,1,1) AS xing,count(*) AS rs
FROM student
GROUP BY SUBSTRING(SNAME,1,1)
OPEN @name_cursOR
SET @count=@@CURSOR_ROWS
IF @count<= 0
BEGIN
PRINT '没有记录'
END
ELSE
BEGIN
WHILE(@i<@count-300)
BEGIN
FETCH @name_cursOR INTO @xing,@rs
--动态生成前300个姓氏SQL语句
SET @sql=@sql+'(SELECT COUNT(*) FROM student WHERE DNO=a.DNO
AND SUBSTRING(SNAME,1,1)='''+@xing+''') AS '+@xing+','
SET @i=@i+1
END
FETCH @name_cursOR INTO @xing,@rs
--动 态 生 成 第 301 个 姓 氏 SQL 语 句
SET @sql=@sql+'(SELECT count(*) FROM student WHERE DNO=a.DNO
AND SUBSTRING(SNAME,1,1)='''+@xing+''') AS '+@xing
CLOSE @name_cursOR
PRINT @sql
SET @sql='SELECT DNAME ,'+@sql+'FROM (SELECT DISTINCT
STUDENT.DNO,DNAME FROM student,DEPT WHERE student.DNO=DEPT.DNO) AS a'12
EXEC(@sql)
END

/*说明：由于字符变量最多只能存储8000个字符，所以本例只统计了前301个姓氏。*/

/*思考模仿题：*/

/*1. 利用CASE实现学生表中学院编号到学院名称的映射*/

SELECT SNO,SNAME,
CASE
WHEN SUBSTRING(SNO,5,1)='1' THEN '机电学院'
WHEN SUBSTRING(SNO,5,1)='2' THEN '信息学院'
WHEN SUBSTRING(SNO,5,1)='3' THEN '工商学院'
END
FROM student

/*2. 定义一函数，实现如下功能，对于一给定的学号studentSNO和
课程号studentCNO查询该值在student和course中是否存在，
存在返回 1，不存在返回 0。*/

CREATE FUNCTION check_sc(@studentSNO char(8),@studentCNO CHAR(8))
RETURNS integer
AS
BEGIN
DECLARE @num int
IF( EXISTS(SELECT * FROM student WHERE SNO=@studentSNO) AND
EXISTS(SELECT * FROM course WHERE CNO=@studentCNO) )
SET @num=1
ELSE
SET @num=0
RETURN @num
END

/*3．根据教师名自定义变量，查询符合要求的教师授课情况*/

DECLARE @tname char(6)
SET @tname='张聪'
SELECT * FROM course WHERE TNAME=@tname

/*4．求授课班号及选修该授课班号的学生人数*/

SELECT CNO AS 授课班号 ,
( SELECT COUNT(*) FROM sc WHERE CNO=course.CNO) AS 选课人数
FROM course

/*5．定义一函数，根据学号返回学生的选课门数（参考INSERT触发器）*/

CREATE FUNCTION COUNT_course(@studentSNO char(8)) RETURNS integer
AS
BEGIN
DECLARE @num int
SELECT @num=COUNT(*) FROM sc WHERE SNO=@studentSNO
RETURN @num
END

/*请同学编写SQL语句调用上述函数，查询'20002059'号学生的选课门数。*/

/*6．修改学生的成绩，若大于80分，增加5分，否则，增加8分*/

UPDATE sc
SET GRADE=
(
CASE
WHEN GRADE>=80 THEN GRADE+5
ELSE GRADE+8
END
)

/*思考题*/

/*（1）按课程名称，统计其平均分，列出其课程名称和平均分*/
select cname as 课程名称,
	(select avg(grade) from sc where cno = course.cno) as 平均分
from course

/*（2）求每个学生选课的门数及其平均分，列出其姓名、课程门数及平均分*/
select sname as 姓名,
	(select count(*) from sc where sno = student.sno) as 课程门数,
	(select avg(grade) from sc where sno = student.sno) as 平均分
from student

/*（3）定义一函数，依据学生的姓名，查询其所选课程的门数*/
create function count_courseBySNAME(@studentNAME char(50))
returns integer
as
begin
declare @num int
select @num = count(*) from student where sname = @studentNAME
return @num
end

/*（4）根据学院名称，统计学生人数，列出学院名称和学生人数*/
SELECT 
CASE
WHEN SUBSTRING(SNO,5,1)='1' THEN '机电学院'
WHEN SUBSTRING(SNO,5,1)='2' THEN '信息学院'
WHEN SUBSTRING(SNO,5,1)='3' THEN '工商学院'
END AS 学院名称,
(select count(*) from student where dno = a.dno ) as 学生人数
FROM student as a

/*（5）若存在学号为‘20081200’的学生，则显示其姓名，否则,显示相应提示信息*/
DECLARE @studentNAME char(80)
DECLARE @studentSNO char(8)
SET @studentSNO = '20081200'
IF(EXISTS(SELECT * FROM STUDENT WHERE SNO =  @studentSNO))
	SET @studentNAME = (SELECT SNAME FROM STUDENT WHERE SNO =  @studentSNO)
ELSE
	SET @studentNAME = '不存在学号为'+@studentSNO+'的学生'
PRINT @studentNAME 

/*（6）查找每个学生超过他选修课程平均成绩的课程相关信息,列出学号，课程号， 
成绩，选课平均成绩*/

select sno,cno,grade,
	(select avg(grade) from sc as sc1 where sc.cno = sc1.cno) 
		as 课程平均成绩
from sc
where grade >
	(select avg(grade) from sc as sc1 where sc.cno = sc1.cno)

/*（7）创建一视图，统计每门课程的学习情况。若课程平均成绩超过90，
则其学习情况为优秀；若课程平均成绩在80和90之间，则其学习情况为优秀良好；
依次类推。*/

CREATE VIEW student_grade
AS
SELECT SNO,SNAME,
	CASE
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>90 THEN '优秀'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>80 THEN '良好'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>70 THEN '中等'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)>60 THEN '合格'
		WHEN (SELECT AVG(GRADE) FROM sc WHERE SNO=STUDENT.SNO)<60 THEN '不合格'
		END
	AS '成绩等级'
FROM student

/*（8）利用游标结合循环，统计各门课程的各种分数的人数。*/
DECLARE @count int
DECLARE @i int
DECLARE @chengji float
DECLARE @rs int
DECLARE @sql varchar(8000)
SET @sql=''
SET @i=0
DECLARE @name_cursOR CURSOR
SET @name_cursOR =CURSOR LOCAL SCROLL FOR
SELECT DISTINCT grade AS chengji,count(*) AS rs
FROM sc
GROUP BY grade
OPEN @name_cursOR
SET @count=@@CURSOR_ROWS
IF @count<= 0
BEGIN
PRINT '没有记录'
END
ELSE
BEGIN
WHILE(@i<@count-1)
BEGIN
FETCH @name_cursOR INTO @chengji,@rs
SET @sql=@sql+'(SELECT COUNT(*) FROM sc WHERE CNO=a.CNO
AND grade='''+convert(varchar(20),@chengji)+''') AS '''+convert(varchar(20),@chengji)+''','
SET @i=@i+1
END
FETCH @name_cursOR INTO @chengji,@rs
SET @sql=@sql+'(SELECT count(*) FROM sc WHERE CNO=a.CNO
AND grade='''+convert(varchar(20),@chengji)+''') AS '''+convert(varchar(20),@chengji)+''''
CLOSE @name_cursOR
PRINT @sql
SET @sql='SELECT CNAME ,'+@sql+'FROM (SELECT DISTINCT
course.CNO,CNAME FROM course,sc WHERE course.CNO=sc.CNO) AS a'
PRINT @sql
EXEC(@sql)
END