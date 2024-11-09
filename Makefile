.PHONY: default
default:
	terraform fmt --recursive
	terraform-docs markdown --output-file README.md .
