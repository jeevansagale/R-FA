library(readxl)
 HR_Employee_Data <- read_excel("C:/Users/Shiv/Downloads/HR_Employee_Data.xlsx")
View(HR_Employee_Data)
Data=HR_Employee_Data
summary(Data)


#Whether employees are not satisfied with their job work
Data1=group_by(Data, left)
Satifaction=summarise(Data1, Averge=mean(satisfaction_level), Variations=sd(satisfaction_level))
plot1=filter(Data, left==1) %>% ggplot( aes(satisfaction_level))+geom_boxplot( color="red")+
  labs(title="Ex employee ")
print(plot1)
plot2=filter(Data, left==0) %>% ggplot( aes(satisfaction_level))+geom_boxplot(color="blue")+
  labs(title="current employee ")
print(plot2)

dev.off()
library(grid)
viewport<- viewport(
  layout=grid.layout(2,1))
pushViewport(viewport)
print(x=plot1,
      vp=viewport(
        layout.pos.row = 1,
        layout.pos.col=1))
print(x=plot2,
      vp=viewport(
        layout.pos.row = 2,
        layout.pos.col=1))

#
data2=group_by(Data, promotion_last_5years) 
data3=summarise(data2, satisfaction=mean(satisfaction_level), Monthly_hours=mean(average_montly_hours), Duration=mean(time_spend_company))
ggplot(Data, aes(satisfaction_level,average_montly_hours))+geom_point()
ggplot(Data, aes(satisfaction_level,average_montly_hours))+geom_point()+ylim(80,200)+xlim(0.20,0.8)

ggplot(Data, aes(satisfaction_level,average_montly_hours,col=factor(left)))+geom_point()+ylim(80,200)+xlim(0.20,0.8)
ggplot(Data, aes(promotion_last_5years))+geom_bar()
ggplot(Data, aes(promotion_last_5years, fill=factor(left)))+geom_histogram(binwidth = 0.8)
ggplot(Data, aes(promotion_last_5years, fill=factor(time_spend_company)))+geom_histogram(binwidth = 0.8)


#Whetehr Department affected salaries and increaments
ggplot(Data, aes( salary))+geom_bar()
ggplot(Data, aes(Department))+geom_bar(aes(fill=salary), position="dodge")+coord_flip()
ggplot(Data, aes(Department))+geom_bar(aes(fill=salary), position="stack")+coord_flip()
ggplot(Data, aes(factor(promotion_last_5years)))+geom_bar(aes(fill=Department), position="stack")


#To export data from R
install.packages("openxlsx")
library(openxlsx)
install.packages("rio")
library(rio)
export(data3, "Stmt_3.xlsx")