CREATE TABLE TrainSchedule(
Train_ID varchar,
Source varchar,
Destination varchar,
Distance integer,
Departure_Time time,
Arrival_Time time
);
copy TrainSchedule(Train_ID, Source, Destination, Distance, Departure_Time, Arrival_Time) from '/home/codebat/Documents/codes/col362/ass2/raildata20.csv' DELIMITER ',' CSV HEADER;