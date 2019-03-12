--PREAMBLE--

create view cs1160315_paperidcount as select PaperId, count(PaperId) as co from paperByAuthors group by PaperId order by co desc, PaperId;
create view cs1160315_morethan20authors as select PaperId from cs1160315_paperidcount where co > 20;

create view cs1160315_allauthorid as select distinct AuthorId from PaperByAuthors;
create view cs1160315_soleauthorpaper as select PaperId from cs1160315_paperidcount where co=1;
create view cs1160315_authorwhohavesolepapers as select distinct AuthorId from cs1160315_soleauthorpaper, PaperByAuthors where cs1160315_soleauthorpaper.paperid = PaperByAuthors.paperid;
create view cs1160315_targetauthoridq4 as select * from cs1160315_allauthorid except select * from cs1160315_authorwhohavesolepapers;

create view cs1160315_authoridcount as select authorid, count(authorid) as co from paperbyauthors group by authorid order by co desc;
create view cs1160315_top20authorid as select * from cs1160315_authoridcount limit 20;

create view cs1160315_soleauthorpaperwithcount as select AuthorId, count(authorid) as co from cs1160315_soleauthorpaper, PaperByAuthors where cs1160315_soleauthorpaper.paperid = PaperByAuthors.paperid group by authorid order by co desc;
create view cs1160315_targetqueryq6 as select authorid from cs1160315_soleauthorpaperwithcount where co>50;

create view cs1160315_paperjvenue as select paper.paperid, paper.venueid, venue.type from paper, venue where paper.venueid = venue.venueid;
create view cs1160315_journalpapers as select paperid from cs1160315_paperjvenue where type='journals';
create view cs1160315_journalauthors as select distinct authorid from cs1160315_journalpapers ,paperbyauthors where cs1160315_journalpapers.paperid = paperbyauthors.paperid;
create view cs1160315_targetqueryq7 as select * from cs1160315_allauthorid except select * from cs1160315_journalauthors;


create view cs1160315_authorjpaperjvenue as select paperbyauthors.authorid, cs1160315_paperjvenue.paperid, cs1160315_paperjvenue.venueid, cs1160315_paperjvenue.type from paperbyauthors cross join cs1160315_paperjvenue where paperbyauthors.paperid = cs1160315_paperjvenue.paperid;
create view cs1160315_journalauthorid as select distinct authorid from cs1160315_authorjpaperjvenue where type='journals';
create view cs1160315_nonjournalauthorid as select distinct authorid from cs1160315_authorjpaperjvenue where type!='journals';
create view cs1160315_onlyjournalauthorid as select * from cs1160315_journalauthorid except select * from cs1160315_nonjournalauthorid;

create view cs1160315_authoridjpaperayear as select paperByAuthors.authorid, paper.paperid, paper.year from paperbyauthors cross join paper where paperbyauthors.paperid=paper.paperid;
create view cs1160315_authorpaperyearcount as select authorid, year, count(paperid) as co from cs1160315_authoridjpaperayear group by authorid, year;
create view cs1160315_targetqueryq9 as select distinct authorid from cs1160315_authorpaperyearcount where year=2012 and co>1 intersect select distinct authorid from cs1160315_authorpaperyearcount where year=2013 and co>2;

create view cs1160315_paperjvenueaname as select paper.paperid, paper.venueid, venue.type, venue.name from paper, venue where paper.venueid = venue.venueid;
create view cs1160315_authorjpaperjvenueaname as select paperbyauthors.authorid, cs1160315_paperjvenueaname.paperid, cs1160315_paperjvenueaname.venueid, cs1160315_paperjvenueaname.type, cs1160315_paperjvenueaname.name from paperbyauthors cross join cs1160315_paperjvenueaname where paperbyauthors.paperid = cs1160315_paperjvenueaname.paperid;
create view cs1160315_corrjournal as select * from cs1160315_authorjpaperjvenueaname where type='journals' and name='corr';
create view cs1160315_targetqueryq10 as select authorid, count(authorid) as co from cs1160315_corrjournal group by authorid order by co desc limit 20;

create view cs1160315_amcjournal as select * from cs1160315_authorjpaperjvenueaname where type='journals' and name='amc';
create view cs1160315_targetqueryq11interim as select authorid, count(authorid) as co from cs1160315_amcjournal group by authorid;
create view cs1160315_targetqueryq11 as select * from cs1160315_targetqueryq11interim where co>3;

create view cs1160315_ieicetjournal as select * from cs1160315_authorjpaperjvenueaname where type='journals' and name='ieicet';
create view cs1160315_ieicetcount as select authorid, count(authorid) as co from cs1160315_ieicetjournal group by authorid;
create view cs1160315_targetieicet as select authorid from cs1160315_ieicetcount where co>9;
create view cs1160315_tcsjournal as select * from cs1160315_authorjpaperjvenueaname where type='journals' and name='tcs';
create view cs1160315_targettcs as select distinct authorid from cs1160315_tcsjournal;
create view cs1160315_targetqueryq12 as select * from cs1160315_targetieicet except select * from cs1160315_targettcs;


create view cs1160315_queryopti as select paperid from paper where upper(title) like '%QUERY%OPTIMIZATION%';
create view cs1160315_targetqueryq14 as select distinct authorid from paperbyauthors cross join cs1160315_queryopti where paperbyauthors.paperid=cs1160315_queryopti.paperid;

create view cs1160315_citationcount as select paper2id, count(paper2id) as co from citation group by paper2id;
create view cs1160315_beingcitedcount as select paper1id, count(paper1id) as co from citation group by paper1id;
create view cs1160315_leftoutercit as select paper2id, cs1160315_citationcount.co as co2, paper1id, cs1160315_beingcitedcount.co as co1 from cs1160315_citationcount left outer join cs1160315_beingcitedcount on cs1160315_citationcount.paper2id=cs1160315_beingcitedcount.paper1id;
create view cs1160315_targetqueryq17 as select paper2id from cs1160315_leftoutercit where (co2>co1+9) or (paper1id is null and co2 > 9);
create view cs1160315_leftoutercitbackup as select paper2id, cs1160315_citationcount.co as co2, paper1id, cs1160315_beingcitedcount.co as co1 from cs1160315_citationcount, cs1160315_beingcitedcount where cs1160315_citationcount.paper2id=cs1160315_beingcitedcount.paper1id;
create view cs1160315_targetqueryq17backup as select paper2id from cs1160315_leftoutercitbackup where (co2>co1+9);

create view cs1160315_noncited as select paperid from paper except select distinct paper2id as paperid from citation;
create view cs1160315_alltitlesq18 as select distinct title from paper;
create view cs1160315_citedpaperidq18 as select distinct paper2id as paperid from citation;
create view cs1160315_citedpapertitleq18 as select distinct title from cs1160315_citedpaperidq18, paper where cs1160315_citedpaperidq18.paperid=paper.paperid;
create view cs1160315_finansq18 as select * from cs1160315_alltitlesq18 except select * from cs1160315_citedpapertitleq18;


create view cs1160315_authcite as select paperbyauthors.authorid as author1, paper1id, paper2id from paperbyauthors cross join citation where paperbyauthors.paperid = citation.paper1id;
create view cs1160315_authciteauth as select author1, paper1id, paper2id, paperbyauthors.authorid as author2 from cs1160315_authcite cross join paperbyauthors where cs1160315_authcite.paper2id=paperbyauthors.paperid;
create view cs1160315_targetauthoridq19 as select distinct author1 as author from cs1160315_authciteauth where author1=author2 and paper1id!=paper2id;

create view cs1160315_paperjvenueanameayear as select paper.paperid, paper.year, paper.venueid, venue.name, venue.type from paper cross join venue where paper.venueid=venue.venueid;
create view cs1160315_authorjpaperjvenueanameayear as select paperbyauthors.authorid, paperbyauthors.paperid, cs1160315_paperjvenueanameayear.year, cs1160315_paperjvenueanameayear.venueid, cs1160315_paperjvenueanameayear.name, cs1160315_paperjvenueanameayear.type from paperbyauthors cross join cs1160315_paperjvenueanameayear where paperbyauthors.paperid=cs1160315_paperjvenueanameayear.paperid;
create view cs1160315_targetqueryq20 as select distinct authorid from cs1160315_authorjpaperjvenueanameayear where type='journals' and name='corr' and year>2008 and year < 2014 except select distinct authorid from cs1160315_authorjpaperjvenueanameayear where type='journals' and name='ieicet' and year=2009;

create view cs1160315_journalcountyear as select name, year, count(name) as co from cs1160315_paperjvenueanameayear where year>2008 and year < 2014 and type='journals' group by name, year;
create view cs1160315_y13_12 as select tab2013.name as name, tab2013.year as y2013, tab2013.co as co2013, tab2012.year as y2012, tab2012.co as co2012 from cs1160315_journalcountyear as tab2013, cs1160315_journalcountyear as tab2012 where tab2013.year=2013 and tab2012.year=2012 and tab2013.co>=tab2012.co and tab2013.name=tab2012.name;
create view cs1160315_y12_11 as select tab2012.name as name, tab2012.year as y2012, tab2012.co as co2012, tab2011.year as y2011, tab2011.co as co2011 from cs1160315_journalcountyear as tab2012, cs1160315_journalcountyear as tab2011 where tab2012.year=2012 and tab2011.year=2011 and tab2012.co>=tab2011.co and tab2012.name=tab2011.name;
create view cs1160315_y11_10 as select tab2011.name as name, tab2011.year as y2011, tab2011.co as co2011, tab2010.year as y2010, tab2010.co as co2010 from cs1160315_journalcountyear as tab2011, cs1160315_journalcountyear as tab2010 where tab2011.year=2011 and tab2010.year=2010 and tab2011.co>=tab2010.co and tab2011.name=tab2010.name;
create view cs1160315_y10_09 as select tab2010.name as name, tab2010.year as y2010, tab2010.co as co2010, tab2009.year as y2009, tab2009.co as co2009 from cs1160315_journalcountyear as tab2010, cs1160315_journalcountyear as tab2009 where tab2010.year=2010 and tab2009.year=2009 and tab2010.co>=tab2009.co and tab2010.name=tab2009.name;
create view cs1160315_y10_09addon as select distinct name from cs1160315_journalcountyear where year=2010 except select distinct name from cs1160315_journalcountyear where year=2009;
create view cs1160315_y10_09total as select distinct name from cs1160315_y10_09 union select distinct name from cs1160315_y10_09addon;
create view cs1160315_targetqueryq21 as select distinct name from cs1160315_y13_12 intersect select distinct name from cs1160315_y12_11 intersect select distinct name from cs1160315_y11_10 intersect select distinct name from cs1160315_y10_09 order by name; 

create view cs1160315_journalcountyearall as select name, year, count(name) as co from cs1160315_paperjvenueanameayear where type='journals' group by name, year;

create view cs1160315_authorjournal as select authorid, name , count(*) as co from cs1160315_authorjpaperjvenueaname where type='journals' group by authorid, name;
create view cs1160315_maxcojournal as select name, max(co) from cs1160315_authorjournal group by name;
create view cs1160315_targetqueryq23 as select cs1160315_authorjournal.name, authorid from cs1160315_authorjournal, cs1160315_maxcojournal where co=max and cs1160315_authorjournal.name=cs1160315_maxcojournal.name;

create view cs1160315_paperjvenueq24 as select paper.paperid, paper.year, venue.name from paper cross join venue where paper.venueid=venue.venueid and paper.year>2006 and paper.year<2010 and venue.type='journals';
create view cs1160315_journcite as select cs1160315_paperjvenueq24.paperid as paper1id, cs1160315_paperjvenueq24.year as paper1year, cs1160315_paperjvenueq24.name as paper1name, citation.paper2id as paper2id from cs1160315_paperjvenueq24, citation where cs1160315_paperjvenueq24.paperid=citation.paper1id;
create view cs1160315_journcitejourn as select cs1160315_journcite.paper1id, cs1160315_journcite.paper1year, cs1160315_journcite.paper1name, cs1160315_journcite.paper2id as paper2id, cs1160315_paperjvenueq24.year as paper2year, cs1160315_paperjvenueq24.name as paper2name from cs1160315_journcite, cs1160315_paperjvenueq24 where cs1160315_journcite.paper2id=cs1160315_paperjvenueq24.paperid;
create view cs1160315_cittable as select paper2name as citpapername, count(paper2name) as citco from cs1160315_journcitejourn where (paper2year=2007 or paper2year=2008) and paper1year=2009 group by paper2name;
create view cs1160315_pubtable as select name as pubpapername, count(name) as pubco from cs1160315_paperjvenueq24 where cs1160315_paperjvenueq24.year=2007 or cs1160315_paperjvenueq24.year=2008 group by name;
create view cs1160315_havetable as select cs1160315_pubtable.pubpapername as name, cast(citco as float)/cast(pubco as float) as co from cs1160315_pubtable, cs1160315_cittable where pubpapername=citpapername;
create view cs1160315_nottableinterim as select pubpapername as name from cs1160315_pubtable except select citpapername as name from cs1160315_cittable; 
create view cs1160315_notable as select name, cast(0 as float) as co from cs1160315_nottableinterim;
create view cs1160315_targetqueryq24 as select * from cs1160315_havetable union select * from cs1160315_notable;

create view cs1160315_papercitcount as select paper2id as paperid, count(paper2id) as co from citation group by paper2id;
create view cs1160315_authoridjcitcount as select authorid, paperbyauthors.paperid, co from paperbyauthors, cs1160315_papercitcount where paperbyauthors.paperid=cs1160315_papercitcount.paperid;
create view cs1160315_addedrow as select row_number() over (partition by authorid order by co desc), authorid, paperid, co from cs1160315_authoridjcitcount;
create view cs1160315_curbrow as select * from cs1160315_addedrow where row_number<=co order by authorid, co desc;
create view cs1160315_authoridhindex as select authorid, max(row_number) from cs1160315_curbrow group by authorid;
create view cs1160315_zeroauthors as select distinct authorid from author except select authorid from cs1160315_authoridhindex;
create view cs1160315_finauthoridhindex as select authorid, 0 as max from cs1160315_zeroauthors union select * from cs1160315_authoridhindex;


--1--
select type, count(type) as co from cs1160315_paperjvenue group by type order by co desc, type;

--2--
select avg(co) from cs1160315_paperidcount;

--3--
select distinct Title from cs1160315_morethan20authors, Paper where cs1160315_morethan20authors.Paperid = Paper.Paperid order by Title;

--4--
select name from cs1160315_targetauthoridq4, author where cs1160315_targetauthoridq4.authorid = author.authorid order by name;

--5--
select name from cs1160315_top20authorid, author where cs1160315_top20authorid.authorid = author.authorid order by co desc, name;

--6--
select name from cs1160315_targetqueryq6, author where cs1160315_targetqueryq6.authorid = author.authorid order by name;

--7--
select name from author, cs1160315_targetqueryq7 where author.authorid = cs1160315_targetqueryq7.authorid order by name;

--8--
select name from cs1160315_onlyjournalauthorid cross join author where cs1160315_onlyjournalauthorid.authorid=author.authorid order by name;

--9--
select name from cs1160315_targetqueryq9 cross join author where cs1160315_targetqueryq9.authorid = author.authorid order by name;

--10--
select name from cs1160315_targetqueryq10, author where cs1160315_targetqueryq10.authorid= author.authorid order by co desc, name;

--11--
select name from cs1160315_targetqueryq11, author where cs1160315_targetqueryq11.authorid=author.authorid order by name;

--12--
select name from cs1160315_targetqueryq12, author where cs1160315_targetqueryq12.authorid=author.authorid order by name;

--13--
select year, count(year) as co from paper where year>2003 and year<2014 group by year order by year;

--14--
select count(authorid) from cs1160315_targetqueryq14;

--15--
select title from cs1160315_citationcount, paper where cs1160315_citationcount.paper2id=paper.paperid order by co desc, title;

--16--
select distinct title from cs1160315_citationcount, paper where cs1160315_citationcount.paper2id=paper.paperid and co>10 order by title;

--17--
select distinct title from cs1160315_targetqueryq17backup, paper where paper.paperid=cs1160315_targetqueryq17backup.paper2id order by title;

--18--
select distinct title from cs1160315_finansq18 order by title;

--19--
select name from cs1160315_targetauthoridq19, author where cs1160315_targetauthoridq19.author=author.authorid order by name;

--20--
select name from cs1160315_targetqueryq20, author where cs1160315_targetqueryq20.authorid=author.authorid order by name;

--21--
select * from cs1160315_targetqueryq21;

--22--
select name, year from cs1160315_journalcountyearall where co=(select max(co) from cs1160315_journalcountyearall) order by year, name;

--23--
select cs1160315_targetqueryq23.name as journalname, author.name as authorname from author, cs1160315_targetqueryq23 where author.authorid=cs1160315_targetqueryq23.authorid order by journalname, authorname;

--24--
select * from cs1160315_targetqueryq24 order by co desc, name;

--25--
select name, max as hindex from author, cs1160315_authoridhindex where author.authorid=cs1160315_authoridhindex.authorid order by hindex desc, name;

--CLEANUP--
drop view cs1160315_finauthoridhindex cascade;
drop view cs1160315_zeroauthors cascade;
drop view cs1160315_authoridhindex cascade;
drop view cs1160315_curbrow cascade;
drop view cs1160315_addedrow cascade;
drop view cs1160315_authoridjcitcount cascade;
drop view cs1160315_papercitcount cascade;
drop view cs1160315_targetqueryq24 cascade;
drop view cs1160315_notable cascade;
drop view cs1160315_nottableinterim cascade;
drop view cs1160315_havetable cascade;
drop view cs1160315_pubtable cascade;
drop view cs1160315_cittable cascade;
drop view cs1160315_journcitejourn cascade;
drop view cs1160315_journcite cascade;
drop view cs1160315_paperjvenueq24 cascade;
drop view cs1160315_targetqueryq23 cascade;
drop view cs1160315_maxcojournal cascade;
drop view cs1160315_authorjournal cascade;
drop view cs1160315_journalcountyearall cascade;
drop view cs1160315_targetqueryq21 cascade;
drop view cs1160315_y10_09total cascade;
drop view cs1160315_y10_09addon cascade;
drop view cs1160315_y10_09 cascade;
drop view cs1160315_y11_10 cascade;
drop view cs1160315_y12_11 cascade;
drop view cs1160315_y13_12 cascade;
drop view cs1160315_journalcountyear cascade;
drop view cs1160315_targetqueryq20 cascade;
drop view cs1160315_authorjpaperjvenueanameayear cascade;
drop view cs1160315_paperjvenueanameayear cascade;
drop view cs1160315_targetauthoridq19 cascade;
drop view cs1160315_authciteauth cascade;
drop view cs1160315_authcite cascade;
drop view cs1160315_finansq18 cascade;
drop view cs1160315_citedpapertitleq18 cascade;
drop view cs1160315_citedpaperidq18 cascade;
drop view cs1160315_alltitlesq18 cascade;
drop view cs1160315_noncited cascade;
drop view cs1160315_targetqueryq17backup cascade;
drop view cs1160315_leftoutercitbackup cascade;
drop view cs1160315_targetqueryq17 cascade;
drop view cs1160315_leftoutercit cascade;
drop view cs1160315_beingcitedcount cascade;
drop view cs1160315_citationcount cascade;
drop view cs1160315_targetqueryq14 cascade;
drop view cs1160315_queryopti cascade;
drop view cs1160315_targetqueryq12 cascade;
drop view cs1160315_targettcs cascade;
drop view cs1160315_tcsjournal cascade;
drop view cs1160315_targetieicet cascade;
drop view cs1160315_ieicetcount cascade;
drop view cs1160315_ieicetjournal cascade;
drop view cs1160315_targetqueryq11 cascade;
drop view cs1160315_targetqueryq11interim cascade;
drop view cs1160315_amcjournal cascade;
drop view cs1160315_targetqueryq10 cascade;
drop view cs1160315_corrjournal cascade;
drop view cs1160315_authorjpaperjvenueaname cascade;
drop view cs1160315_paperjvenueaname cascade;
drop view cs1160315_targetqueryq9 cascade;
drop view cs1160315_authorpaperyearcount cascade;
drop view cs1160315_authoridjpaperayear cascade;
drop view cs1160315_onlyjournalauthorid cascade;
drop view cs1160315_nonjournalauthorid cascade;
drop view cs1160315_journalauthorid cascade;
drop view cs1160315_authorjpaperjvenue cascade;
drop view cs1160315_targetqueryq7 cascade;
drop view cs1160315_journalauthors cascade;
drop view cs1160315_journalpapers cascade;
drop view cs1160315_paperjvenue cascade;
drop view cs1160315_targetqueryq6 cascade;
drop view cs1160315_soleauthorpaperwithcount cascade;
drop view cs1160315_top20authorid cascade;
drop view cs1160315_authoridcount cascade;
drop view cs1160315_targetauthoridq4 cascade;
drop view cs1160315_authorwhohavesolepapers cascade;
drop view cs1160315_soleauthorpaper cascade;
drop view cs1160315_allauthorid cascade;
drop view cs1160315_morethan20authors cascade;
drop view cs1160315_paperidcount cascade;


CREATE OR REPLACE FUNCTION auditlogfunc() RETURNS TRIGGER AS $example_table$
   BEGIN
      INSERT INTO AUDIT(EMP_ID, ENTRY_DATE) VALUES (new.ID, current_timestamp);
      RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER example_trigger AFTER INSERT ON COMPANY
FOR EACH ROW EXECUTE PROCEDURE auditlogfunc();

CREATE OR REPLACE FUNCTION test()
  RETURNS trigger AS
$$
BEGIN
         INSERT INTO attendancedata
         VALUES(100,550,NEW.cnadidate_name,15,2,NEW.state_name,NEW.pc_name,0,0);
 
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';
CREATE TRIGGER test_trigger
  AFTER INSERT
  ON ls2009candi
  EXECUTE PROCEDURE test();