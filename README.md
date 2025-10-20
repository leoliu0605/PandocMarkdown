# This is a Pandoc Markdown Sample

This is a sample of a markdown file that can be converted to a PDF using Pandoc.

## Installation

To install Pandoc, you can use the following command:

``` shell
# for Windows
choco install -y pandoc miktex
```

``` shell
# for macOS
brew install pandoc
brew install --cask mactex-no-gui
```

``` shell
# for Ubuntu
sudo apt update && sudo apt install -y jq texlive-xetex texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra && \
LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | jq -r '.assets[] | select(.name | endswith("-linux-amd64.tar.gz")) | .browser_download_url' | head -n 1) && \
curl -L -o pandoc.tar.gz $LATEST_RELEASE_URL && \
sudo tar -xvzf pandoc.tar.gz --strip-components 1 -C /usr/local && \
rm pandoc.tar.gz && \
pandoc --version
```

``` shell
make install
npm install -g @mermaid-js/mermaid-cli
```

## Links

- https://github.com/Wandmalfarbe/pandoc-latex-template
- https://github.com/pandoc-ext/diagram
