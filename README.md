## Installation

It's simple!

1. Copy
2. Paste
3. ???
4. Profit!

```
git clone http://curlba.sh/jhartog/bashprompt.git
cp bashprompt/.bashrc ~/.bash_prompt
if [ -z "$(grep 'source ~/.bash_prompt' ~/.bashrc)" ]; then cat >> ~/.bashrc << "EOF"
# Import bashprompt
source ~/.bash_prompt
EOF
fi
source ~/.bashrc
```
