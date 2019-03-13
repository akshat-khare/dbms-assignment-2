--PREAMBLE--

create view edge as select distinct Source, Destination from TrainSchedule;
create view edgelessthanonehour as select distinct Source, Destination from TrainSchedule where Arrival_Time - Departure_Time<=interval '1' hour;

create view path as 
WITH RECURSIVE Path (Source,Destination) AS
(SELECT Source, Destination
FROM edge
UNION
SELECT edge.Source, Path.Destination
FROM Path, Edge
WHERE Edge.Destination = Path.Source)
SELECT * FROM Path;


create view pathq2hour as 
WITH RECURSIVE Path (Source,Destination, Departure_Time_Custom, Arrival_Time_Custom ) AS
(SELECT Source, Destination,Departure_Time as Departure_Time_Custom, Arrival_Time as Arrival_Time_Custom
FROM TrainSchedule
UNION
SELECT TrainSchedule.Source, Path.Destination, TrainSchedule.Departure_Time as Departure_Time_Custom, Path.Arrival_Time_Custom as Arrival_Time_Custom
FROM Path, TrainSchedule
WHERE TrainSchedule.Destination = Path.Source 
and 
(
    (
        Path.Departure_Time_Custom>=TrainSchedule.Arrival_Time 
        and 
        Path.Departure_Time_Custom-TrainSchedule.Arrival_Time <= interval '1' hour
    ) or 
    (
        Path.Departure_Time_Custom<TrainSchedule.Arrival_Time
        and 
        TrainSchedule.Arrival_Time - Path.Departure_Time_Custom >= time '23:00:00'

    )
    )
)
SELECT * FROM Path;

create view pathwithtimes as 
WITH RECURSIVE Path (Source,Destination, Departure_Time_Custom, Arrival_Time_Custom, TimeSpent) AS
(SELECT Source, Destination,Departure_Time as Departure_Time_Custom,Arrival_Time Arrival_Time_Custom,Arrival_Time-Departure_Time as TimeSpent 
FROM TrainSchedule
UNION
SELECT TrainSchedule.Source, Path.Destination, TrainSchedule.Departure_Time as Departure_Time_Custom, Path.Arrival_Time_Custom as Arrival_Time_Custom, 
(case when TrainSchedule.Arrival_Time<=Path.Departure_Time_Custom
then (Path.TimeSpent+(TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time)+ (Path.Departure_Time_Custom-TrainSchedule.Arrival_Time))
else (Path.TimeSpent+(TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time)+ (TrainSchedule.Arrival_Time-Path.Departure_Time_Custom))
end
) as TimeSpent
FROM Path, TrainSchedule
WHERE TrainSchedule.Destination = Path.Source
)
SELECT * FROM Path;

create view pathwincrlength as
WITH RECURSIVE Path (Source,Destination,TimeSpentLast) AS
(SELECT Source, Destination, Arrival_Time-Departure_Time as TimeSpentLast
FROM TrainSchedule
UNION
SELECT Path.Source, TrainSchedule.Destination, TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time as TimeSpentLast 
FROM Path, TrainSchedule
WHERE Path.Destination = TrainSchedule.Source and Path.TimeSpentLast<=(TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time))
SELECT * FROM Path;

create view pathalterdecr as 
WITH RECURSIVE Path (Source,Destination,TimeSpentLast,Ifcheck) AS
(SELECT Source, Destination, Arrival_Time-Departure_Time as TimeSpentLast, 1 as Ifcheck
FROM TrainSchedule
UNION
SELECT Path.Source, TrainSchedule.Destination, 
(case when Path.Ifcheck=0 then (TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time) else (Path.TimeSpentLast) end) as TimeSpentLast,
(case when Path.Ifcheck=1 then (0) else (1) end) as Ifcheck
FROM Path, TrainSchedule
WHERE Path.Destination = TrainSchedule.Source and (Path.Ifcheck=1 or (Path.Ifcheck=0 and (Path.TimeSpentLast>=(TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time)))) )
SELECT * FROM Path;


create view allcities as
select distinct city from
(
select distinct Source as city from TrainSchedule 
union 
select distinct Destination as city from TrainSchedule
) as citytab;

create view repeatedpath as
WITH RECURSIVE Path (Source,Destination) AS
(SELECT Source, Destination
FROM TrainSchedule
UNION ALL
SELECT TrainSchedule.Source, Path.Destination
FROM Path, TrainSchedule
WHERE TrainSchedule.Destination = Path.Source)
SELECT * FROM Path;

create view repeatedpathgroup as
select Source, Destination, count(*) as co from repeatedpath group by Source, Destination;

create view q10ans as 
select rep1.co*rep2.co as count from repeatedpathgroup as rep1, repeatedpathgroup as rep2 
where upper(rep1.Source)='DELHI' and upper(rep1.Destination) = 'BHOPAL' 
and upper(rep2.Source)='BHOPAL' and upper(rep2.Destination)='HYDERABAD';

--1--
select distinct Destination from path where upper(Source)='DELHI' order by Destination;

--2--
select distinct Destination from pathq2hour where upper(Source)='DELHI' order by Destination;

--3--
select min(TimeSpent) from pathwithtimes where upper(Source)='DELHI' and upper(Destination)='MUMBAI';

--4--
select distinct train_id from TrainSchedule 
where upper(Source)<>'DELHI' 
and 
Source not in (select distinct Destination from path where upper(Source)='DELHI');

--5--
select distinct Source, Destination from pathwincrlength order by Source;

--6--
select distinct Source, Destination from pathalterdecr order by Source;

--7--
select * from 
(
select city1.city as Source, city2.city as Destination from allcities as city1, allcities as city2 where city1.city<>city2.city
except
select distinct Source, Destination from path
) as alltab order by Source;

--8--
select count(*) as no_of_paths from repeatedpath where upper(Source)='DELHI' and upper(Destination)='MUMBAI';

--9--
select Destination as cities_havingexactly_onepath from repeatedpathgroup where upper(Source)='DELHI' and co=1 order by Destination;

--10--
select 
(case when ((select count(*) from q10ans)=0) then (0) else (select count(*) from q10ans) end) as count;

--CLEANUP--
drop view q10ans cascade;
drop view repeatedpathgroup cascade;
drop view repeatedpath cascade;
drop view allcities cascade;
drop view pathalterdecr cascade;
drop view pathwincrlength cascade;
drop view pathwithtimes cascade;
drop view pathq2hour cascade;
drop view path cascade;
drop view edgelessthanonehour cascade;
drop view edge cascade;