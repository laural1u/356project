result <- read.csv("D:/OneDrive - University of Waterloo/uwaterloo/2021-3-Fall/ECE 356/project/356project/result.csv")
model = lm(grade~total_click, data=result)
summary(model)