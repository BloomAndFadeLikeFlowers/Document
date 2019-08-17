
/*实验内容*/

/*1．创建一个按名字模糊查询学生基本信息的存储过程*/

CREATE PROCEDURE chaxun_student_name(@sname varchar(20))
AS
(
SELECT sno AS 学号,sname AS 姓名 ,age AS 年龄,dname AS 学院名称 FROM
student,dept
WHERE student.dno=dept.dno AND sname LIKE @sname
)
/*说明：存储过程必须先定义，然后在客户端进行调用。
在查询编辑器中，执行方法为： EXEC 存储过程名 参数
例如：本例调用存储过程查询名字中含有丽的学生信息方法为，
在查询编辑器中，执行如下语句：
EXEC chaxun_student_name '%丽%'*/

/*2．创建一个依据学生学号返回其所有课程平均分的存储过程student_average*/

CREATE PROCEDURE student_average (@c1 varchar(8))
AS
RETURN (SELECT AVG(GRADE) FROM sc WHERE SNO=@c1)

/*说明：请同学们使用下面的 SQL 语句调用该存储过程，
查询学号为'20002059'的学生的平均分：*/

DECLARE @no char(8) ,@avg float
SET @no='20002059'
EXEC @avg=student_average @no
PRINT CONVERT(CHAR(10),@avg)
SELECT SNAME ,@avg AS '平均分' FROM student WHERE SNO=@no

/*3.创建一个执行插入功能的存储过程，可以向chengjiao表中插入一条学生记录，
该存储过程包含三个参数，分别表示学生学号、学生姓名、学生出生日期，
其中学生出生日期参数默认值为'1990-1-1'。*/

CREATE PROCEDURE INSERT_chengjiao (@c1 varchar(8),@c2 varchar(10),@c3
datetime='1990-1-1')
AS
INSERT INTO chengjiao(SNO,SNAME,BIRTHDAY) values(@c1,@c2,@c3)

/*说明：存储过程的参数可以具有缺省值，使用方法同 c++相似。
请同学们使用下面的SQL语句调用该存储过程，向chengjiao表中插入'20081001'
和'20081002'两个学生：*/
EXEC INSERT_chengjiao '20081001', 'jiang'
EXEC INSERT_chengjiao '20081002','jiang','1991-12.1'

/*4．创建一个存储过程，可以根据指定的学生学号，通过参数返回该学生的
姓名和所选课的平均分。*/

CREATE PROCEDURE student_nameaverage(
@c1 varchar(8),@c2 varchar(10) OUTPUT ,@c3 float OUTPUT)
AS
SELECT @c2=SNAME , @c3=AVG(GRADE)
FROM student,sc
WHERE student.SNO=sc.SNO AND student.SNO=@c1
GROUP BY student.SNO,student.SNAME

/*说明：存储过程可以通过实参返回数据。请同学们使用下面的SQL语句调用
该存储过程，查询学号为'20002059'的学生的姓名和平均分：*/

DECLARE @s_name char(10)
DECLARE @s_avg float
EXEC student_nameaverage '20002059',@s_name OUTPUT, @s_AVG OUTPUT
PRINT @s_name
PRINT @s_avg

/*5．存储过程在执行后都会返回一个整型值。如果成功执行，返回 0；
否则，返回-1----99之间的数值。下例根据例3创建的存储过程，
判断该存储过程是否执行成功。*/

DECLARE @x Int
exec @x=INSERT_chengjiao '20082001', 'jiang'5
PRINT @x

/*说明：
语句执行结果为：
违反了 UNIQUE KEY 约束 'UQ__chengjiao__3D5E1FD2'。不能在对象 'chengjiao' 中
插入重复键。语句已终止。-4（-4 表示存储过程没有成功执行）*/

/*6．创建触发器，要求在学生表中删除一个学生时，同时从选课表中将
其所有选课信息删除*/

CREATE TRIGGER student_delete ON student
FOR DELETE
AS
DELETE FROM sc
WHERE sc.SNO IN(SELECT SNO FROM DELETED)

/*说明：该触发器是删除记录事件产生时，系统自动运行的。
请同学们在 student 中选中一个学生，察看其在 sc 中有几条记录，
然后，在 student 中，删除这个学生，再察看其在sc 中还有无记录。*/

/*7．创建触发器限定一个学生最多只能选择 4 门课*/

CREATE TRIGGER student_INSERT ON sc
FOR INSERT
AS
DECLARE @c1 int
SELECT @c1=COUNT(*) FROM sc WHERE SNO=(SELECT SNO FROM INSERTED)
IF( @c1>=5)
BEGIN
ROLLBACK
PRINT '超过4门课了，不能再选'
END

/*说明：该触发器是插入记录事件产生时，系统自动运行的。请同学们使用下面的 SQL
语句，测试该触发器：*/
INSERT sc values ('20002037','216303',78)
/*执行结果为：
超过 4 门课了，不能再选6*/

/*8．利用触发器限定修改后的分数只能比原来高*/

CREATE TRIGGER student_update ON sc
FOR UPDATE
AS
IF((SELECT COUNT(*) FROM INSERTED WHERE GRADE>(SELECT GRADE
FROM DELETED))=0)
BEGIN
ROLLBACK
PRINT '修改后的分数比原来的低，不允许 '
END
说明：该触发器是修改记录事件产生时，系统自动运行的。请同学们使用下面的 SQL
语句序列，测试该触发器：
（1） SELECT * FROM sc WHERE SNO='20012048'AND CNO='208401'
执行结果为：
20012048 208401 80
（2） UPDATE sc SET GRADE=60 WHERE SNO='20012048'AND CNO='208401'
执行结果为：
修改后的分数比原来的低，不允许*/

/*思考题*/

/*（1）创建一个存储过程 del_course，根据指定课程号删除course表中的
相应记录。*/

CREATE PROCEDURE del_course (@c1 varchar(8))
AS
delete from course where cno = @c1;

/*（2）在表DEPT上创建一个触发器depart_update，当更改学院编号时，同步更改
student表中的学院编号。*/

CREATE TRIGGER depart_update ON dept
FOR UPDATE
AS
UPDATE dept
SET dept.DNAME = (SELECT DNAME FROM DELETED)

/*（3）对课程course表创建触发器限定一个教师一学期最多只能上2门课*/

CREATE TRIGGER course_teacher ON sc
FOR INSERT
AS
DECLARE @c1 int
SELECT @c1=COUNT(*) FROM course WHERE tname=(SELECT tname FROM INSERTED)
IF( @c1>2)
BEGIN
ROLLBACK
PRINT '一个教师一学期最多只能上2门课'
END

/*（4）创建一个存储过程，可以根据指定的教师名，通过参数返回该教师
所上课程的门数及平均分。*/

CREATE PROCEDURE teacher_coursecount_avg(
@c1 varchar(80),@c2 integer OUTPUT ,@c3 float OUTPUT)
AS
SELECT @c2=count(*) , @c3=(select AVG(GRADE) from sc where sc.cno = course.cno)
FROM course
WHERE course.tname = @c1

SELECT tname,(select count(*) FROM course WHERE course.tname = '马会礼'), 
	(select AVG(GRADE) from sc where sc.cno = course.cno)
FROM course
/*每个老师的授课门数*/
SELECT tname,(select count(*) from course as a where course.tname = a.tname) as 授课门数
FROM course

/*（5）创建一个按教师名查询教师上课信息的存储过程*/

CREATE PROCEDURE course_by_teacher(@c1 varchar(8))
AS
SELECT cno, cname,tname
FROM course
order by tname

/*（6）创建一个按部门查询学生信息的存储过程*/