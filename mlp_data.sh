#!/bin/bash -x

#set -x

filename="jenkins"
echo "-----BEGIN OPENSSH PRIVATE KEY-----
kay
-----END OPENSSH PRIVATE KEY-----" > $filename

chmod 400 ./$filename

mkdir -p /tmp/deployment_statsu/fetching_model_id_and_version
FILE="fetch_model_status.txt"
LOG_FILE="/tmp/deployment_statsu/fetching_model_id_and_version/$FILE"

#DATE=$(date  --date="yesterday" +"%Y-%m-%d")
DATE=$(date  --date='2 days ago' +"%Y-%m-%d")

produce_output DATE $DATE
echo "Fetching $DATE.json file" | tee $LOG_FILE

function model(){
BUCKET='PROD'
GET_URL="http://${GET_URL_IP_PROD}:${GET_URL_PORT_PROD}/sherlock/personalization/get_model_state?zone=$1&bucket=${BUCKET}"
DATA_URL=`curl -X GET --header 'Accept: application/json' ''${GET_URL}''`

  GET_MODEL_ID=`echo $DATA_URL | jq '.activeModelId' | sed 's/"//g'`
  echo $GET_MODEL_ID
  GET_MODEL_VERSION=`echo $DATA_URL | jq '.activeModelVersion' | sed 's/"//g'`
  echo $GET_MODEL_VERSION
}

TARGET_FOLDER="sudo -u fk-hadoop-search hadoop fs -cat hdfs://arjuna/projects/search/ranking/L2_automation/retraining/job_status/${DATE}.json"
#TARGET_FOLDER="sudo -u fk-hadoop-search hadoop fs -cat hdfs://arjuna/projects/search/ranking/L2_automation/retraining/status_update/${DATE}-log.json"
BOX_IP=10.32.139.15


JSON_DATA=`ssh -o "StrictHostKeyChecking=no" -i ./$filename nageswara.rao@$BOX_IP ${TARGET_FOLDER}`;

if [ $? -eq 0 ]
then
  echo -e "============================ Fetching Json file status from HDFS storage ===========================\n\n" | tee -a $LOG_FILE

	echo -e "Hdfs file path: hdfs://arjuna/projects/search/ranking/L2_automation/retraining/job_status/${DATE}.json, File exist in the hdfs storage\n" | tee -a $LOG_FILE

	echo -e "+++++++++++++++ Fetching the model_id and version ++++++++++++++++\n\n" | tee -a $LOG_FILE
	
  MODEL_ID=`echo $JSON_DATA | jq -r '.["model_id"]'`
  MODEL_VERSION=`echo $JSON_DATA | jq -r '.["model_version"]'`
  produce_output MODEL_ID $MODEL_ID
  produce_output MODEL_VERSION $MODEL_VERSION
  #MODEL_ID='MD59818'
  echo -e "Fetching model id version from the json file: \nModel id: $MODEL_ID\nModel Version: $MODEL_VERSION \n\n" | tee -a $LOG_FILE
  
  if [[ $MODEL_ID == None && $MODEL_VERSION == None ]]; then echo "Model id and version are null.." | tee -a $LOG_FILE; echo "$JSON_DATA" | tee -a $LOG_FILE; exit1 ; else echo "Fetched model id and version not null..continuning..." | tee -a $LOG_FILE ; fi 
  HYD_DATA=$(model in-hyderabad-1)
  HYD_MODEL_ID=$(echo $HYD_DATA | awk '{print $1}')
  HYD_MODEL_VERSION=$(echo $HYD_DATA | awk '{print $2}')
  produce_output HYD_MODEL_ID $HYD_MODEL_ID
  produce_output HYD_MODEL_VERSION $HYD_MODEL_VERSION
  echo "Active model id and version in HYD zone Model Id: $HYD_MODEL_ID, Model Version: $HYD_MODEL_VERSION" | tee -a $LOG_FILE
  
  [[ -n $HYD_MODEL_ID ]] && echo "HYD Active deployment model id not null..." || exit 1 
  [[ -n $HYD_MODEL_VERSION ]] && echo "Hyd Active deployment model version not null..." || exit 1
  CH_DATA=$(model in-chennai-1)
  CH_MODEL_ID=$(echo $CH_DATA | awk '{print $1}')
  CH_MODEL_VERSION=$(echo $CH_DATA | awk '{print $2}')
  produce_output CH_MODEL_ID $CH_MODEL_ID
  produce_output CH_MODEL_VERSION $CH_MODEL_VERSION
  
  [[ -n $CH_MODEL_ID ]] && echo "CH Active deployment model id not null..." || exit 1 
  [[ -n $CH_MODEL_VERSION ]] && echo "CH Active deployment model version not null..." || exit 1
  echo "Active model id and version in CH zone Model Id: $CH_MODEL_ID, Model Version: $CH_MODEL_VERSION" | tee -a $LOG_FILE
  
    if [[ $MODEL_ID == $HYD_MODEL_ID  && $MODEL_ID == $CH_MODEL_ID ]]
        then
        echo "Model Id is up to date continue to check with version... " | tee -a $LOG_FILE
        if [[ $MODEL_VERSION == $CH_MODEL_VERSION && $MODEL_VERSION == $HYD_MODEL_VERSION ]]
        then
            echo "Model id and version are all ready exist in the active deployments,Hence deployment going to failed" | tee -a $LOG_FILE
            exit 1
        else
            echo "Updating Model version is diff continuing with deployment" | tee -a $LOG_FILE
            
        fi
    else
        echo "Continuing... the deployment with latest model id and version" | tee -a $LOG_FILE
        
    fi
  
else
	echo "hdfs://arjuna/projects/search/ranking/L2_automation/retraining/job_status/${DATE}.json doesn't exist in the hdfs storage" | tee -a $LOG_FILE
	echo "Retraining is not completed for $DATE date." | tee -a $LOG_FILE
	exit 1
fi

######################################################################################################################################
#!/bin/bash
#SSH Key details


filename="jenkins"
echo "-----BEGIN OPENSSH PRIVATE KEY-----
-----END OPENSSH PRIVATE KEY-----" > $filename

chmod 400 ./$filename

MLP_BOX_IP=10.34.15.210

mkdir -p /tmp/deployment_statsu/dockerization
DATE=$(date +"%Y-%m-%d")
log=$(dockerization_log_${DATE}.txt)

FILE="dockerization_status_${DATE}.txt"
LOG_FILE="/tmp/deployment_statsu/dockerization_status/$FILE"
mkdir -p /tmp/deployment_statsu/dockerization_status/

#Dockerization command

MLP_HUNCH_COMMAND="hunch model dockerize --model-id $MODEL_ID --model-version $MODEL_VERSION"

if [[ $MODEL_ID == 'None' && $MODEL_VERSION == 'None' ]]
  then
      echo -e "================== Model ID and Version not generated =====================================\n\n" | tee -a $LOG_FILE
      echo "Model ID and Model version values are Model ID: $MODEL_ID, Model version: $MODEL_VERSION" | tee -a $LOG_FILE
      echo "Please check $DATE.json file in hdfs://arjuna/projects/search/ranking/L2_automation/retraining/job_status/ path" | tee -a $LOG_FILE
      exit 1
  else
      echo -e "++++++++++++++ Model id and Model version are successfuly generated and it's ready to dockerization +++++++\n\n" | tee -a $LOG_FILE
      echo -e "Dockerization command:- $MLP_HUNCH_COMMAND\n\n" | tee -a $LOG_FILE
      echo -e "====================== Dockerization Status ==========================\n\n" | tee -a $LOG_FILE
      `ssh -o "StrictHostKeyChecking=no" -i ./$filename nageswara.rao@$MLP_BOX_IP "export ML_SDK_CONF_BUCKET=prod-ml-platform-sdk && ${MLP_HUNCH_COMMAND}" &> docker_status`
      VALIDATION=$?
      STATUS=`cat docker_status | grep 'Exception'`

      if [[ $VALIDATION -eq 0 ]]
      then
	        echo " Dockerization completed successfully" | tee -a $LOG_FILE
	        STATUS=`cat docker_status | grep 'successfully'`
          echo "============ Dockerization Status: $status=================" | tee -a $LOG_FILE
          cat docker_status | tee -a $LOG_FILE

      elif [[ $STATUS == "Exception: Model image already exists. To overwrite the image, set the force flag" ]]
      then
	        echo "$STATUS" | tee -a $LOG_FILE
	    else
	        echo "Error while Dockerization" | tee -a $LOG_FILE
	        cat docker_status | tee -a $LOG_FILE
	        exit 1 
      fi

  fi
  
######################################################################################################################################
#!/bin/bash

cd /root
FILE="deployment_template_status_$(date +"%Y-%m-%d")_${ZONE}.txt"
LOG_FILE="/tmp/deployment_statsu/deployment_template_status/$FILE"
mkdir -p /tmp/deployment_statsu/deployment_template_status/
echo $LOG_FILE

produce_output ZONE $ZONE

if [[ $ZONE == "in-chennai-1" ]]
then
  echo "checking kubebconfig file available or not" |  tee $LOG_FILE
  if [ -r "alm-beta-search-modelhost.yml" ]
  then
      echo "======================== KUBECONFIG file available and it's exported ========================\n" | tee -a $LOG_FILE
      export KUBECONFIG=/root/alm-beta-search-modelhost.yml
      echo "KUBECONFIG expoeted with exit code $?" | tee -a $LOG_FILE
  else
      echo "+++++++++++++++++ Kubeconfig file not available Please check....." | tee -a $LOG_FILE
      exit 1
  fi
  else
    echo "Given input zone is not chennai" | tee -a $LOG_FILE
    exit 1
fi
HUNCH_PATH="/opt/conda/envs/hunch/bin/"
#Deployment zone model id and versions
echo "======================= Deployment Zone:$ZONE, Bucket name:$BUCKET , Model Id: $MODEL_ID and Model Version: $MODEL_VERSION ============================================= " | tee -a $LOG_FILE

echo "++++++ Deployment list in $ZONE Zone +++++++++++" | tee -a $LOG_FILE
#List the deployment in particular zone
${HUNCH_PATH}hunch model-deploy list

echo "================== Fetching INACTIVE Deployment details with GET API Call =====================" | tee -a $LOG_FILE
GET_URL="http://${GET_URL_IP_PROD}:${GET_URL_PORT_PROD}/sherlock/personalization/get_model_state?zone=${ZONE}&bucket=${BUCKET}"
echo GET_URL: "curl -X GET --header 'Accept: application/json' ''${GET_URL}''" | tee -a $LOG_FILE
#data=`curl -X GET --header 'Accept: application/json' 'http://10.24.11.136:25280/sherlock/personalization/get_model_state?zone=in-chennai-1&bucket=PROD'`
DATA_URL=`curl -X GET --header 'Accept: application/json' ''${GET_URL}''`

if [[ $? -eq 0 && -n $MODEL_ID && -n $MODEL_VERSION ]]
then
    
    echo -e "================== Currently active and Inactive deployments in $ZONE DC ===========================\n\n" | tee -a $LOG_FILE
    echo $DATA_URL
    inactive_deployment_name=$(echo $DATA_URL | jq '.models.INACTIVE[].name' | sed 's/"//g')
    #inactive_deployment_name="test-vectr-logs"
    active_deployment_name=$(echo $DATA_URL | jq '.models.ACTIVE[].name' | sed 's/"//g')
    [[ -n $inactive_deployment_name ]] && echo "Inactive deployment is not null" || exit 1 
    [[ -n $active_deployment_name ]] && echo "Active deployment is not null" || exit 1
    produce_output INACTIVE_DEPLOYMENT_NAME $inactive_deployment_name
    produce_output ACTIVE_DEPLOYMENT_NAME $active_deployment_name
    echo "++++++++++++++++++++++++++++++++++++++++++++++" | tee -a $LOG_FILE
    echo Active Deployment: "$active_deployment_name" | tee -a $LOG_FILE
    echo Inactive Deployment "$inactive_deployment_name" | tee -a $LOG_FILE
    echo "++++++++++++++++++++++++++++++++++++++++++++++" | tee -a $LOG_FILE
    ${HUNCH_PATH}hunch model-deploy describe --deployment $inactive_deployment_name > deployment
    echo "**********************************************************************" | tee -a $LOG_FILE
    echo "Describe Inactive deployment $inactive_deployment_name" | tee -a $LOG_FILE
    echo "++++++++++++++++++++++++++++++++++++++++++++++" | tee -a $LOG_FILE
    cat deployment
    echo -e "\n**********************************************************************" | tee -a $LOG_FILE
    INACTIVE_DEPLOYMENT_MODEL_ID=$(cat deployment | grep "Model Id" | awk -F ":" '{ print $2 }' | sed 's/ //g')
    INACTIVE_DEPLOYMENT_MODEL_VERSION=$(cat deployment | grep "Model Version" | awk -F ":" '{ print $2 }' | sed 's/ //g')
    INACTIVE_DEPLOYMENT_ELB=$(cat deployment | grep "ELB" | awk -F ":" '{ print $2 }' | sed 's/ //g')
    cpu=`cat deployment | grep cpu | awk -F ":" 'NR==1{ print $2 }'`
    memory=`cat deployment | grep memory | awk -F ":" '{ print $2 }'`
    replicas=`cat deployment | grep Replicas | awk -F " " '{ print $2 }'`
    #replicas='145'
    #memory='7G'
    produce_output REPLICAS $replicas
    produce_output INACTIVE_DEPLOYMENT_MODEL_ID $INACTIVE_DEPLOYMENT_MODEL_ID
    produce_output INACTIVE_DEPLOYMENT_MODEL_VERSION $INACTIVE_DEPLOYMENT_MODEL_VERSION
    produce_output INACTIVE_DEPLOYMENT_ELB $INACTIVE_DEPLOYMENT_ELB
    echo -e "\n********* Fetch Replica, Memory, and Cpu details from Inactive deployment $inactive_deployment_name ************" | tee -a $LOG_FILE
    echo "Replica: $replicas, memory: $memory, cpu: $cpu and name: $inactive_deployment_name" | tee -a $LOG_FILE
    echo "Model id: $MODEL_ID, Model Version: $MODEL_VERSION will update in Inactive deployment" | tee -a $LOG_FILE
    #name='test-log'
    name="$inactive_deployment_name"
    #echo "++++++++ Updated template with Model id and Model version  ++++++++++++"
    #echo "sed -e "s/MD...*/$MODEL_ID/" -e "s/name:...*/name: $name/" -e "s/version:....*/version: $MODEL_VERSION/" -e "s/cpu:....*/cpu: $cpu/" -e "s/memory:....*/memory: $memory/" -e "s/replica_count:.*/replica_count: $replicas/" test_deployment.yml"

    sed -e "s/MD...*/$MODEL_ID/" -e "s/name:...*/name: $name/" -e "s/version:....*/version: $MODEL_VERSION/" -e "s/replica_count:.*/replica_count: $replicas/" -e "s/cpu:....*/cpu: $cpu/" -e "s/memory:....*/memory: $memory/" /root/template-mlp-model-deployment.yaml > /tmp/deployment_statsu/updated_template.yaml

    if [[ $? -eq 0 ]] && echo "Template updated successfully"; then echo "Template updated successfully"; else echo "Template not updated" && exit 1 ; fi
    echo "++++++++ Updated template for mlp deployment ++++++++++++++++++++++" | tee -a $LOG_FILE
    cat /tmp/deployment_statsu/updated_template.yaml
else
    echo "GET URL not working or Model id and Model version null please check..........." | tee -a $LOG_FILE
    echo "Model ID:$MODEL_ID  Model Version: $MODEL_VERSION " | tee -a $LOG_FILE
    echo GET_URL "curl -X GET --header 'Accept: application/json' ''${GET_URL}''" | tee -a $LOG_FILE

fi

ls -ltr /tmp/deployment_statsu/deployment_template_status/


######################################################################################################################################
#!/bin/bash

cd /root
#DATE=`date +"%Y-%m-%d"`
ZONE="in-chennai-1"
FILE="$(date +"%Y-%m-%d")_${ZONE}_deployment_log.txt"
LOG_FILE_PATH="/tmp/deployment_statsu/deployment_model_status/${ZONE}/$FILE"
mkdir -p /tmp/deployment_statsu/deployment_model_status/${ZONE}
echo $LOG_FILE_PATH

if [[ $ZONE == "in-chennai-1" ]]
then
  echo "checking kubebconfig file available or not" |  tee -a $LOG_FILE_PATH
  if [ -r "alm-beta-search-modelhost.yml" ]
  then
      echo "======================== KUBECONFIG file available and it's exported ========================\n" | tee -a $LOG_FILE_PATH
      export KUBECONFIG=/root/alm-beta-search-modelhost.yml
      echo "KUBECONFIG expoeted with exit code $?" | tee -a $LOG_FILE_PATH
  else
      echo "+++++++++++++++++ Kubeconfig file not available Please check....." | tee -a $LOG_FILE_PATH
      exit 1
  fi
  else
    echo "Given input zone is not chennai" | tee -a $LOG_FILE_PATH
    exit 1
fi
HUNCH_PATH="/opt/conda/envs/hunch/bin/"
cat $UPDATED_TEMPLATE_FILE

    echo "Existing Inactive deployment Model Id and Version:"
    echo "Model Id:" $INACTIVE_DEPLOYMENT_MODEL_ID
    echo "Model Version:" $INACTIVE_DEPLOYMENT_MODEL_VERSION

 if [[ $INACTIVE_DEPLOYMENT_MODEL_ID == $CH_MODEL_ID && $INACTIVE_DEPLOYMENT_MODEL_VERSION == $CH_MODEL_VERSION ]]
    then
      echo "Existing Inactive deployment is UpToDate with latest Model Id and Version, Hence skipping the deployment. ELB validation and Model switching steps will be skipped "
       UPDATE_STATUS=failed  
       produce_output UPDATE_STATUS $UPDATE_STATUS
      
    else
      echo "Existing Inactive deployment is Not UpToDate with latest Model Id and Version, continuing the deployment"
      
      ${HUNCH_PATH}hunch model-deploy update --file $UPDATED_TEMPLATE_FILE > status
      [[ $? -eq 0 ]] && echo "Deployment update command executed successfully" || exit 1 
      sleep 2m
      a=0
      #[ $a -lt 5 ]
        while [ $a -lt 5 ]
        do
            ${HUNCH_PATH}hunch model-deploy describe --deployment $INACTIVE_DEPLOYMENT_NAME > update_deployment

            echo status $? | tee -a $LOG_FILE
            echo "*****Updatd deployment file**********" | tee -a $LOG_FILE
            cat update_deployment | tee -a $LOG_FILE
            sleep 2m
            #DEPLOYED_REPLICAS=`cat update_deployment | grep Replicas `
            UPDATED_MODEL=`cat update_deployment | grep "Model Id" | awk -F ":" '{ print $2 }' | sed -e 's/ //'`
            UPDATED_MODEL_VERSION=`cat update_deployment | grep "Model Version" | awk -F ":" '{ print $2 }' | sed -e 's/ //'`
            UPDATED_REPLICA=`cat update_deployment | grep Replicas | awk -F ":" '{ print $2 }' | awk -F "|" '{print $1}' | awk -F " " '{ print $1 }'`
            UPDATED_AVAILABLE=`cat update_deployment | grep Replicas | awk -F ":" '{ print $2 }' | awk -F "|" '{print $2}' | awk -F " " '{ print $1 }'`
            UPDATED_UNAVAILABLE=`cat update_deployment | grep Replicas | awk -F ":" '{ print $2 }' | awk -F "|" '{print $3}' | awk -F " " '{ print $1 }'`
            echo "Updated Model ID: $UPDATED_MODEL  , Updated version Model Version: $UPDATED_MODEL_VERSION " | tee -a $LOG_FILE
            echo "Replicas: $UPDATED_REPLICA total | $UPDATED_AVAILABLE Available | $UPDATED_UNAVAILABLE Unavailable" | tee -a $LOG_FILE
            echo Replicas $replicas | tee -a $LOG_FILE
                if [[ $UPDATED_REPLICA -eq $REPLICAS && $UPDATED_AVAILABLE -eq $REPLICAS && $UPDATED_UNAVAILABLE == None && $UPDATED_MODEL_VERSION == $MODEL_VERSION && $UPDATED_MODEL == $MODEL_ID ]]
                then
                    echo "++++++++++++++++++++ Deployment succeeded......+++++++++++++++++++++++++++++" | tee -a $LOG_FILE
                    echo "Replicas: $UPDATED_REPLICA total | $UPDATED_AVAILABLE Available | $UPDATED_UNAVAILABLE Unavailable" | tee -a $LOG_FILE
                    UPDATE_STATUS=success 
                    produce_output UPDATE_STATUS $UPDATE_STATUS
                    cat update_deployment | tee -a $LOG_FILE
                    break
                    #exit 0
                else

                    printf " Replicas or model id not updated please check...." | tee -a $LOG_FILE
                    echo "Replicas: $UPDATED_REPLICA total | $UPDATED_AVAILABLE Available | $UPDATED_UNAVAILABLE Unavailable" | tee -a $LOG_FILE
                    echo "Updated Model ID: $UPDATED_MODEL  , Updated version Model Version: $UPDATED_MODEL_VERSION " | tee -a $LOG_FILE
                    echo "Fetching Model Id: $MODEL_ID and Model Version: $MODEL_VERSION" | tee -a $LOG_FILE
                fi
                    echo $a | tee -a $LOG_FILE
                    echo "Replicas: $UPDATED_REPLICA total | $UPDATED_AVAILABLE Available | $UPDATED_UNAVAILABLE Unavailable" | tee -a $LOG_FILE
                    a=`expr $a + 1`
                    sleep 3m
                    UPDATE_STATUS=failed
                    produce_output UPDATE_STATUS $UPDATE_STATUS
    done

      
fi

echo "Deployment updated status: $UPDATE_STATUS"
if [[ $UPDATE_STATUS == "success" ]] ; then echo "Replicas updated successfully" ; else echo "Replicas not updated, Updated status:$UPDATE_STATUS " && exit 1 ; fi

cp $LOG_FILE /tmp/deployment_statsu/deployment_model_status/

ls -ltr 
ls -ltr /tmp/deployment_statsu/deployment_model_status/
pwd

############################################################################
#!/bin/bash 

#set -x 


FILE="$(date +"%Y-%m-%d")_${ZONE}_model_validation_log.txt"
LOG_FILE_PATH="/tmp/deployment_statsu/end_point_switch/${ZONE}/$FILE"
mkdir -p /tmp/deployment_statsu/end_point_switch/${ZONE}

echo $LOG_FILE_PATH

echo "Before Switching The End Points Active and Inactive Deployment Details in $ZONE zone" | tee -a $LOG_FILE_PATH

echo "++++++++++++++++++++++++++++++++++++++++++++++" | tee -a $LOG_FILE_PATH
echo Active Deployment: "$ACTIVE_DEPLOYMENT_NAME"  | tee -a $LOG_FILE_PATH
echo Inactive Deployment "$INACTIVE_DEPLOYMENT_NAME"  | tee -a $LOG_FILE_PATH

echo "curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ \
 \""zone"\": \""$ZONE"\", \
 \""bucket"\": \""PROD"\", \
 \""context"\": \""PROD"\", \
 \""marketplace"\": \""FLIPKART"\", \
 \""activeModelName"\": \""$INACTIVE_DEPLOYMENT_NAME"\", \
 \""modelId"\": \""$MODEL_ID"\", \
 \""modelVersion"\": \""$MODEL_VERSION"\", \
 \""updateNotes"\": {\""updated_by"\":\""Jaguar_prod_deployment_pipeline"\"} \
 }' 'http://${PROD_POST_URL_IP}:${PROD_POST_URL_PORT}/sherlock/personalization/update_model_config'" > switch_$ZONE.sh 
 
cat switch_$ZONE.sh | tee -a $LOG_FILE_PATH
 
bash switch_$ZONE.sh | tee -a $LOG_FILE_PATH

[[ $? -eq 0 ]] && echo -e "\n \n Model switch completed successfully in $ZONE" || exit 1



echo "After Switching The End Points in $ZONE zone" | tee -a $LOG_FILE_PATH

GET_URL="http://10.47.100.34:25280/sherlock/personalization/get_model_state?zone=${ZONE}&bucket=PROD"
echo GET_URL: "curl -X GET --header 'Accept: application/json' ''${GET_URL}''"  | tee -a $LOG_FILE_PATH
#data=`curl -X GET --header 'Accept: application/json' 'http://10.24.11.136:25280/sherlock/personalization/get_model_state?zone=in-chennai-1&bucket=PROD'`
DATA_URL=`curl -X GET --header 'Accept: application/json' ''${GET_URL}''`
echo $DATA_URL | tee -a $LOG_FILE_PATH

echo "sleeping 10min before switching the next endpoint"
sleep 10m 

############################ File validation #####################
#!/bin/bash
MAILCC='nageswara.rao@flipkart.com'
MAILTO='nageswara.rao@flipkart.comi,sanjoli.watts@flipkart.com'
MAILFROM='nageswara.rao@flipkart.com'
DIR='/grid/1/devs/nageswara.rao'
FILE='hl_ranking_inputfile.csv'
INPUTFILE=`ls $DIR/$FILE`
FSN='fsn'
VERTICAL='vertical'
RANK='rank'
echo $INPUTFILE
if [ ! -e $DIR/$INPUTFILE ]
   then 
      for i in $( ls hl_ranking_inputfile.csv)
      do 

	DATA=$( cat $DIR/$i | awk 'BEGIN { FS = ","} NF !=3 { print "Record No", NR, "has",NF, "Fields " $0 }')
	LINES=$( cat $DIR/$i | awk 'BEGIN { FS = ","} NF !=3 { print "Record No", NR, "has",NF, "Fields"}'|wc -l )
	FILE_FSN=$( head -n 1 $DIR/$i | awk -F "," '{print $1}'| sed -e 's/\r//g')
	FILE_VERTICAL=$( head -n 1 $DIR/$i | awk -F "," '{print $2}' | sed -e 's/\r//g')
	FILE_RANK=$( head -n 1 $DIR/$i | awk -F "," '{print $3}' | sed -e 's/\r//g')
        echo "$FSN $VERTICAL $RANK"
        echo "$DATA"
        DUPLICATE_RECORD=$(tail -n +2 $DIR/$i | sort | uniq -d  )
        DUPLICATES=$(tail -n +2 $DIR/$i | sort | uniq -d | wc -l )
	if [[ $FSN = $FILE_FSN && $VERTICAL = $FILE_VERTICAL && $RANK = $FILE_RANK ]]
 	then 
  	 if [[ $LINES -eq 0 && $DUPLICATES -eq 0 ]]
  	  then
          ( echo "To: $MAILTO"
                 echo "Cc: $MAILCC"
                 echo "From: $MAILFROM"
                 echo "Subject: Hl Weight Input file validated successfully"
                 echo "MIME-Version: 1.0"
                 echo "Content-Type: text/plain"
                 echo -e "$i file will be used for the next HL Search ranking RPI update"
                 echo -e "Input file path $DIR\n $(ls -ltr $DIR/$i)\n"
                 echo cat "$i" 
                 cat $DIR/$i ) | /usr/sbin/sendmail -t  
   	  else
  		 ( echo "To: $MAILTO"
 		 echo "From: $MAILFROM"
 		 echo "Subject: Hl Weight Input file Records Mismatch/Duplicates"
 		 echo "MIME-Version: 1.0"
 		 echo "Content-Type: text/plain"
  		 echo -e "$i file has duplicate records "
  		 echo -e "Input file path $DIR\n $(ls -ltr $DIR/$i)\n"
                 echo -e "Please take action on below Records"
                 echo -e "Number off duplicate records Hello $DUPLICATES \n\n$DUPLICATE_RECORD\n\n"
  		 echo -e "Number off mismatched records $LINES"
                 echo ""
                 echo "$DATA" ) | /usr/sbin/sendmail -t
         fi
     else 
  	( echo "To: $MAILTO"
  	echo "From: $MAILFROM"
  	echo "Subject: Hl weight inputfile headers are invalid"
  	echo "MIME-Version: 1.0"
  	echo "Content-Type: text/plain"
  	echo -e "$i file headers are not good in inputfile"
        echo ""
  	echo -e "Inputfile path $DIR\n $(ls -ltr $DIR/$i)"
        echo -e "Standard input file headers must be \nfsn,vertical,rank" 
        echo ""
  	echo -e "What we have in the input file header\n $FILE_FSN,$FILE_VERTICAL,$FILE_RANK " ) | /usr/sbin/sendmail -t
 fi
done
else 
 ( echo "To: $MAILTO"
        echo "From: $MAILFROM"
        echo "Subject: Input file hl_ranking_inputfile.csv not available in path $DIR"
        echo "MIME-Version: 1.0"
        echo "Content-Type: text/plain"
        echo -e "Input file name is unique it should be hl_ranking_inputfile.csv " 
        echo -e ls -ltr "$DIR"
        echo -e "$(ls -ltr $DIR | tail -n +2 )") | /usr/sbin/sendmail -t
fi

################# Log fetch #########################################

#!/bin/bash
fetch(){
DATE=$(date  --date="yesterday" +"%Y-%m-%d")
cd /grid/1/devs/nageswara.rao/k8s_logs/

QUERY="SELECT message,utc_date,hour,minute,second from search_3modelhost.$2 where utc_date='"${DATE}"' and (message like '%debug%' or message like '%stack_trace%' or message like '%product-id%' or message like '%probability%')ORDER BY hour,minute,second ASC"
echo $QUERY
mkdir -p /grid/1/devs/nageswara.rao/k8s_logs/MLP_k8s_logs/$1/$3/${DATE}

java -jar hivejdbc-1.0_$1.jar "${QUERY}" > /grid/1/devs/nageswara.rao/k8s_logs/MLP_k8s_logs/$1/$3/${DATE}/${DATE}_output_$(date +"%Y%m%d_%H%M%S").log
sleep 5
}

fetch_prod(){
DATE=$(date  --date="yesterday" +"%Y-%m-%d")
cd /grid/1/devs/nageswara.rao/k8s_logs/

QUERY="SELECT message,utc_date,hour,minute,second from search_3modelhost.$2 where utc_date='"${DATE}"' and (message like '%debug%' or message like '%stack_trace%' or message like '%product-id%' or message like '%probability%')ORDER BY hour,minute,second ASC"
echo $QUERY
mkdir -p /grid/1/devs/nageswara.rao/k8s_logs/MLP_prod_k8s_logs/$1/$3/${DATE}

java -jar hivejdbc-1.0_$1.jar "${QUERY}" > /grid/1/devs/nageswara.rao/k8s_logs/MLP_prod_k8s_logs/$1/$3/${DATE}/${DATE}_output_$(date +"%Y%m%d_%H%M%S").log
sleep 5
}


fetch ch_prod test_3l2_3model_3modelhost test-l2-model
fetch hyd_prod test_3l2_3model_3hyd_3modelhost test-l2-model-hyd
fetch ch_prod test_3l2_3model_32_3modelhost test-l2-model-2
fetch hyd_prod test_3l2_3model_3hyd_32_3modelhost test-l2-model-hyd-2



fetch_prod hyd_prod prod_3l2_3model_3hyd_3modelhost prod-l2-model-hyd
fetch_prod hyd_prod prod_3l2_3model_3hyd_32_3modelhost prod-l2-model-hyd-2
fetch_prod ch_prod prod_3l2_3model_3modelhost prod-l2-model
fetch_prod ch_prod prod_3l2_3model_32_3modelhost prod-l2-model-2



