#Author:Huajing Lu,Yisong Cheng
library(RMySQL)     ### MySQL

#Initial settings
db_user <- 'root'
db_password <- 'cerf0312*'
db_name <- 'Journal'

db_host <- 'localhost' 
db_port <- 3306 # always this port unless you change it during installation

#Connect to the database
mydb <-  dbConnect(MySQL(), user = db_user, password = db_password,
                   dbname = db_name, host = db_host, port = db_port,local_infile = TRUE)

library(RSQLite)
fpath = "/Users/Cerf/Desktop/R/databases/"
dbfile = "PublicationDB.sqlite"
dbcon <- dbConnect(SQLite(), paste0(fpath, dbfile))


fact_data <- dbGetQuery(dbcon, "
  SELECT j.ISSN, j.Title, 
         PubYear as year,
         PubQuarter as quarter,
         COUNT(DISTINCT a.PMID) as num_articles,
         COUNT(DISTINCT aa.author_id) as num_authors
  FROM Journal j
  JOIN Articles a ON j.ISSN = a.Journal_ISSN
  JOIN Authorship aa ON a.PMID = aa.article_id
  GROUP BY j.ISSN, year, quarter
  LIMIT 100
")

dbExecute(mydb,"DROP TABLE IF EXISTS journal_facts")
dbExecute(mydb, "CREATE TABLE journal_facts (ISSN integer,Title text,year text,quarter integer,
          num_articles integer,num_authors integer)")

dbGetQuery(mydb, "SET GLOBAL local_infile = 1;")

dbWriteTable(mydb, "journal_facts", fact_data, overwrite = T)

dbGetQuery(mydb,"SELECT * FROM journal_facts")


