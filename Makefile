MAKE=make

PWD=`pwd`

# hosting variables
SLEEP_TIME=300
EXCLUDE=--exclude=*.tar.gz --exclude=*~ $(EXCLUDE-FILES)
ALL_BUT_GZ=$(subst $(wildcard *.tar.gz),,$(wildcard *))
DATADIR=/usr/share/plinth
PYDIR=$(DATADIR)/python/plinth

## Catch-all targets
default: config dirs docs
all: default

predepend:
	sudo sh -c "apt-get install pandoc psmisc python2.7 python-bcrypt python-cherrypy3 python-django python-passlib python-bootstrapform libjs-twitter-bootstrap sudo"
	git submodule init
	git submodule update
	touch predepend

install: default apache-install freedombox-setup-install
	mkdir -p $(DESTDIR)/etc/init.d $(DESTDIR)/etc/plinth
	cp plinth.sample.config $(DESTDIR)/etc/plinth/plinth.config
	mkdir -p $(DESTDIR)$(PYDIR) $(DESTDIR)$(DATADIR) $(DESTDIR)/usr/bin \
		$(DESTDIR)/usr/share/doc/plinth $(DESTDIR)/usr/share/man/man1
	cp -a static themes $(DESTDIR)$(DATADIR)/
	cp -a actions $(DESTDIR)$(DATADIR)/
	cp -a sudoers.d $(DESTDIR)/etc/sudoers.d
	cp -a *.py modules templates $(DESTDIR)$(PYDIR)/
	cp share/init.d/plinth $(DESTDIR)/etc/init.d
	cp -a lib/* $(DESTDIR)/usr/lib
	install plinth $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/var/lib/plinth/sessions $(DESTDIR)/var/log/plinth $(DESTDIR)/var/run
	mkdir -p $(DESTDIR)/var/lib/plinth/data
	rm -f $(DESTDIR)/var/lib/plinth/users/sqlite3.distrib

freedombox-setup-install:
	install -m755 -D setup.d/86_plinth $(DESTDIR)/usr/lib/freedombox/setup.d/86_plinth

uninstall:
	rm -rf $(DESTDIR)/usr/lib/python2.7/plinth $(DESTDIR)/usr/share/plinth/ \
		$(DESTDIR)/etc/plinth $(DESTDIR)/var/lib/plinth $(DESTDIR)/usr/share/doc/plinth/ \
		$(DESTDIR)/var/log/plinth
	rm -f $(DESTDIR)/usr/bin/plinth $(DESTDIR)/etc/init.d/plinth \
		$(DESTDIR)/usr/share/man/man1/plinth.1.gz $(DESTDIR)/var/run/plinth.pid

dirs:
	@mkdir -p data/sessions

config: Makefile
	@test -f plinth.config || cp plinth.sample.config plinth.config

docs:
	@$(MAKE) -s -C doc
doc: docs

html:
	@$(MAKE) -s -C doc html

clean:
	@rm -f cherrypy.config data/sessions/*
	@find . -name "*~" -exec rm {} \;
	@find . -name ".#*" -exec rm {} \;
	@find . -name "#*" -exec rm {} \;
	@find . -name "*.pyc" -exec rm {} \;
	@find . -name "*.bak" -exec rm {} \;
	@$(MAKE) -s -C doc clean
	rm -f plinth.config
	rm -f predepend

hosting:
	bash start.sh &
	while [ 1 ]; do make current-checkout.tar.gz current-repository.tar.gz; sleep $(SLEEP_TIME); done

current-checkout.tar.gz: $(ALL_BUT_GZ)
	tar cz $(EXCLUDE) * > current-checkout.tar.gz

current-repository.tar.gz: $(ALL_BUT_GZ)
	tar cz $(EXCLUDE) * .git > current-repository.tar.gz

apache-install:
	install -D -m644 share/apache2/plinth.conf $(DESTDIR)/etc/apache2/sites-available/plinth.conf
	install -D -m644 share/apache2/plinth-ssl.conf $(DESTDIR)/etc/apache2/sites-available/plinth-ssl.conf
apache-config: apache-install apache-modules
	a2ensite plinth
	a2ensite plinth-ssl
	service apache2 reload

apache-modules:
# enable all required modules, create snakeoil cert.
	./setup.d/86_plinth
	service apache2 restart
