-- 16.查询学生的总成绩，并进行排名，总分重复时保留名次空缺
-- 问下老师，有没有更好的写法？可以用pandas和窗口函数
set @sco:=null,@rank=0;
select
	s.*,
	case when @sco=scos then '' else @rank:=@rank+1 end as rn ,
	@sco:=scos
from
	(select sid,sum(score) as scos from sc group by sid order by scos desc) s
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
-- 使用窗口函数rank(),保留空缺名次，本例看不出来，可参考第15题。
select *, rank() over (order by total desc) as rank1
from (
	select sc.sid, sum(sc.score) as total from sc group by sc.sid) q;
	-- +------+-------+-------+
	-- | sid  | total | rank1 |
	-- +------+-------+-------+
	-- | 01   | 269.0 |     1 |
	-- | 03   | 240.0 |     2 |
	-- | 02   | 210.0 |     3 |
	-- | 07   | 187.0 |     4 |
	-- | 05   | 163.0 |     5 |
	-- | 04   | 100.0 |     6 |
	-- | 06   |  65.0 |     7 |
	-- +------+-------+-------+
-- 16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺 （使用工厂函数）
select *, dense_rank() over (order by total desc) as rank1
from (
	select sc.sid, sum(sc.score) as total from sc group by sc.sid) q;

-- 17.统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
select SC.cid, Course.cname,
  sum(if(score >= 85, 1, 0))/count(1) as "100-85",
  sum(if(score >= 70 and score < 85, 1, 0))/count(1) as "85-70",
  sum(if(score >= 60 and score < 70, 1, 0))/count(1) as "70-60",
  sum(if(score < 60, 1, 0))/count(1) as "60-0"
from Course inner join SC on SC.cid = Course.cid
group by cid, cname;
-- +------+--------+--------+--------+--------+--------+
-- | cid  | cname  | 100-85 | 85-70  | 70-60  | 60-0   |
-- +------+--------+--------+--------+--------+--------+
-- | 01   | 语文   | 0.0000 | 0.6667 | 0.0000 | 0.3333 |
-- | 02   | 数学   | 0.5000 | 0.1667 | 0.1667 | 0.1667 |
-- | 03   | 英语   | 0.3333 | 0.3333 | 0.0000 | 0.3333 |
-- +------+--------+--------+--------+--------+--------+

-- 18.查询各科成绩前三名的记录 （用窗口函数）
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

-- 19.查询每门课程被选修的学生数
select cid, count(1) from SC
group by cid

-- 20.查询出只选修两门课程的学生学号和姓名
select Student.sid, Student.sname from Student
inner join SC on Student.sid = SC.sid
group by Student.sid,Student.sname
having count(SC.cid) = 2;
-- +------+--------+
-- | sid  | sname  |
-- +------+--------+
-- | 05   | 周梅   |
-- | 06   | 吴兰   |
-- | 07   | 郑竹   |
-- +------+--------+

-- 21.查询男生、女生人数
select ssex, count(1) from Student group by ssex;

-- 22.查询名字中含有「风」字的学生信息
select * from Student where sname like "%风%";
-- 如果sname 是索引字段时,'%风%'' 这样的写法不用到索引,'风%'这样的写法才会用到，真的工作中需要再考虑下了

-- 23.查询同名同性学生名单，并统计同名人数
--1 统计同名同性的学生名单
select Stu_a.* from Student as Stu_a
inner join Student as Stu_b on Stu_a.sname = Stu_b.sname and Stu_a.sid <> Stu_b.sid
and Stu_a.ssex = Stu_b.ssex;
-- 2 统计同名同姓人数
select Sname,ssex, count(*) from Student group by Sname, ssex having count(*) > 1 ;

-- 问题， 能否一个查询搞定？当然：
-- 1.使用Student表按照姓名和性别分组，并统计人数，这个查询结果为表t. 由此可知同名同性的每组的人数(大于1)。
with t as (select sname, ssex, count(1) as same_name from Student group by sname, ssex having same_name > 1)
-- +--------+------+----------+
-- | Sname  | ssex | count(*) |
-- +--------+------+----------+
-- | 李四   | 女   |        2 |
-- +--------+------+----------+
-- 2.然后，查出每个同名同性的人的详细信息。使用Student来连t表
select a.*, t.same_name from Student as a
inner join t on t.sname = a.sname and t.ssex = a.ssex
-- +------+--------+---------------------+------+--------+------+-----------+
-- | SId  | Sname  | Sage                | Ssex | sname  | ssex | same_name |
-- +------+--------+---------------------+------+--------+------+-----------+
-- | 10   | 李四   | 2017-12-25 00:00:00 | 女   | 李四   | 女   |         2 |
-- | 11   | 李四   | 2017-12-30 00:00:00 | 女   | 李四   | 女   |         2 |

-- 24.查询 1990 年出生的学生名单
select * from Student where year(sage) = 1990;
-- 优化，任何对列的操作都导致全表扫描，索引会失效
select * from Student where sage like '1990%'

-- 25.查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
-- +------+-----------+
-- | cid  | avg_score |
-- +------+-----------+
-- | 02   |     72.67 |
-- | 03   |     68.50 |
-- | 01   |     64.50 |
-- +------+-----------+

-- 26.查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
select Student.sid, Student.sname, s.avg_score from Student
inner join (
  select sid, avg(score) as avg_score from SC group by sid having avg_score >=85) as s
on s.sid = Student.sid;
-- +------+--------+-----------+
-- | sid  | sname  | avg_score |
-- +------+--------+-----------+
-- | 01   | 赵雷   |  89.66667 |
-- | 07   | 郑竹   |  93.50000 |
-- +------+--------+-----------+

-- 27、查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
-- 优化，使用join,where判断。
select Student.sname, SC.score from SC
inner join Student on Student.sid = SC.sid
inner join Course on Course.cid = SC.cid
where Course.cname = "数学" and SC.score < 60;
-- +--------+-------+
-- | sname  | score |
-- +--------+-------+
-- | 李云   |  30.0 |
-- +--------+-------+

-- 28.查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况)
select Student.*, Sc.cid, SC.score from Student
left join SC on Student.sid = SC.sid ;

-- 29、查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
select Student.sname, Course.cname, SC.score from Student
inner join SC on Student.sid = SC.sid and SC.score > 70
inner join Course on Course.cid = SC.cid

-- 30.查询不及格的课程(这道题没啥意义)
select * from SC where score < 60
-- 优化：以后不要有select * 的出现，一般公司中字段会50+或者更多，需要什么字段就select什么
select sid, cid, score from sc where score < 60

-- 31.查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名
select Student.sid, Student.sname from Student
inner join SC on SC.sid = Student.sid
and SC.cid = '01' and SC.score > 80;

-- 32、求每门课程的学生人数
select cid, count(1) from SC group by cid;

-- 33、假设成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
-- 34.假设成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
-- 最高成绩可能有多个:
select @max_score := max(score) from SC
inner join Course on Course.cid = SC.cid
inner join Teacher on Teacher.tid = Course.tid
where Teacher.tname = "张三";

select Student.sid, Student.sname, Student.sage, Student.ssex, SC.cid from SC
inner join Course on Course.cid = SC.cid
inner join Teacher on Teacher.tid = Course.tid
inner join Student on Student.sid = SC.sid
where Teacher.tname = "张三" and SC.score = @max_score;
-- +------+--------+---------------------+------+------+
-- | sid  | sname  | sage                | ssex | cid  |
-- +------+--------+---------------------+------+------+
-- | 01   | 赵雷   | 1990-01-01 00:00:00 | 男   | 02   |
-- +------+--------+---------------------+------+------+

-- 35、查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select t1.sid, t1.cid, t1.score from sc as t1
inner join sc as t2 on t1.sid = t2.sid
and t1.cid <> t2.cid and t1.score = t2.score
group by t1.sid, t1.cid,t1.score
-- 或者使用(但内存消耗比join大)
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

-- 36.查询每门功成绩最好的前两名
select sid, cid,score from (
	select *, rank() over (partition by cid order by score desc) as rank1 from sc) t
where rank1 <=2;
-- +------+------+-------+
-- | sid  | cid  | score |
-- +------+------+-------+
-- | 01   | 01   |  80.0 |
-- | 03   | 01   |  80.0 |
-- | 01   | 02   |  90.0 |
-- | 07   | 02   |  89.0 |
-- | 01   | 03   |  99.0 |
-- | 07   | 03   |  98.0 |
-- +------+------+-------+
-- 6 rows in set (0.01 sec)

-- 37.统计每门课程的学生选修人数（超过 5 人的课程才统计）
select cid, count(score) from SC
group by cid having count(score) > 5;

-- 38.检索至少选修两门课程的学生学号
select sid, count(1) as course from SC
group by sid having course >=2;

-- 39、查询选修了全部课程的学生信息
select @count :=count(1) from Course;
select st.sid, st.sname, st.sage from student st
inner join(
	select sid from SC group by sid having count(cid) = @count) t
on t.sid = st.sid
-- +------+--------+---------------------+------+
-- | SId  | Sname  | Sage                | Ssex |
-- +------+--------+---------------------+------+
-- | 01   | 赵雷   | 1990-01-01 00:00:00 | 男   |
-- | 02   | 钱电   | 1990-12-21 00:00:00 | 男   |
-- | 03   | 孙风   | 1990-05-20 00:00:00 | 男   |
-- | 04   | 李云   | 1990-08-06 00:00:00 | 男   |
-- +------+--------+---------------------+------+

-- 40.查询各学生的年龄，只按年份来算
select *, (year(now())-year(sage)) as age  from Student

-- 41.按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
select *,
if(date_format(now(), "%m-%d")< date_format(sage, '%m-%d'), year(now())-year(sage) -1, year(now())-year(sage)) as age
from Student
-- 也可以使用substring()函数

-- 42.查询本周过生日的学生
-- 大石兄的博客的答案，没有考虑闰年的问题
-- 回答：考虑闰年的话，需要使用pandas做。
select
*,
substr(YEARWEEK(student.Sage),5,2) as birth_week
substr(YEARWEEK(CURDATE()),5,2) as now_week
from student
where substr(YEARWEEK(student.Sage),5,2)=substr(YEARWEEK(CURDATE()),5,2);

-- 44.查询本月过生日的学生
-- select sid, sname, ssex, sage from Student where month(sage)=month(now());
-- where后不要对列使用函数,优化：
select @month := month(now());
select sid, sname, ssex, sage from Student where sage like concat("____-_",@month,"%");

-- 另外：mysql> select if(now()> "2019-1-11", "yes", 'no');
-- +-------------------------------------+
-- | if(now()> "2019-1-11", "yes", 'no') |
-- +-------------------------------------+
-- | yes                                 |
-- +-------------------------------------+

-- 45.查询下月过生日的学生
select @month := month(now())+1;
select sid, sname, ssex, sage from Student where sage like concat("____-0",@month,"%");
