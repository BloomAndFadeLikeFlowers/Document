
1.查询成绩比该课程平均成绩低的学生成绩表 

	SELECT SNO,CNO,GRADE 
	FROM sc AS  a 
	WHERE GRADE< ( SELECT AVG(GRADE)   FROM sc  AS  b   WHERE  a.CNO=b.CNO ) 
	
	说明：主查询在判断每个待选行时，唤醒子查询，告诉它该学生选修的课程号，
	并由子查 询计算该课程的平均成绩，然后将该学生的成绩与平均成绩进行比较，
	找出符合条件的记 录，这种子查询称为相关子查询。 

2.查询选修了'线性代数'这门课程的学生学号 
	SELECT SNO,SNAME 
	FROM student  
	WHERE  EXISTS ( 
			SELECT *   
			FROM  sc  ,course    
			WHERE  sc.CNO=course.CNO  
				AND student.SNO=sc.SNO 
				AND  course.CNAME='线性代数' 
		) 
		
	说明：主查询在判断每个学生时，执行子查询，
	根据主查询中的当前行的学号，在子查询 中，从头到尾进行扫描，
	判断是否存在该学生的选课记录，如果存在这样的行，
	EXISTS 子句返回真，主查询选中当前行；
	如果子查询未找到这样的行，EXISTS 子句返回假，主 查询不选中当前行。 
 