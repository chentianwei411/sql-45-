-- 13.按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
-- select sid, avg(score) as avg_score from SC group by sid order by avg_score desc;
-- select Student.*, sc_1.score as "01", sc_2.score as "02", sc_3.score as "03",
-- cast((ifnull(sc_1.score, 0)+ifnull(sc_2.score, 0)+ ifnull(sc_3.score, 0))/(if(sc_1.score, 1, 0)+if(sc_2.score, 1, 0)+if(sc_3.score, 1, 0)) as decimal(5,2))as avg_score
-- from Student
-- left join SC as sc_1 on sc_1.sid = Student.sid and sc_1.cid = "01"
-- left join SC as sc_2 on sc_2.sid = Student.sid and sc_2.cid = "02"
-- left join SC as sc_3 on sc_3.sid = Student.sid and sc_3.cid = "03"
-- order by avg_score desc;
-- 这样写的缺陷，如果有10门课，那就要写10行left join了。优点就是简明清晰，一看就懂。
-- 下面的写法很简单
-- 1. 算平均成绩的表
-- 2. 然后和sc原表关联即可
select sc.*,t1.avgscore from  sc
left join (
	select sc.SId,avg(sc.score) as avgscore from sc GROUP BY sc.SId) as t1
on sc.SId =t1.SId
ORDER BY t1.avgscore DESC

-- 15.按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
select *, rank() over(partition by cid order by score desc) as '排名'
from SC
-- +------+------+-------+--------+
-- | SId  | CId  | score | 排名   |
-- +------+------+-------+--------+
-- | 01   | 01   |  80.0 |      1 |
-- | 03   | 01   |  80.0 |      1 |
-- | 05   | 01   |  76.0 |      3 |
-- | 02   | 01   |  70.0 |      4 |
-- | 04   | 01   |  50.0 |      5 |
-- | 06   | 01   |  31.0 |      6 |
-- | 01   | 02   |  90.0 |      1 |
-- | 07   | 02   |  89.0 |      2 |
-- | 05   | 02   |  87.0 |      3 |
-- | 03   | 02   |  80.0 |      4 |
-- | 02   | 02   |  60.0 |      5 |
-- | 04   | 02   |  30.0 |      6 |
-- | 01   | 03   |  99.0 |      1 |
-- | 07   | 03   |  98.0 |      2 |
-- | 02   | 03   |  80.0 |      3 |
-- | 03   | 03   |  80.0 |      3 |
-- | 06   | 03   |  34.0 |      5 |
-- | 04   | 03   |  20.0 |      6 |
-- +------+------+-------+--------+

-- 15.1 按各科成绩进行排序，并显示排名， Score 重复时合并名次
select *, dense_rank() over(partition by cid order by score desc) as '排名'
from SC
-- +------+------+-------+--------+
-- | SId  | CId  | score | 排名   |
-- +------+------+-------+--------+
-- | 01   | 01   |  80.0 |      1 |
-- | 03   | 01   |  80.0 |      1 |
-- | 05   | 01   |  76.0 |      2 |
-- | 02   | 01   |  70.0 |      3 |
-- | 04   | 01   |  50.0 |      4 |
-- | 06   | 01   |  31.0 |      5 |
-- | 01   | 02   |  90.0 |      1 |
-- | 07   | 02   |  89.0 |      2 |
-- | 05   | 02   |  87.0 |      3 |
-- | 03   | 02   |  80.0 |      4 |
-- | 02   | 02   |  60.0 |      5 |
-- | 04   | 02   |  30.0 |      6 |
-- | 01   | 03   |  99.0 |      1 |
-- | 07   | 03   |  98.0 |      2 |
-- | 02   | 03   |  80.0 |      3 |
-- | 03   | 03   |  80.0 |      3 |
-- | 06   | 03   |  34.0 |      4 |
-- | 04   | 03   |  20.0 |      5 |
-- +------+------+-------+--------+


-- 16.查询学生的总成绩，并进行排名，总分重复时保留名次空缺
select sid, sum(score) from SC
group by sid
order by sum(score) desc  --没有排名，所以对它进行一下排名。
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
set @sco:=null,@rank=0;
select q.sid, scos,
case when @sco=scos then '' else @rank:=@rank+1 end as rn,
@sco:=scos
from(
	select sc.sid, sum(sc.score) as scos from sc
	group by sc.sid
	order by scos desc) q;

-- 16.1查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
set @crank=0;
select q.sid, total, @crank := @crank +1 as rn from(
	select sc.sid, sum(sc.score) as total from sc
	group by sc.sid
	order by total desc)q;

-- 备注⚠️ 也可以使用Mysql8.0版本的窗口函数。
-- 1.有重复排名使用 dense_rank(),假如有并列第3名的2个学生，那么再下一个学生的排名是第4名
select *, dense_rank() over (order by total desc) as rank1
from (
	select sc.sid, sum(sc.score) as total from sc group by sc.sid) q;
-- 2. 仅仅简单的排序，忽略重复使用row_number()
-- 3.使用rank(), 即有重复排名，并且设置间隔/保留空缺，即假如有并列第3的2个学生，那么再下一个学生的排名是第5名。

-- 18.查询各科成绩前三名的记录
-- 不懂博客上的答案中 "< 3" 是怎么筛选查询结果的？下面是大石兄博客的答案：
-- select *
-- from sc
-- where  (select count(1) from sc as a where sc.CId =a.CId and  sc.score <a.score )<3
-- ORDER BY CId asc,sc.score desc
-- 改用窗口函数:
select * from (
	select * , dense_rank() over (partition by cid order by score desc) as rank1 from sc) t
where rank1 <= 3;
-- 解释：over()内部不能用limit子句，所以再用select子句包裹一下，然后加个where子句。
-- +------+------+-------+-------+
-- | SId  | CId  | score | rank1 |
-- +------+------+-------+-------+
-- | 01   | 01   |  80.0 |     1 |
-- | 03   | 01   |  80.0 |     1 |
-- | 05   | 01   |  76.0 |     2 |
-- | 02   | 01   |  70.0 |     3 |
-- | 01   | 02   |  90.0 |     1 |
-- | 07   | 02   |  89.0 |     2 |
-- | 05   | 02   |  87.0 |     3 |
-- | 01   | 03   |  99.0 |     1 |
-- | 07   | 03   |  98.0 |     2 |
-- | 02   | 03   |  80.0 |     3 |
-- | 03   | 03   |  80.0 |     3 |
-- +------+------+-------+-------+
-- 11 rows in set (0.00 sec)


-- 35、查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select t1.sid, t1.cid, t1.score from sc as t1
inner join sc as t2 on t1.sid = t2.sid
and t1.cid <> t2.cid and t1.score = t2.score
group by t1.sid, t1.cid,t1.score

-- 推荐使用join，消耗内存少。
select *
from sc as t1
where exists(select * from sc as t2
        where t1.SId=t2.SId
        and t1.CId!=t2.CId
        and t1.score =t2.score )
-- +------+------+-------+
-- | SId  | CId  | score |
-- +------+------+-------+
-- | 03   | 02   |  80.0 |
-- | 03   | 03   |  80.0 |
-- | 03   | 01   |  80.0 |
-- +------+------+-------+

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
-- 回答：https://www.jianshu.com/p/cf3fe3990d66 参考这篇提高效率的文章。

-- 42.查询本周过生日的学生
-- 大石兄的博客的答案，没有考虑闰年的问题
-- 回答：考虑闰年的话，需要使用pandas做。
select
*,
substr(YEARWEEK(student.Sage),5,2) as birth_week
substr(YEARWEEK(CURDATE()),5,2) as now_week
from student
where substr(YEARWEEK(student.Sage),5,2)=substr(YEARWEEK(CURDATE()),5,2);
