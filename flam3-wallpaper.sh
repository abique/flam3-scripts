#! /bin/bash

sheepid=$1
flam3_url=http://v2d7c.sheepserver.net/gen/244/$sheepid/electricsheep.244.$sheepid.flam3
screen_w=0
screen_h=0
flam_w=0
flam_h=0
ss_w=1
ss_h=1
ss=1

if [[ $# -ne 1 ]] ; then
    echo usage: "$0" sheepid
    exit 1
fi

# fetch screen size
IFS="${IFS}x" read screen_w screen_h garbage <<<"$(xrandr 2>/dev/null | grep '\*')"

echo found resolution: ${screen_w}x${screen_h}

if ! [[ -r $sheepid.flam3 ]] ; then
    wget "$flam3_url" -O $sheepid.flam3
fi

read flam_w flam_h <<<$(sed -n 's/.*size="\([0-9]\+\) \([0-9]\+\)".*/\1 \2/p' $sheepid.flam3)

echo sheep size: ${flam_w}x${flam_h}

ss_h=$((100 * ${screen_h} / ${flam_h}))
ss_w=$((100 * ${screen_w} / ${flam_w}))

if [[ $ss_h -le $ss_w ]]; then
    ss=$ss_h
    flam_w=$((100 * ${screen_w} / ${ss}))
else
    ss=$ss_w
    flam_h=$((100 * ${screen_h} / ${ss}))
fi

echo new sheep size: ${flam_w}x${flam_h}, scale factor \* 100: $ss_h

sed -i 's/size="[0-9]\+ [0-9]\+\"/size="'$flam_w' '$flam_h'"/g' $sheepid.flam3

ss=$(echo $ss / 100 | bc -l) out=$sheepid-${screen_w}x${screen_h}.png in=$sheepid.flam3 flam3-render
