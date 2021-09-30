#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jul 25 13:34:59 2020

@author: robbertmijn
"""

from fitparse import FitFile
from os import path, listdir
import sys

if __name__ == '__main__':
    indir = sys.argv[1]
    outdir = sys.argv[2]
                    
    for filename in [f for f in listdir(indir) if f.endswith('.fit')]:
        with open(outdir + '/' + filename + '.csv','w') as csv_file:
            csv_file.write('time,lat,long,dist,speed,hr,alt_enh,alt,cadence\n')
            
            fitfile = FitFile(path.join(indir,filename))
            fitfile = FitFile("Ramp_Test.fit")
            print(filename)
            # Get all data messages that are of type record
            for lap in fitfile.get_messages('lap'):
                print("..")
                for d in lap:
                    print(d)
                
                
                
                for data in record:
                    
                    print(data)
                    
                    # Print the name and value of the data (and the units if it has any)
                    if data.units:
                        print(" * {}: {} ({})".format(data.name, data.value, data.units))
                    else:
                        print(" * {}: {}".format(data.name, data.value))
            
                if position_long:
                    try:
                        csv_file.write('%s,%.0f,%.0f,%.2f,%.3f,%.0f,%.0f\n'%(timestamp, position_lat, position_long, distance, enhanced_speed, heart_rate, cadence))
                    except:
                        print(position_lat, distance)

# f = gzip.open(path.join('export',i), 'rb')
#         file_content = f.read()
#         f.close()