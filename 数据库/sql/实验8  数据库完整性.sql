
/*1.在XSGL数据库中，创建一个名为yanshi_student的表，指定SNO为主码，
且设置属性级约束、元组级约束和表级约束。*/

CREATE TABLE yanshi_student
( SNO char (8) ,
SNAME char (10) NOT NULL ,
AGE smallint NULL,
SEX char (2) NULL DEFAULT '男' /*SEX 缺省值为男 */ ,3
DNO char (4) NOT NULL ,
BIRTHDAY datetime NULL ,
PRIMARY KEY (Sno) /*在表级定义主码，实现实体完整性*/,
CHECK(SEX IN ('男','女')) /*性别属性 SEX 只允许取'男'或'女' */ ,
CHECK(SNO LIKE '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
/*SNO 只能为 8 位数字，且不能以 0 开头*/ ,
CHECK((SUBSTRING(SNO,5,1)='3' AND DNO='0003')
	OR(SUBSTRING(SNO,5,1) ='2' AND DNO='0002')
	OR (SUBSTRING(SNO,5,1) = '1' AND DNO='0001'))

/*定义了元组中SNO和DNO两个属性值之间的约束条件，SNO的第5位只能为1，2，3，
且当第5位为1时，DNO 只能为 0001，第 5 位为 2 时， DNO 只能为 0002，第 5
位为 3 时， DNO 只能为 0003)*/
请同学们用下列 SQL 语句调试，并观察其现象：
（1） INSERT yanshi_student(SNO,SNAME,DNO) values('x0001','li','0001')
（2） INSERT yanshi_student(SNO,SNAME,DNO) values('00001','li','0001')
（3） INSERT yanshi_student(SNO,SNAME,DNO) values('10001','li','0001')
（4） INSERT yanshi_student(SNO,SNAME,DNO) values('20073001','li','0001')
（5） INSERT yanshi_student(SNO,SNAME,DNO) values('20073001','li','0003')

/*2．在 XSGL 数据库中，创建一个名为 yanshi_course 的表，指定 CNO 为主码。*/

CREATE TABLE yanshi_course (
CNO char(6) ,
CNAME char(30) NOT NULL ,
TNAME char(10) NULL ,
CREDIT float NULL ,
ROOM char(30) NULL ,
PRIMARY KEY (CNO)
)
请同学们用下列 SQL 语句调试，并观察其现象：
（1） INSERT yanshi_course(CNO,CNAME) values('222201','软件技术基础')
（2） INSERT yanshi_course(CNO,CNAME) values('c43002','可视化程序设计与用户
界面')
（3） INSERT yanshi_course(CNO,CNAME) values('133804','工程训练')

/*3．在XSGL数据库中，创建一个名为yanshi_sc的表，指定 SNO、CNO为主码，
并且 SNO参照 yanshi_student表中的SNO，CNO参照yanshi_course表中的CNO。*/

CREATE TABLE yanshi_sc(
SNO char(8) ,
CNO char(6) ,
GRADE float NULL,
PRIMARY KEY(SNO,CNO),
FOREIGN KEY(SNO) references yanshi_student(SNO),
FOREIGN KEY(CNO) references yanshi_course(CNO),
CHECK (GRADE BETWEEN 0 AND 100),
)
请同学们用下列 SQL 语句调试，并观察其现象：
（1） INSERT yanshi_sc(SNO,CNO,GRADE) VALUES('20073001','222201',81)
（2） INSERT yanshi_sc(SNO,CNO,GRADE) VALUES ('20073001','133804',67)
（3） INSERT yanshi_sc(SNO,CNO,GRADE) VALUES('20073001','222203',70)
/*4．在 XSGL 数据库中，创建一个规则，限定绑定列的输入值在 0.5 和 5 之间，
并使用存储过程 sp_bindrule 将其绑定到 yanshi_course 表中的 CREDIT 列中，
限定学分只能在 0.5和 5 之间。*/

CREATE RULE rule1 AS @c1 BETWEEN 0.5 AND 5
EXEC sp_bindrule 'rule1','yanshi_course.CREDIT'
请同学们用下列 SQL 语句调试，并观察其现象：
（1） INSERT yanshi_course(CNO,CNAME,CREDIT) values('133805','工程训练',6)
（2） INSERT yanshi_course(CNO,CNAME,CREDIT) values('133805','工程训练',2)

/*5．解除 rule1 规则到 yanshi_course.CREDIT 的绑定，并删除该规则。*/

（1） EXEC sp_unbindrule 'yanshi_course.CREDIT'
（2） DROP RULE rule1

/*思考题*/

/*（1）创建一个表yanshi_depart，包含DNO、DNAME、DADDRESS和DEAN四个属性，
DNO由4个数字字符构成，且为该表的主码，DNAME由30个字符构成，DADDRESS由
5个字符构成，DEAN由10个字符构成。*/

CREATE TABLE yanshi_depart (
DNO char(4) ,
DNAME char(30) NOT NULL ,
DADDRESS char(5) NULL ,
DEAN char(10) NULL ,
PRIMARY KEY(DNO)
)

/*（2）为例1中的yanshi_student表建立外键“DNO”，参考表 yanshi_depart的
“DNO”列。*/
CREATE TABLE yanshi_student
( SNO char (8) ,
SNAME char (10) NOT NULL ,
AGE smallint NULL,
SEX char (2) NULL DEFAULT '男' /*SEX 缺省值为男 */ ,
DNO char (4) NOT NULL ,
BIRTHDAY datetime NULL ,
PRIMARY KEY (Sno) /*在表级定义主码，实现实体完整性*/,
FOREIGN KEY (DNO) references yanshi_depart,
CHECK(SEX IN ('男','女')) /*性别属性 SEX 只允许取'男'或'女' */ ,
CHECK(SNO LIKE '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
/*SNO 只能为 8 位数字，且不能以 0 开头*/ ,
CHECK((SUBSTRING(SNO,5,1)='3' AND DNO='0003')
	OR(SUBSTRING(SNO,5,1) ='2' AND DNO='0002')
	OR (SUBSTRING(SNO,5,1) = '1' AND DNO='0001'))
)

/*（3）为表yanshi_depart的DNAME建立一个规则@dname IN ('机电学院','信息学
院','工商学院')。*/
CREATE RULE dname_rule AS @dname IN ('机电学院','信息学院','工商学院');go
EXEC sp_bindrule 'dname_rule','yanshi_depart.dname';go

/*（4）为表yanshi_depart的DADDRESS建立一个规则@daddress LIKE
'[A-Z][1-9][1-9][1-9][1-9]'，限定DADDRESS的值只能由字母开头，后跟 4 个数字。*/

CREATE RULE daddress_rule AS @daddress LIKE '[A-Z][1-9][1-9][1-9][1-9]';go
EXEC sp_bindrule 'daddress_rule','yanshi_depart.daddress';go

/*（5） 删除第 3 小题所建立的规则。*/
EXEC sp_unbindrule 'yanshi_depart.dname';go
DROP RULE dname_rule;go