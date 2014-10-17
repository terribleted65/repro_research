Analyze, graph, and report on the activity of an anonymous individual using 2 months 
of data gathered from their personal activity monitoring device (e.g. fitbit).

Load the data


```r
activity_all <- read.csv(file="./activity.csv", header=TRUE)
```


The total number of steps taken each day while ignoring missing data.

```r
# print histogram of steps taken per day
hist(daily_steps$t_steps, main="Number of Daily Steps", xlab="Steps Taken", 
     ylab="Frequency", col="green", breaks=30, xlim=c(0,25000), ylim=c(0,12))
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png) 

The mean number of steps per day:

```r
mean(daily_steps$t_steps)
```

```
## [1] 9354.23
```

The median number of steps per day:

```r
median(daily_steps$t_steps)
```

```
## [1] 10395
```

Average number of steps taken across all days within a 5 minute interval while 
ignoring missing values:


```r
#calc average # of steps per interval across days
avg_steps_interval <- aggregate(activity_all$steps, by=list(activity_all$interval),
    FUN=mean, na.rm=TRUE)
colnames(avg_steps_interval)[1] <- "interval"
colnames(avg_steps_interval)[2] <- "avg_steps"
#create time series plot for avg steps by interval
library(ggplot2)
qplot(interval,avg_steps, data=avg_steps_interval,geom="line",xlab="5 Minute Intervals",
      ylab="Average Number of Steps")
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png) 

What time 5-minute time interval, on average, contains the maximum number of steps?


```r
#find time interval has the max avg number of steps
max_avg_steps_row <- which.max(avg_steps_interval$avg_steps)
avg_steps_interval[max_avg_steps_row,1]
```

```
## [1] 835
```

Impute the missing steps data from the original data:


```r
# impute missing values by using the average number of steps for an interval as
# the imputed value
activity_w_values <- activity_all
for (n in 1:NROW(activity_w_values)){
    if (is.na(activity_w_values$steps[n])){
        activity_w_values$steps[n] <- 
        avg_steps_interval$avg_steps[which(activity_w_values$interval[n]==avg_steps_interval$interval)]
    }
}
```

Total number of steps taken each days using imputed values:


```r
# calculate daily steps with imputed values included
daily_steps_imp <- ddply(activity_w_values, .(date), summarize, t_steps=sum(steps))
# print histogram of steps taken per day with values imputed
hist(daily_steps_imp$t_steps, main="Number of Daily Steps", xlab="Steps Taken", 
     ylab="Frequency", col="green", breaks=30, xlim=c(0,25000), ylim=c(0,12))
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png) 

Compare the average number of steps taken per 5-minute interval across weekdays
and weekends:


```r
activity_w_values$day <- weekdays(as.Date(activity_w_values$date))
# determine weekday or weekend
activity_w_values$day <- ifelse ((activity_w_values$day== "Saturday" | activity_w_values$day== "Sunday"), "Weekend", "Weekday")
# average steps by day#####################
averages <- aggregate(steps ~ interval + day, data = activity_w_values, mean)
# plot 
ggplot(averages, aes(interval, steps)) + geom_line() + facet_grid(day ~ .) + 
    xlab("5-minute interval") + ylab("Number of steps")
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10-1.png) 
