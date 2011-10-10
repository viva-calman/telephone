#!/bin/bash
OLDFILE="./cdr-old.csv"
NEWFILE="./cdr.csv"
PARCEFILE="./cdr.parce"
diff $OLDFILE $NEWFILE|sed -e 's/> //'|sed -e '/^<.*$/ d'|sed -e '/---/ d'|sed -e '1,1 d' >$PARCEFILE
mv $NEWFILE $OLDFILE



