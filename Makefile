BUILD_PATH := $(dir $(firstword $(wildcard */packer/*)))
env := stage
var_file := $(filter %$(env).json,$(wildcard $(BUILD_PATH)*.json))
VARFILE_OPT := -var-file=${var_file}
BUILD_FILES := $(wildcard $(BUILD_PATH)*/*.json)
ECHO_CMD := @echo 
PACK_CMD := @packer build
PACK_OPT = ""
timestamp = $(shell date +%Y%m%d-%H%M)
LOGGER =| tee build-$(timestamp).log

AWS_ACCOUNT := $(shell aws sts get-caller-identity --query Account --output text)
src_ami := ami-04ccdf5793086ea95
build := minimal-rhel-7-hvm
SPEL_OPT := -var source_ami_rhel7_hvm=${src_ami} -only ${build}

.PHONY: help check-setup strip

help:
	@echo "       USAGE:    make <COMMAND> <OPTIONS>"
	@echo ""
	@echo "COMMANDs:"
	@echo ""
	@echo "        help:  - help menu. if no argument is passed with make command, help menu will be outputted"
	@echo "          EX:    make help"
	@echo ""
	@echo " check-setup:  - ensure necessary packages are installed, and required Environment Variables set"
	@echo "          EX:    make check-setup"
	@echo ""
	@echo "       strip:  - recursively strips all log files of ANSI color characters in current working directory"
	@echo "          EX:    make strip"
	@echo ""
	@echo "OPTIONs:"
	@echo "                 Optional arguments that can be entered in any order, or not at all."
	@echo ""
	@echo "         log:  - generate a log with timestamp"
	@echo "          EX:    make spel debug log"
	@echo ""
	@echo "                 ** PACKER **"
	@echo ""
	@echo "      SYNTAX:    pack build -debug ${VARFILE_OPT} ${BUILD_PATH}/<template_directory>/<template_file>.json | tee build.log"
	@echo ""
	@echo "COMMANDs:"
	@echo ""
	@echo "        pack:  - specific AMI build from the template file"
	@echo "          EX:    make spel"
	@echo ""
	@echo "    pack-all:  - build AMIs for spel and forensics, as well as all downstream builds for pack-harden"
	@echo "          EX:    make pack-all"
	@echo ""
	@echo " pack-harden:  - build AMIs for harden, as well as all downstream builds"
	@echo "          EX:    make pack-harden"
	@echo ""
	@echo "OPTIONs:"
	@echo ""
	@echo "       debug:  - step through Packer provisioning steps"
	@echo "          EX:    make spel debug"
	@echo ""

check-setup:
	@if [ -z "$(shell aws --version)" ]; then echo "AWS CLI not installed"; \
		elif [ ${AWS_ACCOUNT} -eq 029803331920 ]; then echo "fedhr Prod Env: ${AWS_ACCOUNT}"; \
		elif [ ${AWS_ACCOUNT} -eq 578411044202 ]; then echo "SiteOps Stage Env: ${AWS_ACCOUNT}"; \
		elif [ ${AWS_ACCOUNT} -eq 578463482707 ]; then echo "SecOps Stage Env: ${AWS_ACCOUNT}"; \
		else echo "Unable to find acceptable AWS account"; fi

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

strip-ansi:
	@sed -i 's|\x1b\[[0-9;]*[Am]||g' $(wildcard *.log)

.PHONY: pack pack-harden pack-all

pack:
ifneq (log, $(filter log, $(MAKECMDGOALS)))
	$(eval LOGGER='')
endif

ifeq (debug, $(filter debug, $(MAKECMDGOALS)))
	$(eval PACK_OPT=-debug )
endif

%:
	@:


pack-all: spel forensics pack-harden

pack-harden: harden ldap openvpn jumpbox jenkins burp dsm nessus splunk

.PHONY: burp dsm forensics harden jenkins jumpbox ldap nessus openvpn spel splunk

burp:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %burp-update.json, $(BUILD_FILES)) ${LOGGER}

dsm:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %deep-security.json, $(BUILD_FILES)) ${LOGGER}

forensics:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %forensics.json, $(BUILD_FILES)) ${LOGGER}

harden:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %harden.json, $(BUILD_FILES)) ${LOGGER}

jenkins:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %jenkins.json, $(BUILD_FILES)) ${LOGGER}

jumpbox:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %jumpbox.json, $(BUILD_FILES)) ${LOGGER}

ldap:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %ldap.json, $(BUILD_FILES)) ${LOGGER}

nessus:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %nessus-scanner.json, $(BUILD_FILES)) ${LOGGER}

openvpn:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %openvpn.json, $(BUILD_FILES)) ${LOGGER}

spel:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} ${SPEL_OPT} $(filter %minimal-linux.json, $(BUILD_FILES)) ${LOGGER}

splunk:
	${PACK_CMD} ${PACK_OPT} ${VARFILE_OPT} $(filter %splunk.json, $(BUILD_FILES)) ${LOGGER}
