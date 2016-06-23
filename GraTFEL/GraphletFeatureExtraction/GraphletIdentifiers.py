__author__ = 'mmrahman'
import numpy as np

def GraphletID(Graphlet):
    '''
    if Graphlet.number_of_nodes()==1:
        return 0
    if Graphlet.number_of_nodes()==Graphlet.number_of_edges()==2:
        return 11
    '''
    nodes=Graphlet.nodes()
    degreeList=np.zeros(len(nodes))
    weightList=np.array([1,10,100,1000,10000])

    for n,i in zip(nodes,range(0,len(nodes))):
        degree=len(Graphlet[n].keys())
        degreeList[i]=degree
    degreeList.sort()

    graphletId=int(sum(degreeList*weightList[0:len(nodes)]))

    if graphletId==32221 or graphletId==33222:
        neighbourDegreeList=np.zeros(3)
        for n,i in zip(nodes,range(0,len(nodes))):
            if len(Graphlet[n].keys())==3:
                for neighbors,j in zip(Graphlet[n].keys(),range(0,3)):
                    neighbourDegreeList[j]=len(Graphlet[neighbors].keys())
                neighbourDegreeList.sort()
                graphletId=graphletId*1000+int(sum(neighbourDegreeList*weightList[0:3]))
                break


    return graphletId




            #print n
            #print Graphlet.neighbors(n)
            #print Graphlet[n].keys()
