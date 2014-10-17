# read in full activity csv file
activity_all <- read.csv(file="./activity.csv", header=TRUE)
#calculate daily steps
library(plyr)
daily_steps <- ddply(activity_all, .(date), summarize, t_steps=sum(steps,na.rm=TRUE))
# print histogram of steps taken per day
hist(daily_steps$t_steps, main="Number of Daily Steps", xlab="Steps Taken", 
     ylab="Frequency", col="green", breaks=30, xlim=c(0,25000), ylim=c(0,12))
# mean number of steps per day
mean(daily_steps$t_steps)
# median number of steps per day
median(daily_steps$t_steps)

#question 2
#calc average # of steps per interval across days
avg_steps_interval <- aggregate(activity_all$steps, by=list(activity_all$interval),
    FUN=mean, na.rm=TRUE)
colnames(avg_steps_interval)[1] <- "interval"
colnames(avg_steps_interval)[2] <- "avg_steps"
#create time series plot for avg steps by interval
library(ggplot2)
qplot(interval,avg_steps, data=avg_steps_interval,geom="line",xlab="5 Minute Intervals",
      ylab="Average Number of Steps")
#find time interval has the max avg number of steps
max_avg_steps_row <- which.max(avg_steps_interval$avg_steps)
avg_steps_interval[max_avg_steps_row,1]
#
#Question 3
# calculate the number of rows with NA values
total_rows <- NROW(activity_all)
good_rows <- NROW(na.omit(activity_all))
total_rows - good_rows
# impute missing values by using the average number of steps for an interval as
# the imputed value
activity_w_values <- activity_all
for (n in 1:NROW(activity_w_values)){
    if (is.na(activity_w_values$steps[n])){
        activity_w_values$steps[n] <- 
        avg_steps_interval$avg_steps[which(activity_w_values$interval[n]==avg_steps_interval$interval)]
    }
}
# calculate daily steps with imputed values included
daily_steps_imp <- ddply(activity_w_values, .(date), summarize, t_steps=sum(steps))
# print histogram of steps taken per day with values imputed
hist(daily_steps_imp$t_steps, main="Number of Daily Steps", xlab="Steps Taken", 
     ylab="Frequency", col="green", breaks=30, xlim=c(0,25000), ylim=c(0,12))
# mean number of steps per day
mean(daily_steps_imp$t_steps)
# median number of steps per day
median(daily_steps_imp$t_steps)
# question 4
activity_w_values$day <- weekdays(as.Date(activity_w_values$date))
# determine weekday or weekend
activity_w_values$day <- ifelse ((activity_w_values$day== "Saturday" | activity_w_values$day== "Sunday"), "Weekend", "Weekday")
# average steps by day#####################
averages <- aggregate(steps ~ interval + day, data = activity_w_values, mean)
# plot 
ggplot(averages, aes(interval, steps)) + geom_line() + facet_grid(day ~ .) + 
    xlab("5-minute interval") + ylab("Number of steps")
#