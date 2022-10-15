# Name - Sarjak Atul Maniar
# Email - sm2732@scarletmail.rutgers.edu


library(readr)

myData <- read_csv('/Users/sarju/Desktop/MITA Sem 1/ABI/HomeWork/Week1/Lab1/Ch1_bike_sharing_data.csv')

df <- data.frame(myData)

head(df)

class(Ch1_bike_sharing_data) # "data.frame"
# A data.frame is native to R and is the simplest most basic type of table structure.

str(df)
dim(df)

# Create a new data.frame from an existing one

bike = df
head(bike)

# Convert data.frame to data.table
# The table bike is a data.frame, which is the native basic table structure in R, 
# we want to convert it into a data.table, which is a more powerful table structure in R.

# We have to first install the data.table package.

library(data.table)

# Now we will convert the bike data.frame into a data.table
setDT(bike)

class(bike)
str(bike)

# To convert it back into a data.frame (basic table), just use the command:
setDF(bike)


# Let us see the power of Data table

# Filtering Data

bike[season == 4]

bike[season == 4 | season == 1]

# Filter for all the data in winter and summer, using %in%:
bike[season %in% c(1,4)]
f=c(1,4)
bike[season %in% f]

# Filter for the rows that are in winter AND the weather was clear (value 1)
bike[season==4 & weather==1]

# Filter for the rows that are NOT in winter AND the weather was clear(value 1)
bike[season != 4 & weather==1]

# Notice how when you run these lines, the results show up in the console.
# BUT if you could also place the results in another table.

nowinter = bike[season != 4 & weather==1]
nowinter

# Selecting Columns
# df[Row Section,Column Section]
# Select the datetime and windspeed columns:

bike[,.(datetime,windspeed)] # .() are used when we need to select more than 1 column

# The results come back as a data.table, but if you don’t use .(), and have
# just one column, then it comes back as a vector.

bike[,windspeed] 

# Selecting Columns - Applying Functions
# We can apply functions to column data, for example, what is the average temperature:
bike[,mean(temp)]

# Now what if we want the average, standard deviation, minimum, and maximum temperatures:
bike[,.(mean(temp),sd(temp),min(temp),max(temp))]

# We can store the results in another table and rename the columns:
bb=bike[,.(mean(temp),sd(temp),min(temp),max(temp))] 
bb
names(bb)=c('Mean','SD','Min','Max') # renaming the columns of table bb
bb

# What if we want to see the average, standard deviation, min and max, 
# but now according to the seasons. we must now use the 3rd section of the data.table, 
# to do aggregations.

# df[RowSection,ColumnSection,Grouping Section]

# The grouping section allows us to apply functions to subsections of the data. For example:

bike[,.(mean(temp),sd(temp),min(temp),max(temp)),by= season] # Group by column season

# 3 Steps of Aggregation:
# 1.Create 4 subtables, 1 table for each season
# 2.Apply the functions to each subtable
# 3.Combine the results for each of the subtables into 1 table (that’s why we will have 4 rows)


# Now what if we wanted to find the mean, max, etc. for each season’s own weather, 
# i.e. for each particular weather type in each season.

bike[,.(mean(temp),sd(temp),min(temp),max(temp)),by=.( season,weather)]
bws = bike[,.(mean(temp),sd(temp),min(temp),max(temp)),by=.( season,weather)]
# Selecting Columns - Applying Functions
# Let’s put the results in a new table bws, and put the season and weather in order:

names(bws)=c('Season','Weather','Mean','SD','Min','Max') 
bws = bws[order(Season,Weather)] # by default in ascending order
# bws = bws[order(Season,-Weather)] # for descending order, just put a negation '-' sign

# Creating New Variables

# What if we wanted to filter the original bike data, by only the days that had 
# a temperature that was less than the average temperature for its particular season? 
# The simplest way to do this is to simply create a new column, that has the average 
# temperature for each particular season. Again, we will use aggregation and apply 
# grouping by season, but this time we will create new columns within the table with 
# those results:

bike[,avgTemp:=mean(temp)]

bike[,seasonAvgTemp:=mean(temp),by=season]
head(bike,10)
tail(bike,10)

bike[season==4] 
# The average temp for each season will be different..
# So, this is the power of Group By..

# Now we will simply filter and store the results in a new table named bike2:

bike2 = bike[temp < seasonAvgTemp]

# If we wanted to create multiple variables, from multiple columns, the syntax changes slightly:

bike[,c('seasonAvgTemp','seasonMinTemp'):=.(mean(temp) ,min(temp)),by=season]

# In order to create 2 new columns seasonAvgTemp & seasonMinTemp, it need to put in c function and wrap them in quotes.


# Data.table - Shift Example (dfexp)

# The shift() function is a powerful tool that allows you to do analysis across different time-periods.

ticker=c(rep('a',5),rep('b',5))
oi = c(seq(2,10,2),seq(5,25,5)) 

# data.table function creates a data table for you
# while creating the data table, note that the vectors need to be of the SAME SIZE...
dfexp=data.table(tradeday=c(1:5, 1:5),ticker,oi)
# note that here we don't use ':=' function to assign the vector directly while creating the data.table
dfexp 

# shift funciton takes 2 parameters, 1st -> the column which you are counting up or down like row-wise, 
# and 2nd-> by how much you are counting up or down..j
dfexp[, oi_prev:= shift(oi, n=1)] # counting up by 1 row
dfexp

# creatin new column x which is the summation of oi and oi_prev columns
dfexp[, x:=oi+oi_prev]
dfexp

dfexp[, c('oi1', 'oi2', 'oi3'):= shift(oi, n = 1:3)] 
# Remember if we are creating more than 1 columns, then we have to use c function and wrap it in quotes
dfexp

# Three new columns have now been created. 
# Notice when there isn’t enough previous rows, a NA is placed in the column.
# oi1 column -> shift up by 1
# oi2 column -> shift up by 2
# oi3 column -> shift up by 3

# What is wrong with the shift results?

dfexp[, c('oi2', 'oi3', 'oi4'):= shift(oi, n = 1:3)]
dfexp

# Since the shift only happens in sub-groups, b doesn’t look at any of a’s previous rows.
# we can see that for 'b', the shift is not proper. It has taken values from 'a'.
# So we need to do shifting not on the whole table, but as a sub-table..
# We can do this by entering the 3rd section of the data.table with a group by function..

dfexp[, c('oi2', 'oi3', 'oi4'):= shift(oi, n = 1:3), by = ticker]
# there are 2 unique values in ticker column and therefore there are 2 unique sub-tables being created.
# so when the computer comes to the sub-table 'b', it and starts the shifting process it assumes that
# there is nothing above it... 

dfexp














































