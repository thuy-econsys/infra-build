BUILD_PATH := $(dir $(firstword $(wildcard */packer/*)))
env := stage
VAR_FILE := $(filter %$(env).json,$(wildcard $(BUILD_PATH)*.json))
VARFILE_OPT := -var-file=${VAR_FILE}
BUILD_FILES := $(wildcard $(BUILD_PATH)*/*.json)
ECHO_CMD := @echo 
PACK_CMD := @packer build
PACK_OPT := ""
timestamp = $(shell date +%Y%m%d-%H%M)
LOGGER := ""

SRC_AMI := ami-04ccdf5793086ea95
AMI := minimal-rhel-7-hvm
SPEL_OPTS := -var source_ami_rhel7_hvm=${SRC_AMI} -only ${AMI}

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
	@echo "      syntax:    ${PACK_CMD} ${VARFILE_ARG} ${BUILD_PATH}/<COMMAND>/<COMMAND>.json"
	@echo ""
	@echo "    pack-all:  - pack spel, forensics, harden as well as all downstream builds for pack-harden"
	@echo " pack-harden:  - pack harden, as well as all downstream builds: burp, dsm, jenkins, jumpbox, ldap, nessus, openvpn, splunk"
	@echo ""

check-setup:
	@if [ -z "$(shell aws --version)" ]; then echo "AWS CLI not installed"; \
		else echo AWS account $(shell aws sts get-caller-identity --query Account); fi
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


.PHONY: pack pack-harden pack-all

pack:

ifeq (log, $(filter log, $(MAKECMDGOALS)))
	$(eval LOGGER="| tee build-${timestamp}.log")
	${ECHO_CMD} logging
endif

ifeq (debug, $(filter debug, $(MAKECMDGOALS)))
	$(eval PACK_OPT=" -debug")
	${ECHO_CMD} debugging
endif

%:
	@:


pack-all: spel forensics pack-harden

pack-harden: harden ldap openvpn jumpbox jenkins burp dsm nessus splunk

.PHONY: burp dsm forensics harden jenkins jumpbox ldap nessus openvpn spel splunk

burp:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %burp-update.json, $(BUILD_FILES)) ${LOGGER}

dsm:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %deep-security.json, $(BUILD_FILES)) ${LOGGER}

forensics:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %forensics.json, $(BUILD_FILES)) ${LOGGER}

harden:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %harden.json, $(BUILD_FILES)) ${LOGGER}

jenkins:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %jenkins.json, $(BUILD_FILES)) ${LOGGER}

jumpbox:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %jumpbox.json, $(BUILD_FILES)) ${LOGGER}

ldap:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %ldap.json, $(BUILD_FILES)) ${LOGGER}

nessus:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %nessus-scanner.json, $(BUILD_FILES)) ${LOGGER}

openvpn:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %openvpn.json, $(BUILD_FILES)) ${LOGGER}

spel:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} ${SPEL_OPT} $(filter %minimal-linux.json, $(BUILD_FILES)) ${LOGGER}

splunk:
	${ECHO_CMD} $(PACK_OPT) ${VARFILE_OPT} $(filter %splunk.json, $(BUILD_FILES)) ${LOGGER}
