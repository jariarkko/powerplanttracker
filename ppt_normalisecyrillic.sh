#!/bin/bash

perl -CSD -ne 'print lc' |
    sed 's/ина/ине/' |
    sed 's/инe/ине/'
