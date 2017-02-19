#!/bin/bash


if [ $# -ne 3 ]
then
    echo "Usage: ./run.sh trace.prv config.cfg config.cfg"
fi



TIMER_START=$(date +%s.%N)

PARAMEDIR=~/BSCTOOLS/wxparaver-4.6.3-linux-x86_64/bin/paramedir
PARAVER=~/BSCTOOLS/wxparaver-4.6.3-linux-x86_64/bin/wxparaver
TRACE=$1
CFG=$2
BASE=${TRACE%.prv}
CHOP_END=".chop1"
CHOP_BASE=$BASE$CHOP_END
CHOP=$CHOP_BASE.prv
CFG_BASE=${CFG%.cfg}

CFG_IMG=$3
CFG_IMG_BASE=${CFG_IMG%.cfg}

LOOP_START=0
LOOP_STOP=95
LOOP_STEP=5


RANKS=$(head -n1 $TRACE | cut -f6 -d':' | cut -f1 -d'(')

# Set threshold? if <24 h=240?
W_HEIGHT=$((RANKS*10))
cat $CFG_IMG | sed "s/height [0-9]\+/height ${W_HEIGHT}/" > tmp.cfg

#Adjust width too, based on execution time?

cp tmp.cfg $CFG_IMG
rm tmp.cfg

echo "Start"

#for i in {0..5..5}
for ((i=$LOOP_START; i <=$LOOP_STOP; i+= $LOOP_STEP))
do

    echo -n "$i.."
START=$i
END=$((i+5))

cat cut.xml | sed  "s/START/${i}/"    > tmp.xml
cat tmp.xml | sed  "s/END/${END}/" > cut-tmp.xml
rm tmp.xml


$PARAMEDIR -c $TRACE cut-tmp.xml $CFG

AVG=$(grep Average $CFG_BASE | cut -f2 -d$'\t')
MAX=$(grep Maximum $CFG_BASE | cut -f2 -d$'\t')
LB=$(grep Avg $CFG_BASE | cut -f2 -d$'\t')




NAME=$BASE"-"$RANKS"-"$START"-"$END"__Avg_Max_LB_"$AVG"_"$MAX"_"$LB"_img"

$PARAVER $CHOP $CFG_IMG -i

IMG_NAME_BASE=$CFG_IMG_BASE"@"$CHOP_BASE

#eog $IMG_NAME_BASE.png
mv $IMG_NAME_BASE.png $NAME.png

#eog $NAME.png
#Check if quality decreases / alternatively change sources to save directly as jpg
#Requires Imagemagick
convert $NAME.png $NAME.jpg

mv $NAME.jpg imgs/

# Clean up
rm $CHOP_BASE*
rm cut-tmp.xml
rm $CFG_BASE
rm $IMG_NAME_BASE.code.png
rm $NAME.png
done

echo "done"
TIMER_END=$(date +%s.%N)
TOTAL_TIME=$(echo "$TIMER_END - $TIMER_START" | bc)
#printf "Time elapsed: %0.2f s\n" $TOTAL_TIME

echo "Time elapsed: $TOTAL_TIME s"
