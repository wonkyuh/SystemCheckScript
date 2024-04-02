LOG=check.log
RESULT=result.log
> $LOG
> $RESULT

#
# (1) Operating System 
#

function Banner(){
cat << EOF 
  +============================================================================+  
  |                                                                            |
  |                         Linux System Checker Script                        |
  |                                - project -                                 |
  |                                                                            |
  |                                                                            |
  |                                                                            |
  +============================================================================+
                                 [ $NUM / 73 ]

EOF
NUM=`expr $NUM + 1`
}

function F_Banner(){
cat << EOF 
  +============================================================================+    
  |                                                                            |
  |                         Linux System Checker Script                        |
  |                                - project -                                 |
  |                                                                            |
  |                                                                            |
  |                                                                            |
  +============================================================================+
                                  [ Finish ]
                             [ check report.txt ]

EOF
}


#
# (2) for All ===============================================================================
#

BAR() {
echo "========================================================================" >> $RESULT
}

NOTICE() {
echo '[ OK ] : 정상'
echo '[WARN] : 비정상'
echo '[INFO] : Information 파일을 보고, 고객과 상의'
}

OK() {
echo -e '\033[32m'"[ 양호 ] : $*"'\033[0m'
} >> $RESULT

WARN() {
echo -e '\033[31m'"[ 취약 ] : $*"'\033[0m'
} >> $RESULT

INFO() { 
echo -e '\033[35m'"[ 정보 ] : $*"'\033[0m'
} >> $RESULT

CODE(){
echo -e '\033[36m'$*'\033[0m' 
} >> $RESULT

SCRIPTNAME() {
basename $0 | awk -F. '{print $1}' 
}

#
# (3) for Some ==================================================================================
#

FindPatternReturnValue() {
# $1 : File name
# $2 : Find Pattern
if egrep -v '^#|^$' $1 | grep -q $2 ; then # -q = 출력 내용 없도록
	ReturnValue=$(egrep -v '^#|^$' $1 | grep $2 | awk -F= '{print $2}')
else
	ReturnValue=None
fi
echo $ReturnValue
}

IsFindPattern() {
if egrep -v '^#|^$' $1 | grep -q $2 ; then # 라인의 처음이#, 라인의 처음이 마지막으로 되어있는
	ReturnValue=$?
else
	ReturnValue=$?
fi
echo $ReturnValue
}

PAM_FindPatternReturnValue() {
PAM_FILE=$1
PAM_MODULE=$2
PAM_FindPattern=$3
LINE=$(egrep -v '^#|^$' $PAM_FILE | grep $PAM_MODULE)
if [ -z "$LINE" ] ; then #내용이 없으면 (zero면) None을 출력
	ReturnValue=None
else
	PARAMS=$(echo $LINE | cut -d ' ' -f4-)
	# echo $PARAMS
	set $PARAMS
	while [ $# -ge 1 ]
	do
		CHOICE1=$(echo $* | awk '{print $1}' | awk -F= '{print $1}')
		CHOICE2=$(echo $* | awk '{print $1}' | awk -F= '{print $2}')
		# echo "$CHOICE1 : $CHOICE2"
		case $CHOICE1 in
			$PAM_FindPattern) ReturnValue=$CHOICE2 ;;
			*) : ;;		
		esac
		shift
	done
fi
echo $ReturnValue

CheckEncryptedPasswd() {
SFILE=$1
EncryptedPasswdField=$(grep '^root' $SFILE | awk -F: '{print $2}' | awk -F'$' '{print $2}')
#echo $EncryptedPasswdField
case $EncryptedPasswdField in
	1|2a|5) echo WarnTrue ;;
	6) echo TrueTrue ;;
	*) echo 'None' ;;
esac
}

SearchValue() {

SEARCH=$(egrep -v '^#|^$' $2 | sed 's/#.*//' | grep -w $3)
if [ -z "$SEARCH" ] ; then
	echo FALSE
else
	if [ $1 = 'KEYVALUE' ] ; then
	echo $SEARCH
elif [ $1 = 'VALUE' ] ; then
	echo "$SEARCH" | awk '{print $2}'
	fi
fi
}