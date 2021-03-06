# 
# No modifications of this Makefile should be necessary.
#
# This file contains the build instructions for installing OMF files.  It is
# generally called from the makefiles for particular formats of documentation.
#
# Note that you must configure your package with --localstatedir=/var/lib
# so that the scrollkeeper-update command below will update the database
# in the standard scrollkeeper directory.
#
# If it is impossible to configure with --localstatedir=/var/lib, then
# modify the definition of scrollkeeper_localstate_dir so that
# it points to the correct location. Note that you must still use 
# $(localstatedir) in this or when people build RPMs it will update
# the real database on their system instead of the one under RPM_BUILD_ROOT.
#
# Note: This make file is not incorporated into xmldocs.make because, in
#       general, there will be other documents install besides XML documents
#       and the makefiles for these formats should also include this file.
#
# About this file:
#	This file was taken from scrollkeeper_example2, a package illustrating
#	how to install documentation and OMF files for use with ScrollKeeper
#	0.3.x and 0.4.x.  For more information, see:
#		http://scrollkeeper.sourceforge.net/	
# 	Version: 0.1.2 (last updated: March 20, 2002)
#

omf_dest_dir=$(datadir)/omf
scrollkeeper_localstate_dir = $(localstatedir)/scrollkeeper

omf: omf_timestamp

omf_timestamp: $(omffile)
	-for file in $(omffile); do \
	    scrollkeeper-preinstall $(docdir)/$(docname).xml $(srcdir)/$$file $$file.out; \
	done
	touch omf_timestamp

install-data-hook-omf:
	$(mkinstalldirs) "$(DESTDIR)$(omf_dest_dir)"
	for file in $(omffile); do \
	    omfdir="$(DESTDIR)$(omf_dest_dir)/`echo $$file | sed 's/-[^-]*\.omf$$//'`"; \
	    $(mkinstalldirs) "$$omfdir"; \
	    $(INSTALL_DATA) "$$file.out" "$$omfdir/$$file"; \
	    if test "x$(_ENABLE_SK)" = "xtrue"; then \
	        scrollkeeper-update -p "$(scrollkeeper_localstate_dir)" -o "$$omfdir"; \
	    fi; \
	done;

uninstall-local-omf:
	for file in $(omffile); do \
	    omfdir="$(DESTDIR)$(omf_dest_dir)/`echo $$file | sed 's/-[^-]*\.omf$$//'`"; \
	    if test "x$(_ENABLE_SK)" == "xtrue"; then \
	        scrollkeeper-uninstall -p "$(scrollkeeper_localstate_dir)" "$$omfdir/$$file"; \
	    fi; \
	    rm -f "$$omfdir/$$file"; \
	    rmdir --ignore-fail-on-non-empty "$$omfdir"; \
	done
	rmdir --ignore-fail-on-non-empty "$(DESTDIR)$(omf_dest_dir)"

