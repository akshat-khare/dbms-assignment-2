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


create view pathdetail as
WITH RECURSIVE Path (Source,Destination, TimeSpent, Distance) AS
(SELECT Source, Destination, Arrival_Time - Departure_Time as TimeSpent, Distance
FROM TrainSchedule
UNION
SELECT TrainSchedule.Source, Path.Destination, Path.TimeSpent + TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time as TimeSpent, Path.Distance + TrainSchedule.Distance as Distance
FROM Path, TrainSchedule
WHERE TrainSchedule.Destination = Path.Source)
SELECT * FROM Path;

create view pathq2 as 
WITH RECURSIVE Path (Source,Destination) AS
(SELECT Source, Destination
FROM edgelessthanonehour
UNION
SELECT edgelessthanonehour.Source, Path.Destination
FROM Path, edgelessthanonehour
WHERE edgelessthanonehour.Destination = Path.Source)
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
WHERE Path.Destination = TrainSchedule.Source and Path.TimeSpentLast<(TrainSchedule.Arrival_Time-TrainSchedule.Departure_Time))
SELECT * FROM Path;

--1--
select distinct Destination from path where upper(Source)='DELHI' order by Destination;
--2--
select distinct Destination from pathq2hour where upper(Source)='DELHI' order by Destination;
--3--
select min(TimeSpent) from pathwithtimes where upper(Source)='DELHI';
--4--
select distinct train_id from TrainSchedule 
where upper(Source)<>'DELHI' 
and 
Source not in (select distinct Destination from path where upper(Source)='DELHI');
--5--
select distinct Source, Destination from pathwincrlength order by Source;
--6--

