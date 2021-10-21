multipolygon = "(((1,2),(3,4)),((5,6),(7,8)),((9,10),(11,12)))"

multipolygon = chop(multipolygon, head=1, tail=1)
splitArray = split(multipolygon, ")),")
for x in 1:length(splitArray)
    println(splitArray[x])
end