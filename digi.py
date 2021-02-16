#!/usr/bin/python

import sys
import speedtest
from digidevice import runt

runt.start()
iterations = 0

def test():
        s = speedtest.Speedtest()
        print (s)
        print(s.get_servers())
        print(s.get_best_server())
        print(s.download())
        print(s.upload())
        res = s.results.dict()
        print (res)
        return res["download"], res["upload"], res["ping"]
def main():
    # simply print in needed format if you want to use pipe-style: python script
     for i in range(iterations):
          d, u, p = test()
          print('Test #{}\n'.format(i+1))
          print('Download: {:.2f} Kb/s\n'.format(d / 1024))
         print('Upload: {:.2f} Kb/s\n'.format(u / 1024))
         print('Ping: {}\n'.format(p))

    digikeys = runt.keys("")

    for i in digikeys:
         print (i)

if __name__ == '__main__':
    main()