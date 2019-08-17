/*建立一个新表‘成教表’ chengjiao，结构与 student 表相同。*/
CREATE TABLE chengjiao
(
SNO char (8) not null unique,
SNAME char(10),
SEX char(2),
DNO char(8),
AGE smallint,
BIRTHDAY datetime )


/*思考题*/

/*（1）在选课表中插入一个新的选课记录，
学号为20002059，授课班号为244501，成绩80分。*/
insert sc (sno,cno,grade) values(20002059,244501,80)

/*（2）从选课表中删除选修‘线性代数’的选修纪录*/
delete from sc 
where cno in
  (select cno from course where cname = '线性代数')

/*（3）将机电学院的女生一次性添加到成教表中*/
insert into chengjiao(sno,sname,sex,dno)
(select sno,sname,sex,dno from student where sex = '女' 
	and SUBSTRING(SNO,5,1)='1')

/*（4）将所有学生的高等数学成绩加５分*/
UPDATE sc SET GRADE=GRADE+5
WHERE CNO IN
(SELECT CNO FROM course
WHERE CNAME='高等数学')

/*（5）将学号尾数为‘4’的同学成绩加 2*/
UPDATE sc SET GRADE=GRADE+2
WHERE sno IN
(SELECT sno FROM student
WHERE sno like '%4')

/*（6）删除电科系所有学生的选课记录*/
delete from sc 
where sno in
  (select sno from student where SUBSTRING(SNO,5,2)='29')

/*（7）将学号为“20002059”的学生姓名改为“王菲”*/
update student set sname = '王菲' where sno = 20002059

/*（8）删除成绩为空的选课记录*/
delete from sc where grade is null