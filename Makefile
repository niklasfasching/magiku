.PHONY: init
init: git sshd ufw unattended-upgrades environment packages
	mkdir -p /usr/local/lib/systemd/system
	find -mindepth 2 -maxdepth 2 -name 'Makefile' -execdir make init \;

.PHONY: environment
environment:
	ln --force --symbolic ~/config/general/environment /etc/environment

.PHONY: git
git:
	ln --force --symbolic ~/config/general/gitconfig ~/.gitconfig

.PHONY: sshd
sshd:
	ln --force --symbolic ~/config/general/authorized_keys ~/.ssh/authorized_keys
	sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
	systemctl restart sshd

.PHONY: ufw
ufw:
	ufw disable
	echo y | ufw reset
	ufw default deny incoming
	ufw default allow outgoing
	ufw allow ssh
	ufw allow http
	ufw allow https
	echo y | ufw enable

.PHONY: unattended-upgrades
unattended-upgrades:
	apt-get install --assume-yes unattended-upgrades
	ln --force --symbolic ~/config/general/auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

.PHONY: install
install:
	@find /usr/local/lib/systemd/system -xtype l -exec rm {} \; # cleanup systemd load path (remove anything not in repo anymore)
	find -mindepth 2 -maxdepth 2 -name 'Makefile' -execdir make install \;
	@systemctl daemon-reload
	@systemctl --state=not-found --all | grep ' running ' | awk '{print $$2}' | xargs --max-lines=1 --no-run-if-empty systemctl stop

.PHONY: packages
packages:
	# snap refresh && snap install ...
	# apt-get update --quiet=2 && apt-get install --quiet=2 ...
