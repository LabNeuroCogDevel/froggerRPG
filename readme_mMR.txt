64 bit matlab on 64 bit windows 7

parallel port matlab:

   c:/matlab_io32_io64/io64
   see html file for instructions
   ** 
    config_io to initialize
   **

psychtoolbox install:
  done for 2015a
  2020a:
    cd C:\toolbox\Psychtoolbox\
    SetupPsychtoolbox

luna needs access to
  C:\Program Files\MATLAB\R2020a\toolbox\local\pathdef.m

paralle port windows install:
 - drivers fetched 


network: - use test ip
  10.48.88.247
  10.48.88.1

  reset to default: 10.48.86.241 (even though it wont work)



20210511 -
 using COM1. line 260 of getSettings:     s.serial.port = 'COM1'; 
             and in runTests