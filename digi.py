#!/usr/bin/python

import sys
from digidevice import runt

runt.start() 

def main():


    digikeys = runt.keys("")

    for i in digikeys:
         print (i)

if __name__ == '__main__':
    main()