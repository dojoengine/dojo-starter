katana:
	katana --dev --dev.no-fee --http.cors_origins "*" 

setup:
	@./scripts/setup.sh $(PROFILE)

build: 
	@clear; scarb fmt; sozo build
	
# Define tasks that are not real files
.PHONY: katana setup

# Catch-all rule for undefined commands
%:
	@echo "Error: Command '$(MAKECMDGOALS)' is not defined."
	@exit 1
