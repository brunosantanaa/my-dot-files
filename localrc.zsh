##############################################################################
# Profile definitions
# >>> asdf
. $HOME/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
export PATH="/home/brunosantanaa/Selenium/chromedriver/:$PATH"
export PATH="/home/brunosantanaa/Selenium/geckodriver/:$PATH"
. "$HOME/.cargo/env"
