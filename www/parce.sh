#!/bin/bash
OLDFILE="./cdr-old.csv"
NEWFILE="./cdr.csv"
PARCEFILE="./cdr.parce"
diff $OLDFILE $NEWFILE|sed -e 's/> //'|sed -e '1,1d' >$PARCEFILE
#mv $NEWFILE $OLDFILE



