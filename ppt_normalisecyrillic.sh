#!/bin/bash

perl -CSD -ne 'print lc' |
    sed 's/ина/инe/'
