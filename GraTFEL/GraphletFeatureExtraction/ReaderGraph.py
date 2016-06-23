__author__ = 'mmrahman'
import scipy.io as sio
import networkx as nx


#not complete
'''
def ReadEdges(fileName,Graph,time):
    f_in = open(fileName)
    for line in f_in:
        splits = line.split()
        if len(splits)!=2:
            continue

        u=int(splits[0])
        v=int(splits[1])
        if u==v:
            continue
        if u>v:
            t=u
            u=v
            v=t

        #if v not in Graph[u]:
        Graph.add_edge(u,v,{'history':time})
#        Graph[u][v]['history'].append(time)
'''

#not complete

def ReadEdges(fileName,Graph):
    f_in = open(fileName)
    for line in f_in:
        splits = line.split()
        if len(splits)!=2:
            continue
        Graph.add_edge(int(splits[0]),int(splits[1]))

#reads dynamic network from matfile. Must be a variable "adj" with dimensions n*n*t.
#n is number of nodes and t is number of time stamps
def ReadMat(fileName,Graphs):
    Data=sio.loadmat(fileName)
    n=Data['adj'].shape[0]
    t=Data['adj'].shape[2]
    print("Loaded a network with "+str(n)+" Nodes and "+str(t)+" time stamps")

    #print(type(Data['adj']))
    #print Data['adj'].itemsize

    #print Data['adj'].ndim
    edges = Data['adj'].nonzero()
    #print edges[0]
    #print edges[1]
    #print edges[2]

    for i in range(0,t):
        Graphs[i]=nx.Graph()
        Graphs[i].add_nodes_from(range(0,n)) #makes sure, that all snaps has same number of nodes

    for i in range(0,edges[0].size):
        #print(str(edges[0][i])+"\t"+str(edges[1][i])+"\t"+str(edges[2][i])+"\t")
        if edges[0][i]<edges[1][i]:
            Graphs[edges[2][i]].add_edge(edges[0][i],edges[1][i])


