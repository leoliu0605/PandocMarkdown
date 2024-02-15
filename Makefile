# Define date command based on Operating System
ifeq ($(OS),Windows_NT)
	DATE := $(shell echo %date:~0,4%-%date:~5,2%-%date:~8,2%)
else
	DATE := $(shell date +%Y-%m-%d)
endif

define GEN_GFM
pandoc -f markdown -t gfm -o $1.md $1_.md
endef

define GEN_PDF
pandoc -f markdown -t pdf -o $1.pdf $1_.md --pdf-engine=xelatex --toc-depth=3 --number-sections --template=eisvogel.latex --listings --variable date=$(DATE) --lua-filter=diagram.lua $(OPTS)
endef

all:
	@echo Usage:
	@echo   make install   - Install the Eisvogel template and diagram.lua filter
	@echo   make readme    - Generate README.md and README.pdf
	@echo   make example   - Generate example/SAMPLE.md and example/SAMPLE.pdf

install:
ifeq ($(OS),Windows_NT)
	@echo "Fetching the latest Eisvogel release URL..."
	@powershell -Command "$$LATEST_RELEASE_URL = $$(Invoke-RestMethod -Uri 'https://api.github.com/repos/Wandmalfarbe/pandoc-latex-template/releases/latest' | Select-Object -ExpandProperty assets | Where-Object { $$_.name -like '*eisvogel*.zip' } | Select-Object -First 1 -ExpandProperty browser_download_url); \
	if ([string]::IsNullOrEmpty($$LATEST_RELEASE_URL)) { \
		Write-Error 'Error: Unable to retrieve the release URL.'; \
		exit 1; \
	}; \
	Write-Host 'Downloading Eisvogel template...'; \
	Invoke-WebRequest -Uri $$LATEST_RELEASE_URL -OutFile 'Eisvogel.zip'; \
	Write-Host 'Unzipping the template...'; \
	Expand-Archive -Path 'Eisvogel.zip' -DestinationPath $$env:USERPROFILE'\AppData\Roaming\pandoc\templates' -Force; \
	Remove-Item 'Eisvogel.zip';"
	@echo "Fetching the latest diagram.lua release URL..."
	@powershell -Command "$$filtersPath = \"$$(Join-Path $$env:USERPROFILE 'AppData\Roaming\pandoc\filters')\"; \
	if (!(Test-Path -Path $$filtersPath)) { \
		New-Item -ItemType Directory -Path $$filtersPath; \
	} \
	Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/leoli0605/diagram/main/_extensions/diagram/diagram.lua' -OutFile \"$$(Join-Path $$filtersPath 'diagram.lua')\";"
else
	# Unix-like commands (macOS and Linux)
	@echo "Fetching the latest Eisvogel release URL..."
	@LATEST_RELEASE_URL=$$(curl -s https://api.github.com/repos/Wandmalfarbe/pandoc-latex-template/releases/latest | jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' | head -n 1); \
	if [ -z "$$LATEST_RELEASE_URL" ]; then \
		echo "Error: Unable to retrieve the release URL."; \
		exit 1; \
	fi; \
	echo "Downloading Eisvogel template..."; \
	curl -L -o Eisvogel.zip "$$LATEST_RELEASE_URL"; \
	echo "Unzipping the template to $$HOME/.pandoc/templates..."; \
	mkdir -p $$HOME/.pandoc/templates; \
	unzip Eisvogel.zip -d $$HOME/.pandoc/templates; \
	rm Eisvogel.zip
	@echo "Fetching the latest diagram.lua release URL..."
	mkdir -p ~/.pandoc/filters
	curl -L https://raw.githubusercontent.com/leoli0605/diagram/main/_extensions/diagram/diagram.lua -o $$HOME/.pandoc/filters/diagram.lua
ifeq ($(shell uname),Darwin)
	# https://github.com/oh-my-home/homebrew-fonts
	@echo "Installing Source Han Serif fonts..."
	@brew tap oh-my-home/fonts
	@brew install ttc-source-han-serif  # Install Static Super OTC of Source Han Serif.
	@brew install otf-source-han-serif-sc  # Install Source Han Serif - Language Specific OTFs for Simplified Chinese.
	@brew install otf-source-han-serif-tc  # Install Source Han Serif - Language Specific OTFs for Traditional Chinese — Taiwan.
	@brew install otf-source-han-serif-j  # Install Source Han Serif - Language Specific OTFs for Japanese.
	@brew install otf-source-han-serif-k  # Install Source Han Serif - Language Specific OTFs for Korean.
else
	@echo "Installing Noto Sans CJK SC font..."
	@sudo apt-get update
	@sudo apt-get install -y fonts-noto-cjk
endif
endif

readme:
	@echo $(call GEN_GFM,README)
	@echo $(call GEN_PDF,README)

example:
ifeq ($(OS),Windows_NT)
	$(eval OPTS := --variable CJKmainfont="Microsoft YaHei")
else
ifeq ($(shell uname),Darwin)
	$(eval OPTS := --variable CJKmainfont="Source Han Serif TC")
else
	$(eval OPTS := --variable CJKmainfont="Noto Sans CJK TC")
endif
endif
	$(call GEN_GFM,example/SAMPLE)
	$(call GEN_PDF,example/SAMPLE)

.PHONY: all install readme example
