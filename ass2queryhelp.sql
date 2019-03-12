CREATE TABLE TrainSchedule(
Train_ID varchar,
Source varchar,
Destination varchar,
Distance integer,
Departure_Time time,
Arrival_Time time
);
copy TrainSchedule(Train_ID, Source, Destination, Distance, Departure_Time, Arrival_Time) from '/home/codebat/Documents/codes/col362/ass2/raildata20.csv' DELIMITER ',' CSV HEADER;

copy TrainSchedule(Train_ID, Source, Destination, Distance, Departure_Time, Arrival_Time) from '/home/codebat/Documents/codes/col362/ass2/pdfraildata.csv' DELIMITER '|' CSV HEADER;


create view edge as select distinct Source, Destination from TrainSchedule;

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

create view path as 
WITH RECURSIVE Path (Source,Destination) AS
(SELECT Source, Destination
FROM TrainSchedule
UNION
SELECT TrainSchedule.Source, Path.Destination
FROM Path, TrainSchedule
WHERE TrainSchedule.Destination = Path.Source)
SELECT * FROM Path;



--NOT USED--
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
--NOT USED--