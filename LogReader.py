#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      didac
#
# Created:     03/03/2017
# Copyright:   (c) didac 2017
# Licence:     <your licence>
#-------------------------------------------------------------------------------


import csv

def main():

    with open('some.csv', 'rb') as f:
        reader = csv.reader(f)
        for row in reader:
            print row

if __name__ == '__main__':
    main()
