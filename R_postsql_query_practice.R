#RpostgreSQL package practice

library("RPostgreSQL", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname = "nbastats",
                 host = "acgpostgres.cm478rhwwdgh.us-east-1.rds.amazonaws.com", port = 5432,
                 user = "", password = "")

#test
dbExistsTable(con, "nbastats")

Rnbastats <- dbGetQuery(con, "SELECT * from nbastats")

toprebound <- dbGetQuery(con, 
	"SELECT player, rbs
	FROM nbastats
	ORDER BY rbs desc
	limit 10")

toppoint <- dbGetQuery(con,
	"SELECT player, pts
	FROM nbastats
	ORDER BY PTS desc
	limit 10")

zpts <- dbGetQuery(con,
	"SELECT player, (pts - avg(pts)over()) / stddev(pts) over() AS z_pts
	from nbastats")

dbWriteTable(con, c("zpts"), value=zpts,append=TRUE, row.names=FALSE)

nbastats_zpts <- dbGetQuery(con, 
	"CREATE TABLE nbastats_zpts AS
	SELECT nbastats.*, zpts.z_pts                                                                                                                          
	from nbastats, zpts
	where nbastats.player = zpts.player")

nbastats_zpts <- dbGetQuery(con, "SELECT * from nbastats_zpts")

dbDisconnect(con)
dbUnloadDriver(drv)