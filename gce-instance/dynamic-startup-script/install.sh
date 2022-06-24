#!/bin/sh

DIRECTORY="tf"
SCRIPT_DIRECTORY="scripts"
FILE1="main.tf"
FILE1_URL="https://github.com/CloudVLab/cls-lab-scripts/raw/main/gce-instance/dynamic-startup-script/terraform/main.tf"
FILE2="outputs.tf"
FILE2_URL="https://github.com/CloudVLab/cls-lab-scripts/raw/main/gce-instance/dynamic-startup-script/terraform/outputs.tf"
FILE3="runtime.yaml"
FILE3_URL="https://github.com/CloudVLab/cls-lab-scripts/raw/main/gce-instance/dynamic-startup-script/terraform/runtime.yaml"
FILE4="variables.tf"
FILE4_URL="https://github.com/CloudVLab/cls-lab-scripts/raw/main/gce-instance/dynamic-startup-script/terraform/variables.tf"
FILE5="startup_script.tftpl"
FILE5_URL="https://github.com/CloudVLab/cls-lab-scripts/raw/main/gce-instance/dynamic-startup-script/terraform/startup_script.tftpl"

# Create TF directory if not present
if [ ! -d $DIRECTORY ]; then
  mkdir $DIRECTORY 
fi


# Create scripts directory if not present
if [ ! -d $SCRIPT_DIRECTORY ]; then
  mkdir $SCRIPT_DIRECTORY 
fi


# Download if the file does not exist
if [ ! -f $DIRECTORY/$FILE1 ]; then
curl -L $FILE1_URL -o "$DIRECTORY/$FILE1"
fi 

# Download if the file does not exist
if [ ! -f $DIRECTORY/$FILE2 ]; then
curl -L $FILE2_URL -o "$DIRECTORY/$FILE2"
fi

# Download if the file does not exist
if [ ! -f $DIRECTORY/$FILE3 ]; then
curl -L $FILE3_URL -o "$DIRECTORY/$FILE3"
fi

# Download if the file does not exist
if [ ! -f $DIRECTORY/$FILE4 ]; then
curl -L $FILE4_URL -o "$DIRECTORY/$FILE4"
fi

if [ ! -f $SCRIPT_DIRECTORY/$FILE5 ]; then
curl -L $FILE5_URL -o "$SCRIPT_DIRECTORY/$FILE5"
fi