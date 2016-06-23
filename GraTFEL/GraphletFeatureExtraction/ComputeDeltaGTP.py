__author__ = 'mmrahman'
import networkx as nx
from GraphletIdentifiers import GraphletID

def MineDeltaGraphletTransitionsFromDynamicNetwork(Graph1,Graph2,Stat,u,v):
    G=Graph2.subgraph([u,v])
    growGraphlet(G,Graph1,Graph2,5,Stat,u,v)



def growGraphlet(Graphlet,Graph1,Graph2,GraphletSize,Stat,u,v):
    Extensions=list()
    for n in Graphlet.nodes():
        Extensions.extend(Graph2[n].keys())
    Extensions=set(Extensions)
    for n in Graphlet.nodes():
        Extensions.remove(n)


    #print "Extensions: " + str(Extensions)
    for n in Extensions:
        ExtendedNodeList=Graphlet.nodes()
        ExtendedNodeList.append(n)
        ExtendedGraphlet=Graph2.subgraph(ExtendedNodeList)
        #print ExtendedNodeList
        #print n
        if ISRedundent(ExtendedGraphlet,n,u,v):
            #print "redundent"
            continue

        gid2=GraphletID(ExtendedGraphlet)
        PastGraphlet=Graph1.subgraph(ExtendedNodeList)

        pastConnceted=nx.connected_components(PastGraphlet)

        '''
        if nx.number_connected_components(PastGraphlet)>1:
            print "------"
            print ExtendedNodeList
            for x in pastConnceted:
                print x
        '''

        for x in pastConnceted:
            #print x
            gid1=GraphletID(Graph1.subgraph(x))

            if gid1==0: #not interested in growing from a  node
                continue

            if gid1 not in Stat:
                Stat[gid1]=dict()
            if gid2 not in Stat[gid1]:
                Stat[gid1][gid2]=0
            Stat[gid1][gid2]+=1
            #print str(gid1)+"->"+str(gid2)
        '''
        print "Graphlet id: "+str(gid)
        print ExtendedGraphlet.nodes()
        print ExtendedGraphlet.edges()
        '''


        if len(ExtendedGraphlet.nodes())<GraphletSize:
             growGraphlet(ExtendedGraphlet,Graph1,Graph2,GraphletSize,Stat,u,v)
        del ExtendedGraphlet
        del ExtendedNodeList
        del PastGraphlet
    del Extensions

def ISRedundent(Graphlet,NewNode,u,v):
    nodes=Graphlet.nodes()
    for n in nodes:
        if n <= NewNode or n==u or n==v:
            continue
        G=nx.Graph(Graphlet)
        G.remove_node(n)
        if nx.number_connected_components(G)==1:
            del G
            return True
        del G

    return False

