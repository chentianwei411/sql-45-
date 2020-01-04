-- 13.按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
-- select sid, avg(score) as avg_score from SC group by sid order by avg_score desc;
select Student.*, sc_1.score as "01", sc_2.score as "02", sc_3.score as "03",
cast((ifnull(sc_1.score, 0)+ifnull(sc_2.score, 0)+ ifnull(sc_3.score, 0))/(if(sc_1.score, 1, 0)+if(sc_2.score, 1, 0)+if(sc_3.score, 1, 0)) as decimal(5,2))as avg_score
from Student
left join SC as sc_1 on sc_1.sid = Student.sid and sc_1.cid = "01"
left join SC as sc_2 on sc_2.sid = Student.sid and sc_2.cid = "02"
left join SC as sc_3 on sc_3.sid = Student.sid and sc_3.cid = "03"
order by avg_score desc;
-- 这样写的缺陷，如果有10门课，那就要写10行left join了。优点就是简明清晰，一看就懂。

-- 15.按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
-- 15.1 按各科成绩进行排序，并显示排名， Score 重复时合并名次

-- 16.查询学生的总成绩，并进行排名，总分重复时保留名次空缺
select sid, sum(score) from SC
group by sid
order by sum(score) desc

-- 参考（这个答案，有些丑陋，因为多了一列@sco := scos,这列只是计算用途。）
-- 问下老师，有没有更好的写法？
select
	s.*,
	case when @sco=scos then '' else @rank:=@rank+1 end as rn ,
	@sco:=scos
from
	(select sid,sum(score) as scos from sc group by sid order by scos desc) s,
	(select @rank:=0,@sco:=null) t
  -- +------+-------+------+------------+
  -- | sid  | scos  | rn   | @sco:=scos |
  -- +------+-------+------+------------+
  -- | 01   | 269.0 | 1    |      269.0 |
  -- | 03   | 240.0 | 2    |      240.0 |
  -- | 02   | 210.0 | 3    |      210.0 |
  -- | 07   | 187.0 | 4    |      187.0 |
  -- | 05   | 163.0 | 5    |      163.0 |
  -- | 04   | 100.0 | 6    |      100.0 |
  -- | 06   |  65.0 | 7    |       65.0 |
  -- +------+-------+------+------------+

-- 16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
-- 麻烦老师也对比着讲一下

-- 18.查询各科成绩前三名的记录
-- 不懂博客上的答案中 "< 3" 是怎么筛选查询结果的？下面是大石兄博客的答案：
select *
from sc
where  (select count(1) from sc as a where sc.CId =a.CId and  sc.score <a.score )<3
ORDER BY CId asc,sc.score desc

-- 35、查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
-- select t1.sid, t1.cid, t1.score from sc as t1
-- inner join sc as t2 on t1.sid = t2.sid
-- and t1.cid <> t2.cid and t1.score = t2.score
-- group by t1.sid, t1.cid,t1.score

-- 请老师讲解一下工作中是否常用exists这个关键字？？？
select *
from sc as t1
where exists(select * from sc as t2
        where t1.SId=t2.SId
        and t1.CId!=t2.CId
        and t1.score =t2.score )

-- 36.查询每门功成绩最好的前两名（和第18题一样）

-- 39、查询选修了全部课程的学生信息 (请老师讲解一下使用查询的效率问题，大石兄博客写的是一个复合语句)
select @count :=count(1) from Course;
select * from student
where sid in (select sid from SC group by sid having count(cid) = @count);
-- +------+--------+---------------------+------+
-- | SId  | Sname  | Sage                | Ssex |
-- +------+--------+---------------------+------+
-- | 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
-- | 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
-- | 03   | 孙风   | 1990-05-20 00:00:00 | 男   |
-- | 04   | 李云   | 1990-08-06 00:00:00 | 男   |
-- +------+--------+---------------------+------+
-- 👇是大石兄博客的答案：（我用show profiles比较，发现耗时时间较多）
-- select
-- *
-- from student a
-- where (select count(1) from sc b where a.sid=b.sid)
--     =(select count(1) from course)
