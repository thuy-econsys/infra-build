SHELL = /bin/bash
BUILD_PATH = ./infrastructure/packer
VAR_FILE = ${BUILD_PATH}/packer-vars-stage.json
SRC_AMI = ami-04ccdf5793086ea95
BUILD = minimal-rhel-7-hvm

.PHONY: help check-setup pack-harden pack-all burp dsm forensics harden jenkins	jumpbox ldap nessus openvpn spel splunk

help:
	@echo ''
	@echo 'usage: make [TARGET] [EXTRA_ARGUMENTS]'

check-setup:

	@if [ -z "$(shell aws --version)" ]; then echo "AWS CLI not installed"; else echo AWS account $(shell aws sts get-caller-identity --query Account); fi
	@if [ -z "$(shell packer -v)" ]; then echo "Packer not installed"; fi
	@if [ -z "$(shell terraform -v)" ]; then echo "Terraform not installed"; fi
	@if [ -z "$(shell terragrunt -v)" ]; then echo "Terragrunt not installed"; fi

	@if [ -z "${AWS_ACCESS_KEY_ID}" ]; then echo "AWS_ACCESS_KEY_ID needs to be set"; fi
	@if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then echo "AWS_SECRET_ACCESS_KEY needs to be set"; fi
	@if [ -z "${AWS_REGION}" ]; then echo "AWS_REGION needs to be set"; fi
	@if [ -z "${REMOTE_STATE_BUCKET}" ]; then echo "REMOTE_STATE_BUCKET needs to be set"; fi
	@if [ -z "${REMOTE_STATE_PROFILE}" ]; then echo "REMOTE_STATE_PROFILE needs to be set"; fi
	@if [ -z "${STATE_LOCK_DYNAMODB_TABLE}" ]; then echo "STATE_LOCK_DYNAMODB_TABLE needs to be set"; fi

pack-harden: harden ldap openvpn jumpbox jenkins burp dsm nessus splunk

pack-all: spel forensics harden-all

burp:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/burpsuite/burp-update.json

dsm:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/deepsecurity/deep-security.json

forensics:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/forensics/forensics.json

harden:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/harden/harden.json

jenkins:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/jenkins/jenkins.json

jumpbox:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/jumpbox/jumpbox.json

ldap:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/ldap/ldap.json

nessus:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/nessus/nessus-scanner.json

openvpn:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/openvpn/openvpn.json

spel:
	@packer build -var-file=$VAR_FILE -var source_ami_rhel7_hvm=$SRC_AMI -only $BUILD ${BUILD_PATH}/spel/minimal-linux.json

splunk:
	@packer build -var-file=$VAR_FILE ${BUILD_PATH}/splunk/splunk.json
