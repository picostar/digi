#!/usr/bin/python

import sys
from digidevice import runt

runt.start() 

def tree_traverse(tree):
    for k in tree.items():
          v = runt.get("k")
          if v is not None:
            return k,v

def main():

     digikeys = runt.keys("")

     for i in digikeys:
          print (i)
          mk = runt.keys(i)
          for x in mk:
               print (x)
               y = runt.get("x")
               print (y)

     print (tree_traverse(digikeys))

if __name__ == '__main__':
    main()