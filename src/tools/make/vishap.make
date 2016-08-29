# DO NOT RUN THIS MAKEFILE DIRECTLY.
#
# Always use the makefile in the root of the enlistment. This makefile
# depends on up to date configuration files generated by the root makefile.




# Be independent of any CFLAGS settings in the calling environment
CFLAGS =

# Gnu make has the make initial directory in CURDIR, BSD make has it in .CURDIR.
ROOTDIR = $(CURDIR)$(.CURDIR)

# Configuration.Make is created by src/tools/make/configure.c, which is run on
# *every* build by the makefile in the enlistment root.
include ./Configuration.Make

FLAVOUR  = $(OS).$(DATAMODEL).$(COMPILER)
BUILDDIR = build/$(FLAVOUR)
VISHAP   = $(ONAME)$(BINEXT)




# Default make target - explain usage
usage:
	@echo ""
	@echo Do not run this makefile directly, always run the makefile in
	@echo the root of the enlistment.




clean:
	@printf "\n\n--- Cleaning branch $(BRANCH) $(OS) $(COMPILER) $(DATAMODEL) ---\n\n"
	rm -rf $(BUILDDIR)
	rm -f $(VISHAP)




# Assemble: Generate the Vishap Oberon compiler binary by compiling the C sources in the build directory

assemble:
	@printf "\nmake assemble - compiling Oberon compiler c source:\n"
	@printf "  VERSION: %s\n" "$(VERSION)"
	@printf "  BRANCH:  %s\n" "$(BRANCH)"
	@printf "  Target characteristics:\n"
	@printf "    PLATFORM:   %s\n" "$(PLATFORM)"
	@printf "    OS:         %s\n" "$(OS)"
	@printf "    BUILDDIR:   %s\n" "$(BUILDDIR)"
	@printf "    INSTALLDIR: %s\n" "$(INSTALLDIR)"
	@printf "  Oberon characteristics:\n"
	@printf "    INTSIZE:    %s\n" "$(INTSIZE)"
	@printf "    ADRSIZE:    %s\n" "$(ADRSIZE)"
	@printf "    ALIGNMENT:  %s\n" "$(ALIGNMENT)"
	@printf "  C compiler:\n"
	@printf "    COMPILER:   %s\n" "$(COMPILER)"
	@printf "    COMPILE:    %s\n" "$(COMPILE)"
	@printf "    DATAMODEL:  %s\n" "$(DATAMODEL)"

	cd $(BUILDDIR) && $(COMPILE) -c SYSTEM.c  Configuration.c Platform.c Heap.c
	cd $(BUILDDIR) && $(COMPILE) -c Console.c Strings.c       Modules.c  Files.c
	cd $(BUILDDIR) && $(COMPILE) -c Reals.c   Texts.c         vt100.c    errors.c
	cd $(BUILDDIR) && $(COMPILE) -c OPM.c     extTools.c      OPS.c      OPT.c
	cd $(BUILDDIR) && $(COMPILE) -c OPC.c     OPV.c           OPB.c      OPP.c

	cd $(BUILDDIR) && $(COMPILE) $(STATICLINK) Vishap.c -o $(ROOTDIR)/$(VISHAP) \
	SYSTEM.o  Configuration.o Platform.o Heap.o    Console.o Strings.o       Modules.o  Files.o \
	Reals.o   Texts.o         vt100.o    errors.o  OPM.o     extTools.o      OPS.o      OPT.o \
	OPC.o     OPV.o           OPB.o      OPP.o
	@printf "$(VISHAP) created.\n"




compilerfromsavedsource:
	@echo Populating clean build directory from bootstrap C sources.
	@mkdir -p $(BUILDDIR)
	@cp bootstrap/$(PLATFORM)-$(ADRSIZE)$(ALIGNMENT)/* $(BUILDDIR)
	@make -f src/tools/make/vishap.make -s assemble




translate:
# Make sure we have an oberon compiler binary: if we built one earlier we'll use it,
# otherwise use one of the pre-prepared sets of C sources in the bootstrap directory.

	if [ ! -e $(VISHAP) ]; then make -f src/tools/make/vishap.make -s compilerfromsavedsource; fi

	@printf "\nmake translate - translating compiler source from Oberon to C:\n"
	@printf "  PLATFORM:  %s\n" $(PLATFORM)
	@printf "  INTSIZE:   %s\n" $(INTSIZE)
	@printf "  ADRSIZE:   %s\n" $(ADRSIZE)
	@printf "  ALIGNMENT: %s\n" $(ALIGNMENT)
	@mkdir -p $(BUILDDIR)
	@rm -f $(BUILDDIR)/*.sym

	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../Configuration.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/system/Platform$(PLATFORM).Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfFapx -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/system/Heap.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/system/Console.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/library/v4/Strings.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/library/v4/Modules.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfFx   -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/system/Files.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/library/v4/Reals.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/library/v4/Texts.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/library/misc/vt100.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/errors.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/OPM.cmdln.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/extTools.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfFx   -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/OPS.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/OPT.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/OPC.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/OPV.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/OPB.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SsfF    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/OPP.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ssfm    -B$(INTSIZE)$(ADRSIZE)$(ALIGNMENT) ../../src/compiler/Vishap.Mod

	cp src/system/*.[ch] $(BUILDDIR)

	@printf "$(BUILDDIR) filled with compiler C source.\n"




browsercmd:
	@printf "\nMaking symbol browser\n"
	@cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -fSm ../../src/tools/browser/BrowserCmd.Mod
	@cd $(BUILDDIR); $(COMPILE) BrowserCmd.c -o showdef \
	  Platform.o Texts.o OPT.o Heap.o Console.o SYSTEM.o OPM.o OPS.o OPV.o \
	  Files.o Reals.o Modules.o vt100.o errors.o Configuration.o Strings.o \
	  OPC.o




FORCE:

testcoordinator: FORCE
	@rm -f testcoordinator.exe testclient.exe
	@make -f src/tools/make/vishap.make -s testtools


testtools:
	@printf "\nMaking test coordinator\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -SfFs ../../src/tools/testcoordinator/IP.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Sfsm ../../src/tools/testcoordinator/TestCoordinator.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Sfsm ../../src/tools/testcoordinator/TestClient.Mod
	cd $(BUILDDIR); $(COMPILE) -c IP.c
	cd $(BUILDDIR); $(COMPILE) TestCoordinator.c -o $(ROOTDIR)/testcoordinator \
	                           Platform.o SYSTEM.o Heap.o Console.o Strings.o IP.o
	cd $(BUILDDIR); $(COMPILE) TestClient.c      -o $(ROOTDIR)/testclient      \
	                           Platform.o SYSTEM.o Heap.o Console.o Strings.o IP.o




# installable: Check for access to the installation directory

installable:
	@rm -rf "S(INSTALLDIR)/test-access-qqq"
	@if ! mkdir -p "$(INSTALLDIR)/test-access-qqq";then echo "\\n\\n   Cannot write to install directory.\\n   Please use sudo or run as root/administrator.\\n\\n"; exit 1;fi
	@rm -rf "S(INSTALLDIR)/test-access-qqq"




# install: Use only after a successful full build. Installs the compiler
#          and libraries in /opt/$(ONAME).
#          May require root access.
install:
	@printf "\nInstalling into \"$(INSTALLDIR)\"\n"
	@rm -rf "$(INSTALLDIR)"
	@mkdir -p "$(INSTALLDIR)/bin"      "$(INSTALLDIR)/include" "$(INSTALLDIR)/sym" "$(INSTALLDIR)/lib"
	@cp $(BUILDDIR)/*.h                "$(INSTALLDIR)/include/"
	@cp $(BUILDDIR)/*.sym              "$(INSTALLDIR)/sym/"
	@cp $(VISHAP)                      "$(INSTALLDIR)/bin/$(VISHAP)"
	@-cp $(BUILDDIR)/showdef$(BINEXT)  "$(INSTALLDIR)/bin"
	@cp $(BUILDDIR)/lib$(ONAME).*      "$(INSTALLDIR)/lib/"
	@if which ldconfig >/dev/null 2>&1; then $(LDCONFIG); fi


# showpath: Describe how to set the PATH variable
showpath:
	@printf "\nNow add $(INSTALLDIR)/bin to your path, for example with the command:\n"
	@printf "export PATH=\"$(INSTALLDIR)/bin:\$$PATH\"\n"
	@printf "\n"




uninstall:
	@printf "\nUninstalling from \"$(INSTALLDIR)\"\n"
	rm -rf "$(INSTALLDIR)"
	rm -f /etc/ld.so.conf/lib$(ONAME)
	if which ldconfig >/dev/null 2>&1; then ldconfig; fi




v4:
	@printf "\nMaking v4 library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/v4/Args.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/v4/Printer.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/v4/Sets.Mod

ooc2:
	@printf "\nMaking ooc2 library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc2/ooc2Strings.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc2/ooc2Ascii.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc2/ooc2CharClass.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc2/ooc2ConvTypes.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc2/ooc2IntConv.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc2/ooc2IntStr.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc2/ooc2Real0.Mod


TODO: Comment disabled lines contain use of VAL that reads beyond source variable

ooc:
	@printf "\nMaking ooc library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocLowReal.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocLowLReal.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocRealMath.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocOakMath.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocLRealMath.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocLongInts.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocComplexMath.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocLComplexMath.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocAscii.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocCharClass.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocStrings.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocConvTypes.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocLRealConv.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocLRealStr.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocRealConv.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocRealStr.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocIntConv.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocIntStr.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocMsg.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocSysClock.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocTime.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocChannel.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocStrings2.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocRts.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocFilenames.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocTextRider.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocBinaryRider.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocJulianDay.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocFilenames.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocwrapperlibc.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ooc/oocC$(DATAMODEL).Mod

oocX11:
	@printf "\nMaking oocX11 library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/oocX11/oocX11.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/oocX11/oocXutil.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/oocX11/oocXYplane.Mod

ulm:
	@printf "\nMaking ulm library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmObjects.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmPriorities.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmDisciplines.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmServices.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSys.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSYSTEM.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmEvents.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmProcess.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmResources.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmForwarders.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmRelatedEvents.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmTypes.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmStreams.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmStrings.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSysTypes.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmTexts.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSysConversions.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmErrors.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSysErrors.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSysStat.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmASCII.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSets.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmIO.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmAssertions.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmIndirectDisciplines.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmStreamDisciplines.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmIEEE.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmMC68881.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmReals.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmPrint.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmWrite.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmConstStrings.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmPlotters.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmSysIO.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmLoader.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmNetIO.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmPersistentObjects.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmPersistentDisciplines.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmOperations.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmScales.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmTimes.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmClocks.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmTimers.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmConditions.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmStreamConditions.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmTimeConditions.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmCiphers.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmCipherOps.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmBlockCiphers.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmAsymmetricCiphers.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmConclusions.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmRandomGenerators.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmTCrypt.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/ulm/ulmIntOperations.Mod

pow32:
	@printf "\nMaking pow library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/pow/powStrings.Mod

misc:
	@printf "\nMaking misc library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/system/Oberon.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/misc/crt.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/misc/Listen.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/misc/MersenneTwister.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/misc/MultiArrays.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/misc/MultiArrayRiders.Mod

s3:
	@printf "\nMaking s3 library\n"
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethBTrees.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethMD5.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethSets.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethZlib.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethZlibBuffers.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethZlibInflate.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethZlibDeflate.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethZlibReaders.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethZlibWriters.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethZip.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethRandomNumbers.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethGZReaders.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethGZWriters.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethUnicode.Mod
	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethDates.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethReals.Mod
#	cd $(BUILDDIR); $(ROOTDIR)/$(VISHAP) -Ffs ../../src/library/s3/ethStrings.Mod

librarybinary:
	@printf "\nMaking lib$(ONAME)\n"

#	Remove objects that should not be part of the library
	rm -f $(BUILDDIR)/vishap.o

#	Note: remining compiler files are retained in the library allowing the building
#	of utilities like BrowserCmd.Mod (aka showdef).

#	Make static library
	ar rcs "$(BUILDDIR)/lib$(ONAME).a" $(BUILDDIR)/*.o

#	Make shared library
	@cd $(BUILDDIR) && $(COMPILE) -shared -o lib$(ONAME).so *.o




library: v4 ooc2 ooc ulm pow32 misc s3 librarybinary




sourcechanges:
	@cd $(BUILDDIR) && sh $(ROOTDIR)/src/tools/make/sourcechanges.sh $(ROOTDIR)/bootstrap/$(PLATFORM)-$(ADRSIZE)$(ALIGNMENT)




RUNTEST = COMPILER=$(COMPILER) OBECOMP=$(VISHAP) FLAVOUR=$(FLAVOUR) BRANCH=$(BRANCH) sh ./test.sh "$(INSTALLDIR)"

confidence:
	@printf "\n\n--- Confidence tests ---\n\n"
	cd src/test/confidence/hello;           $(RUNTEST)
	cd src/test/confidence/intsyntax;       $(RUNTEST)
	cd src/test/confidence/language;        $(RUNTEST)
	cd src/test/confidence/texts;           $(RUNTEST)
	cd src/test/confidence/library;         $(RUNTEST)
	cd src/test/confidence/lola;            $(RUNTEST)
	cd src/test/confidence/arrayassignment; $(RUNTEST)
	if [ "$(PLATFORM)" != "windows" ] ; then cd src/test/confidence/signal; $(RUNTEST); fi
	@printf "\n\n--- Confidence tests passed ---\n\n"



# auto: A full build started from a central machine running TestCoordinator.
auto:
	@make -f src/tools/make/vishap.make -s clean
	@make -f src/tools/make/vishap.make -s translate
	@make -f src/tools/make/vishap.make -s assemble
	@make -f src/tools/make/vishap.make -s testtools
	while cmd=$$(./testclient -w "$(FLAVOUR)"); do $$cmd 2>&1 | ./testclient -s "$(FLAVOUR)"; done
