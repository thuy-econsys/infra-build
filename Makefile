BUILD_PATH := $(dir $(firstword $(wildcard */packer/*)))
env := stage
VAR_FILE := $(filter %$(env).json,$(wildcard $(BUILD_PATH)*.json))
BUILD_FILES := $(wildcard $(BUILD_PATH)*/*.json)
OPTS = -debug -var-file=${VAR_FILE}
PIPED = | tee file.log

SRC_AMI := ami-04ccdf5793086ea95
BUILD := minimal-rhel-7-hvm

.PHONY: help check-setup 

help:
	@echo "       usage:    make <COMMAND>"
	@echo ""
	@echo "COMMANDs:"
	@echo ""
	@echo "        help:  - help menu"
	@echo " check-setup:  - ensure necessary packages are installed, and required Environment Variables set"
	@echo ""
	@echo "                 ### Packer ###"
	@echo ""
	@echo "                 Can be run as individual jobs, make <COMMAND>, or packed in groups"
	@echo "      syntax:    pack build -var-file=${VAR_FILE} ${BUILD_PATH}/<COMMAND>/<COMMAND>.json"
	@echo ""
	@echo "    pack-all:  - pack spel, forensics, harden as well as all downstream builds for pack-harden"
	@echo " pack-harden:  - pack harden, as well as all downstream builds: burp, dsm, jenkins, jumpbox, ldap, nessus, openvpn, splunk"
	@echo ""

check-setup:
	@if [ -z "$(shell aws --version)" ]; then echo "AWS CLI not installed"; else echo AWS account $(shell aws sts get-caller-identity --query Account); fi
	@if [ -z "$(shell packer -v)" ]; then echo "Packer not installed"; fi
	@if [ -z "$(shell terraform -v)" ]; then echo "Terraform not installed"; fi
	@if [ -z "$(shell terragrunt -v)" ]; then echo "Terragrunt not installed"; fi

	@if [ -z $$AWS_PROFILE ]; then echo "AWS_PROFILE needs to be set"; fi
	@if [ -z $$AWS_ACCESS_KEY_ID ]; then echo "AWS_ACCESS_KEY_ID needs to be set"; fi
	@if [ -z $$AWS_SECRET_ACCESS_KEY ]; then echo "AWS_SECRET_ACCESS_KEY needs to be set"; fi
	@if [ -z $$AWS_REGION ]; then echo "AWS_REGION needs to be set"; fi
	@if [ -z $$REMOTE_STATE_BUCKET ]; then echo "REMOTE_STATE_BUCKET needs to be set"; fi
	@if [ -z $$REMOTE_STATE_PROFILE ]; then echo "REMOTE_STATE_PROFILE needs to be set"; fi
	@if [ -z $$STATE_LOCK_DYNAMODB_TABLE ]; then echo "STATE_LOCK_DYNAMODB_TABLE needs to be set"; fi

pack-module:
ifeq ($(debug),)
	$(info not debugging)
else ifeq ($(debug),debug)
	$(info debugging)
endif

ifeq ($(log),)
	$(info not logging)
else ifeq ($(log),log)
	$(info logging)
endif

ifeq ($(module),)
	(@echo no module defined)
else ifeq ($(module), burp)
	$(info $(OPTS) $(filter %burp-update.json,$(BUILD_FILES)) $(PIPED))
else ifeq ($(module), dsm)
	$(info $(OPTS) $(filter %deep-security.json,$(BUILD_FILES)) $(PIPED))
else ifeq ($(module), nessus)
	$(info $(OPTS) $(filter %nessus-scanner.json,$(BUILD_FILES)) $(PIPED))
else ifeq ($(module), spel)
	$(info $(OPTS) $(filter %minimal-linux.json,$(BUILD_FILES)) $(PIPED))
else ifeq ($(module), $(module))
	$(info $(OPTS) $(filter %$(module).json,$(BUILD_FILES)) $(PIPED))
else
	$(error not sure if it gets here...)
endif


.PHONY: pack-harden pack-all

pack-harden: harden ldap openvpn jumpbox jenkins burp dsm nessus splunk

pack-all: spel forensics pack-harden

.PHONY: burp dsm forensics harden jenkins jumpbox ldap nessus openvpn spel splunk

burp:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/burpsuite/burp-update.json

dsm:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/deepsecurity/deep-security.json

forensics:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/forensics/forensics.json

harden:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/harden/harden.json

jenkins:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/jenkins/jenkins.json

jumpbox:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/jumpbox/jumpbox.json

ldap:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/ldap/ldap.json

nessus:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/nessus/nessus-scanner.json

openvpn:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/openvpn/openvpn.json

spel:
	@packer build -var-file=${VAR_FILE} -var source_ami_rhel7_hvm=${SRC_AMI} -only ${BUILD} ${BUILD_PATH}/spel/minimal-linux.json

splunk:
	@packer build -var-file=${VAR_FILE} ${BUILD_PATH}/splunk/splunk.json
