.PHONY: install link

install:
	@echo "Installing global Aider configurations..."
	@mkdir -p ~/.config/aider
	@cp aider.conf.yml ~/.aider.conf.yml
	@cp aider-coding-standards.md ~/.config/aider/aider-coding-standards.md
	@echo "Done! Make sure to update the path in .aider.conf.yml if needed, or keep files in place."

# symbolic links (useful for config development)
link:
	@echo "Linking configuration files to home directory..."
	@ln -sf $(PWD)/.aider.conf.yml ~/.aider.conf.yml
	@ln -sf $(PWD)/coding-standards.md ~/.config/aider-standards.md
	@echo "Linked successfully."
