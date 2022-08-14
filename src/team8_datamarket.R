library(dplyr)
library(lubridate)

# 5명인 조
dset <- c("dataset1","dataset2","dataset3","dataset4","dataset5")

# 6명인 조
#dset <- c("dataset1","dataset2","dataset3","dataset4","dataset5","dataset6")

#값 초기화
os <- 0
is <- 0

for (i in dset){ # 사람 한명 데이터 당 돌아가는 반복문
  
  print(paste("****", i, "****",sep = ""))
  
  title <- paste(i,".csv",sep="")
  map <- read.csv(title)
  
  #시간변환
  time <- map$Timestamp #해당 조의 시간 변수를 작성해야함

  date <- strptime(time,format="%Y-%m-%dT%H:%M:%S")
  date<-ymd_hms(date, tz = "UTC")
  attributes(date)$tzone = "Asia/Seoul"
  
  
  ########## 날짜 찾기 ##############
  
  # 변수 초기화 
  len <- c(1:length(date))
  tmp = date[1]
  day_lst = c(make_date(2019,month(tmp),day(tmp)))
  day_idx = c(1)
  cnt = 1
  
  
  #날짜가 변경되는 인덱스를 리스트에 추가
  for (i in len){
    day_d = make_date(2019,month(date[i]),day(date[i]))
    
    if (day_d != day_lst[cnt]){
      day_idx = c(day_idx, i)
      day_lst = c(day_lst, day_d)
      cnt = cnt + 1
      
    }
  }
  
  ############ OS, IS 찾기 ##############
  
  #연산을 위해 마지막 인덱스 추가
  day_idx = c(day_idx, length(date))
  
  
  #날짜 별로 for문 돌려서 10-14시 사이 os,is 구분
  for (i in c(1:(length(day_idx)-1))){

    
    begin = day_idx[i]
    end = day_idx[i+1]-2
    
    flag = F #20분 이상 빈 경우를 표시해주는 플래그로, 빈 시간이 없으면 F를 유지한다.
    
    for (k in c(begin:end)){ #날짜 별 시간 가리키는 인덱스 k
      
      nd = date[k]    #현재시간
      td= date[k+1]   #다음시간
      
      # 10시 - 14시 사이에 20분 이상 비어있는 구간 체크
      if (hour(nd) >= 10 & hour(td) <= 14){
        nnd = as.numeric(nd)
        ntd = as.numeric(td)
        
        # 20분 이상 빈 경우
        if(ntd-nnd>1200){  # 시간을 계산할 수 있도록 처리해주어야 함 
          
          # loop에서 if(a[n+1] - a[n]) > 1200s 이면 os+1
          os<-os+1
          
          flag = T
          break
        }
        
      }
    }
    if (!flag){  # otherwise is + 1
      is <- is+1
    }
  }
  
}


t_ratio <- abs(os/(os+is))
ratio <- abs(os/(os + is) - 0.5)
vpl = c(t_ratio, 1-t_ratio, ratio)


pl <- data.frame("OS" = t_ratio, "IS" = 1-t_ratio, "RATIO" = ratio)
print(pl)

jpeg(filename = "team8.jpeg", width = 500, height= 500) # 사진 저장시 팀이름 변경!!!

# 그래프로 그려 그림으로 저장
barplot(vpl, names = c(paste("OS\n(",round(t_ratio,4),")",sep=""),paste("IS\n(",round(1-t_ratio,4),")",sep=""),paste("RATIO\n(",round(ratio,4),")",sep="")))

dev.off()

##########################
