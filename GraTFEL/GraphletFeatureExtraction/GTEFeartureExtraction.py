__author__ = 'mmrahman'
from ReaderGraph import ReadMat
import networkx as nx
from ComputeDeltaGTP import MineDeltaGraphletTransitionsFromDynamicNetwork
import sys


#used for mining GTE at a time stamp t
def delta(graph,n,t,nx,OutExt):
    fout_=open(OutExt+'Delta'+str(t)+'.txt','w')
    temp=nx.Graph(graph)
    for u in range(0,n):
        print "stamp: "+str(t)+" node: "+str(u)
        for v in range(u+1,n):
            #print str(u)+"\t"+str(v)
            Stat = dict()
            temp.add_edge(u,v)
            MineDeltaGraphletTransitionsFromDynamicNetwork(graph,temp,Stat,u,v)
            for a in Stat:
                for b in Stat[a]:
                    fout_.write(str(t)+"\t"+str(u)+"\t"+str(v)+"\t"+str(a)+"\t"+str(b)+"\t"+str(Stat[a][b])+"\n")
            if not graph.has_edge(u,v):
                temp.remove_edge(u,v)
    del temp
    fout_.close()


###START###
if len(sys.argv)<5:
    print "Usage: GTEFeartureExtraction.py Input Hop Snap OutPutExt"
    exit()
InputFile=sys.argv[1]
Hop = int(sys.argv[2])
Snap = int(sys.argv[3])
OutExt=sys.argv[4]

#Load graph
GraphSnaps=dict()
ReadMat(InputFile,GraphSnaps)

#print snap stats
for gid in GraphSnaps.keys():
    print "Snap: "+str(gid)+", nodes: "+str(len(GraphSnaps[gid].nodes()))+", edges: "+str(len(GraphSnaps[gid].edges()))

NumSnaps=max(GraphSnaps.keys())+1


#superimpose the graph snapshots and compute the shortest paths between all pair of nodes
#used for decreaseing the dataset size by selecting a subset of all possible pairs
Master=nx.Graph(GraphSnaps[0])
for t in range(1,NumSnaps-1):
    Master=nx.compose(Master,GraphSnaps[t])
    print "Snap: "+str(t)+", nodes: "+str(len(Master.nodes()))+", edges: "+str(len(Master.edges()))
p=nx.shortest_path_length(Master)


#The status of the edges (0/1); truth value
n=len(GraphSnaps[0].nodes())
fout=open(OutExt+'Truth.txt','w') #this file contains edge history of node pairs we are interested in
et=0;
for u in range(0,n):
    for v in range(u+1,n):
        #print str(u)+"\t"+str(v)
        if (v not in p[u]) or p[u][v]>Hop:
            if GraphSnaps[NumSnaps-1].has_edge(u,v):
                et+=1
            continue
        fout.write(str(u)+"\t"+str(v))
        for t in range(1,NumSnaps):
            if GraphSnaps[t].has_edge(u,v):
                fout.write("\t"+str(1))
            else:
                fout.write("\t"+str(0))
        fout.write("\n")
fout.close()
print "et used in matlab: "+str(et)

#compute delta for each edge for time stamp 0 to t-1
n=len(GraphSnaps[0].nodes())
print Snap
delta(GraphSnaps[t],n,Snap,nx,OutExt)

