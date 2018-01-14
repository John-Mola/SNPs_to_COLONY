#!/bin/sh

DAT=$1

srun ~/bin/colony/colony2s.ifort.out IFN:./$DAT
