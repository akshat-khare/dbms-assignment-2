import random
import numpy as np
import datetime
read_file = open("cities.csv","r")
count=0
threshold=10
numedges=20000
numseconds= 86399
cityarr=[]
for line in read_file:
	count+=1
	if(count==1):
		continue
	# print(line)
	linearr=line.split(',')
	# print(linearr)
	city= linearr[0].lower().strip()
	cityarr.append(city)
	# if(count>threshold):
	# 	break
# print(cityarr)
# print(len(cityarr))

# print("cityname")
# for city in cityarr:
# 	print(city)
numcities= len(cityarr)
indexofdelhi =-1
indexofdelhi =cityarr.index('delhi')
indexofmumbai = -1
indexofmumbai = cityarr.index('mumbai')
# print(indexofdelhi)
# print(indexofmumbai)
# exit()
numedgesadded=0
edges = np.zeros((numedges,2))
while(numedgesadded<numedges):
	if(numedgesadded==0):
		start= indexofdelhi
		end = indexofmumbai
	else:
		start = random.randint(0,numcities-1)
		end = random.randint(0,numcities-1)	
	if(start>=end):
		continue
	edges[numedgesadded][0]=start
	edges[numedgesadded][1]=end
	numedgesadded+=1
# print(edges)
# print(len(edges))
numtimeadded=0
deptime=[]
arrtime=[]
distancearr=[]
while(numtimeadded<numedges):
	start=random.randint(0,numseconds)
	end=random.randint(0,numseconds)
	if(start>=end):
		continue
	deptime.append(str(datetime.timedelta(seconds=start)))
	arrtime.append(str(datetime.timedelta(seconds=end)))
	distancearr.append(random.randint(1,2000))
	numtimeadded+=1
# print(deptime)
# print(arrtime)
# print(distancearr)
print("train_id,source,destination,distance,departure_time,arrival_time")
for x in range(numedges):
	print(str(x+1)+ ","+cityarr[int(edges[x][0])]+","+cityarr[int(edges[x][1])]+","+ str(distancearr[x])+","+str(deptime[x])+","+str(arrtime[x]))
