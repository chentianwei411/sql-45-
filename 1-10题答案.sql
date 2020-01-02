-- 1.查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
select student.*, a.sid, a.cid, a.score as "01", b.score as "02"
from sc a inner join sc b
on a.sid = b.sid and a.cid = '01' and b.cid = '02'
inner join student on student.sid = a.sid
where a.score > b.score;
-- +------+--------+---------------------+------+------+------+------+------+
-- | SId  | Sname  | Sage                | Ssex | sid  | cid  | 01   | 02   |
-- +------+--------+---------------------+------+------+------+------+------+
-- | 02   | 钱电   | 1990-12-21 00:00:00 | 男   | 02   | 01   | 70.0 | 60.0 |
-- | 04   | 李云   | 1990-08-06 00:00:00 | 男   | 04   | 01   | 50.0 | 30.0 |
-- +------+--------+---------------------+------+------+------+------+------+

-- 1.1
select a.sid, a.cid, a.score as '01', b.cid, b.score as '02'
from sc a inner join sc b on a.sid = b.sid
and a.cid = '01' and b.cid = '02';
-- +------+------+------+------+------+
-- | sid  | cid  | 01   | cid  | 02   |
-- +------+------+------+------+------+
-- | 01   | 01   | 80.0 | 02   | 90.0 |
-- | 02   | 01   | 70.0 | 02   | 60.0 |
-- | 03   | 01   | 80.0 | 02   | 80.0 |
-- | 04   | 01   | 50.0 | 02   | 30.0 |
-- | 05   | 01   | 76.0 | 02   | 87.0 |
-- +------+------+------+------+------+

-- 1.2
-- 主表是student，第一个内连接查询到上了01课的学生，第二个左连接附加02课程的成绩。
select a.sid, b.cid, b.score, c.cid ,c.score from Student as a
inner join SC as b on a.sid = b.sid and b.Cid = "01"
left join SC as c on a.sid = c.sid and c.Cid = "02"
-- +------+------+-------+------+-------+
-- | sid  | cid  | score | cid  | score |
-- +------+------+-------+------+-------+
-- | 01   | 01   |  80.0 | 02   |  90.0 |
-- | 02   | 01   |  70.0 | 02   |  60.0 |
-- | 03   | 01   |  80.0 | 02   |  80.0 |
-- | 04   | 01   |  50.0 | 02   |  30.0 |
-- | 05   | 01   |  76.0 | 02   |  87.0 |
-- | 06   | 01   |  31.0 | NULL |  NULL |
-- +------+------+-------+------+-------+

-- 1.3
select Student.*, sc.cid, sc.score from Student
inner join sc on sc.sid = Student.sid and sc.cid = '02'
where Student.sid not in (select sid from sc where cid = '01');
-- +------+--------+---------------------+------+------+-------+
-- | SId  | Sname  | Sage                | Ssex | cid  | score |
-- +------+--------+---------------------+------+------+-------+
-- | 07   | 郑竹   | 1989-07-01 00:00:00 | 女   | 02   |  89.0 |
-- +------+--------+---------------------+------+------+-------+

-- 2.查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select St.sid, St.Sname, cast(avg(sc.score) as decimal(5,2)) as avg_score from Student as St
inner join sc on St.sid = sc.sid
group by St.sid, St.Sname having avg_score >= 60;
-- +------+--------+-----------+
-- | sid  | Sname  | avg_score |
-- +------+--------+-----------+
-- | 01   | 赵雷   |     89.67 |
-- | 02   | 钱电   |     70.00 |
-- | 03   | 孙风   |     80.00 |
-- | 05   | 周梅   |     81.50 |
-- | 07   | 郑竹   |     93.50 |
-- +------+--------+-----------+

-- 3.查询在 SC 表存在成绩的学生信息
select Stu.sid from Student as Stu
where sid in (select distinct sid from sc);
-- +------+
-- | sid  |
-- +------+
-- | 01   |
-- | 02   |
-- | 03   |
-- | 04   |
-- | 05   |
-- | 06   |
-- | 07   |
-- +------+

-- 4.查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
select Stu.sid, Stu.sname, count(sc.cid) as total_course, sum(sc.score) as total_score
from Student as Stu left join sc on Stu.sid = sc.sid
group by Stu.sid, Stu.sname;

-- 4.1 查有成绩的学生信息
select * from Student where sid in (select sid from sc);
-- 使用exists，大数据下更高效
select * from Student where exists(select 1 from sc where sc.sid = Student.sid);

-- 5.查询「李」姓老师的数量
select count(Tname) from Teacher where Tname like '李%';

-- 6.查询学过「张三」老师授课的同学的信息
select Student.Sname from Teacher
inner join Course on Teacher.tid = Course.tid and Teacher.tname = "张三"
inner join SC on Course.cid = SC.cid
inner join Student on SC.sid = Student.sid;

-- 7.查询没有学全所有课程的同学的信息
select Student.Sname from Student
left join SC on SC.sid = Student.sid
group by Student.Sname
having count(sc.cid) < (select count(1) from Course);
-- +--------+  解题思路：
-- | Sname  |  1.主表是Student,通过它左连接SC表。把所有学生的成绩和学生信息连表。
-- +--------+  2.按照每个学生分组，计算每个学生有多少门成绩。
-- | 周梅   |   3. 筛选。使用子查询和having count()比较
-- | 吴兰   |
-- | 郑竹   |
-- | 张三   |
-- | 李四   |
-- | 赵六   |
-- | 孙七   |
-- +--------+

-- 8.查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
select distinct Student.sname from Student
left join SC on SC.sid = Student.sid
where SC.cid in(select cid from SC where sid = '01');
-- +--------+
-- | sname  |
-- +--------+
-- | 赵雷   |
-- | 钱电   |
-- | 孙风   |
-- | 李云   |
-- | 周梅   |
-- | 吴兰   |
-- | 郑竹   |
-- +--------+

-- 9.查询和" 01 "号的同学学习的课程 完全相同的其他同学的信息
-- 解题思路：
-- 1.教程里面给了一篇文章谈到大数据下，尽量不要使用复杂的嵌套子查询。不利于运行效率。
-- 2.基于这个事实，我的代码分成2条查询语句
-- 3.第一条查询到'01'号同学学习的课程。这里有2个知识点：
--   其中一个是教程里面已经提到：group_concat。
--   另一个是user-defined variable。所以可以使用@grou_c储存我们刚刚查询到的数据。
-- 4.第二条查询，
--   把Student左关联SC,然后剔除"01"号同学的记录。
--   然后分组，使用having条件语句，筛选出和"01"号同学的课程完全一样的学生。

select sid, @group_c := group_concat(cid) from sc group by sid having sid = "01";

select Student.Sname from student
left join SC on SC.sid = Student.sid and SC.sid <> "01"
group by Student.Sname
having group_concat(sc.cid) = @group_c;
-- +--------+
-- | Sname  |
-- +--------+
-- | 孙风   |
-- | 李云   |
-- | 钱电   |
-- +--------+

-- 10.查询没学过"张三"老师讲授的任一门课程的学生姓名
select Student.sid, Student.Sname from Student where sid not in (
  -- 先查询学过张三课程的学生的sid。
  select sid from SC
  inner join Course on Course.cid = SC.cid
  inner join Teacher on Teacher.tid = Course.tid and Teacher.tname = "张三"
);
-- +------+--------+
-- | sid  | Sname  |
-- +------+--------+
-- | 06   | 吴兰   |
-- | 09   | 张三   |
-- | 10   | 李四   |
-- | 11   | 李四   |
-- | 12   | 赵六   |
-- | 13   | 孙七   |
-- +------+--------+

-- 11.查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
select Student.sid, Student.sname, avg(score) from Student
inner join SC on SC.sid = Student.sid
