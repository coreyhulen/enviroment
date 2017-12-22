.PHONY: all install clean nuke

all: install

install:
	@cd shell && $(MAKE) install
	@cd vim && $(MAKE) install
	@echo "CONGRATS! Install successful"
	
clean:
	@cd shell && $(MAKE) clean
	@cd vim && $(MAKE) clean
	@echo "CONGRATS! Uninstall successful"

nuke:
	@cd shell && $(MAKE) nuke
	@cd vim && $(MAKE) nuke
	@echo "BOOM! everything is gone"
	
	
