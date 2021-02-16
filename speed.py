#!/usr/bin/python

import speedtest


def test():
    s = speedtest.Speedtest()
    s.get_servers()
    s.get_best_server()
    s.download()
    s.upload()
    res = s.results.dict()
    return res["download"], res["upload"], res["ping"]


def main():
    # write to csv
    with open('file.csv', 'w') as f:
        f.write('download,upload,ping\n')
        for i in range(3):
            print('Making test #{}'.format(i+1))
            d, u, p = test()
            f.write('{},{},{}\n'.format(d, u, p))
