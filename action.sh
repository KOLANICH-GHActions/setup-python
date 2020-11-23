#!/usr/bin/env bash

set -e;

NEED_PYTEST=$1;

THIS_SCRIPT_DIR=`dirname "${BASH_SOURCE[0]}"`; # /home/runner/work/_actions/KOLANICH-GHActions/setup-python/master
echo "This script is $THIS_SCRIPT_DIR";
THIS_SCRIPT_DIR=`realpath "${THIS_SCRIPT_DIR}"`;
echo "This script is $THIS_SCRIPT_DIR";
ACTIONS_DIR=`realpath "$THIS_SCRIPT_DIR/../../.."`;

AUTHOR_NAMESPACE=KOLANICH-GHActions;
HARDENING_ACTION_REPO=$AUTHOR_NAMESPACE/hardening;
BOOTSTRAP_ACTION_REPO=$AUTHOR_NAMESPACE/bootstrap-python-packaging;
GIT_PIP_ACTION_REPO=$AUTHOR_NAMESPACE/git-pip;

HARDENING_ACTION_DIR=$ACTIONS_DIR/$HARDENING_ACTION_REPO/master;
BOOTSTRAP_ACTION_DIR=$ACTIONS_DIR/$BOOTSTRAP_ACTION_REPO/master;
GIT_PIP_ACTION_DIR=$ACTIONS_DIR/$GIT_PIP_ACTION_REPO/master;

if [ -d "$HARDENING_ACTION_DIR" ]; then
	:
else
	git clone --depth=1 https://github.com/$HARDENING_ACTION_REPO $HARDENING_ACTION_DIR;
fi;

if [ -d "$BOOTSTRAP_ACTION_DIR" ]; then
	:
else
	git clone --depth=1 https://github.com/$BOOTSTRAP_ACTION_REPO $BOOTSTRAP_ACTION_DIR;
fi;

if [ -d "$GIT_PIP_ACTION_DIR" ]; then
	:
else
	git clone --depth=1 https://github.com/$GIT_PIP_ACTION_REPO $GIT_PIP_ACTION_DIR;
fi;

bash $HARDENING_ACTION_DIR/action.sh;
bash $BOOTSTRAP_ACTION_DIR/action.sh;
bash $GIT_PIP_ACTION_DIR/action.sh $THIS_SCRIPT_DIR/pythonPackagesToInstallFromGit.txt;

if [ $NEED_PYTEST ]; then
	bash $GIT_PIP_ACTION_DIR/action.sh $THIS_SCRIPT_DIR/pythonPackagesToInstallFromGitPytestDeps.txt;

	git clone --depth=50 https://github.com/pytest-dev/pytest.git
	cd pytest;
	sed -E -i 's%([a-z_-]+>=[0-9]\.[0-9]+),<[0-9]\.[0-9]%\1%g' ./setup.cfg;
	python3 -m build -nwx .;
	sudo pip3 install --upgrade ./dist/*.whl;
	cd ..;
	rm -rf ./pytest;
fi;
