library(lubridate)


dset <- c("dataset1","dataset2","dataset3","dataset4","dataset5")
#dset <- c("dataset1","dataset2","dataset3","dataset4","dataset5","dataset6")

for (q in dset){
  print(q)
  title = paste(q,"_place.csv",sep="")
  pdata = read.csv(title)
  
  place = as.numeric(as.character(pdata$Place))
  difference = pdata$Difference
  
  pdata[,"Date"] = as.Date(pdata$Date)
  pdata[,"Startpoint"] = ymd_hms(pdata$Startpoint)
  pdata[,"Endpoint"] = ymd_hms(pdata$Endpoint)
  
  lenp = length(pdata$Place)
  
  
  
  # ��¥ ���� �̱�
  day_lst = unique(pdata$Date)
  day_idx = c()
  
  for (k in day_lst){
    t = which(pdata$Date == k)
    day_idx = c(day_idx,t[1])
  }
  day_idx
  day_idx = c(day_idx,length(pdata$Date))
  
  #��¥ �� ������ �ٷ��
  for (m in c(1:(length(day_idx)-1))){
    
    begin = day_idx[m]
    end = day_idx[m+1]-2
    
    
    # place �� ���� 1
    if ((begin+1) == day_idx[m+1] || begin >= end){
      next
    }
    for (i in c((begin+1):end)){
      
      bp = place[i-1]
      pp = place[i]
      fp = place[i+1]
      
      #100������ ��
      if (pp >= 100){
        pp100 = pp/100
        if (bp == pp100 & fp == pp100){
          pp = bp
        }else if(bp == pp100){
          pp = bp
        }else if(fp == pp100)
          pp = fp
      }else{
        # 0 600 0 / 10000
      }
      
      place[i] = pp
      
      
      
      # place�� 0�ε� �� �Ʒ��� �����ϴ�
      # => �ش� ���ڷ� ����
      if (pp == 0 & bp == fp){
        place[i] = bp
      }
      
    }
  }
  
  
  
  pdata[,"Place"] = place
  
  
  #title_a = paste(q, "_replace1.csv",sep="")
  #write.csv(pdata,file = title_a,row.names = F)
  
  
  ############################################################
  
  # ������ place�� ���� �籸��
  place= pdata$Place
  
  #��¥ �� ������ �ٷ��
  for (m in c(1:(length(day_idx)-1))){
    
    begin = day_idx[m]
    end = day_idx[m+1]-1
    
    ts = c(pdata$Startpoint[begin])
    
    
    te = c()
    tdf = c()
    tp = c(place[begin])
    
    tidx = 1
    
    if ((begin+1) == day_idx[m+1]|| begin > end){
      te = c(pdata$Endpoint[begin])
      diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
      tdf = c(tdf, diff)
    }
    else{
      for (i in c((begin+1):end)){
        if(place[i] != tp[tidx]){
          #��� �޶����� �ð� �ɰ���
          if (length(te)==0){
            te = c(pdata$Endpoint[i-1])
          }else{
            te = c(te,pdata$Endpoint[i-1])
          }
          
          
          ts = c(ts,pdata$Endpoint[i-1])
          tp = c(tp,place[i])
          
          
          diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
          tdf = c(tdf, diff)
          
          tidx = tidx + 1
          
          
        }
      }
      
    }
    
    # endpoint
    if (length(ts) > length(te)){
      if (ts[length(ts)] != pdata$Endpoint[end]){
        if (length(te) == 0){
          te = c(pdata$Endpoint[end])
          diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
          tdf = c(tdf, diff)
          tidx = tidx + 1
        }else{
          te = c(te, pdata$Endpoint[end])
          diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
          tdf = c(tdf, diff)
          
          tidx = tidx + 1
        }
      }
      else{
        ts = ts[-length(ts)]
        tp = tp[-length(tp)]
        tidx = tidx - 1
      }
    }
    
    td = c(pdata$Date[begin])
    if (length(tp) > 1){
      for (i in c(2:length(tp))){
        td = c(td,pdata$Date[begin])
      }
    }
    
    if (m == 1){
      nd = td
      ns = ts
      ne = te
      ndf = tdf
      np = tp
    }else{
      nd = c(nd,td)
      ns = c(ns,ts)
      ne = c(ne,te)
      ndf = c(ndf,tdf)
      np = c(np,tp)
      
    }
    
    dsave =data.frame (nd,ns,ne,ndf,np)
    colnames(dsave) = c('Date','Startpoint','Endpoint','Difference','Place')
    
    #title_a = paste(q, "_placeclean1.csv",sep="")
    #write.csv(dsave,file = title_a,row.names = F)
    
  }
  
  
  ############################################################
  
  # place ���� 2
  place = pdata$Place
  
  # �� �α��� �������ǵ� �ǹ� ���� ���� ��� �� 0���� �����
  for (m in c(1:(length(day_idx)-1))){
    
    begin = day_idx[m]
    end = day_idx[m+1]-2
    
    # place �� ����
    
    if ((begin+1) == day_idx[m+1]|| begin >= end){
      next
    }
    for (i in c((begin+1):end)){
      
      
      bp = place[i-1]
      pp = place[i]
      ppdiff = difference[i]
      fp = place[i+1]
      
      # 0 10 0�ε� 10�� 180�� �����ΰ�� 0����
      if (bp == 0 & bp == fp){
        if (pp != 0 & ppdiff <= 180){
          place[i] = 0
        }
      }
      
      # 0 10 2  �ε� 10�� 180�� ���ϸ� 0����
      else if (bp ==0 & fp != pp){
        if (pp != 0 & ppdiff <= 180){
          place[i]= 0
        }
      } 
      else if(fp == 0 & bp != pp){
        if (pp!= 0 & ppdiff <= 180){
          place[i] = 0
        }
      }
      
      # �������� ���� ���ƴµ� 180�� �����̰� �� �յڿ� 0���� �����ߴ� ��� -> 0���� ġȯ
      
    }
  }
  
  pdata[,"Place"] = place
  
  
  #title_a = paste(q, "_replace2.csv",sep="")
  #write.csv(pdata,file = title_a,row.names = F)
  
  
  
  ############################################################
  
  
  
  
  
  # ������ place�� ���� �籸��
  place = pdata$Place
  
  #��¥ �� ������ �ٷ��
  for (m in c(1:(length(day_idx)-1))){
    
    begin = day_idx[m]
    end = day_idx[m+1]-1
    
    ts = c(pdata$Startpoint[begin])
    
    te = c()
    tdf = c()
    tp = c(place[begin])
    
    tidx = 1
    
    if ((begin+1) == day_idx[m+1]|| begin > end){
      te = c(pdata$Endpoint[begin])
      diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
      tdf = c(tdf, diff)
    }
    else{
      for (i in c((begin+1):end)){
        if(place[i] != tp[tidx]){
          #��� �޶����� �ð� �ɰ���
          if (length(te)==0){
            te = c(pdata$Endpoint[i-1])
          }else{
            te = c(te,pdata$Endpoint[i-1])
          }
          
          
          ts = c(ts,pdata$Endpoint[i-1])
          tp = c(tp,place[i])
          
          
          diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
          tdf = c(tdf, diff)
          
          tidx = tidx + 1
          
          
        }
      }
      
    }
    
    # endpoint
    if (length(ts) > length(te)){
      if (ts[length(ts)] != pdata$Endpoint[end]){
        if (length(te) == 0){
          te = c(pdata$Endpoint[end])
          diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
          tdf = c(tdf, diff)
          tidx = tidx + 1
        }else{
          te = c(te, pdata$Endpoint[end])
          diff = as.numeric(te[tidx]) - as.numeric(ts[tidx])
          tdf = c(tdf, diff)
          
          tidx = tidx + 1
        }
      }
      else{
        ts = ts[-length(ts)]
        tp = tp[-length(tp)]
        tidx = tidx - 1
      }
    }
    
    td = c(pdata$Date[begin])
    if (length(tp) > 1){
      for (i in c(2:length(tp))){
        td = c(td,pdata$Date[begin])
      }
    }
    
    if (m == 1){
      nd = td
      ns = ts
      ne = te
      ndf = tdf
      np = tp
    }else{
      nd = c(nd,td)
      ns = c(ns,ts)
      ne = c(ne,te)
      ndf = c(ndf,tdf)
      np = c(np,tp)
      
    }
    
    dsave =data.frame (nd,ns,ne,ndf,np)
    colnames(dsave) = c('Date','Startpoint','Endpoint','Difference','Place')
    
    title_a = paste(q, "_placecleanfinal.csv",sep="")
    write.csv(dsave,file = title_a,row.names = F)
    
  }
  
}
